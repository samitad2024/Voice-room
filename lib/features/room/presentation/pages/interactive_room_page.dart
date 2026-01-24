import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../data/datasources/zego_audio_datasource.dart';
import '../../data/datasources/room_realtime_service.dart';
import '../../data/datasources/room_remote_datasource.dart';
import '../../domain/entities/room.dart';
import '../../domain/entities/live_room_participant.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../widgets/speaker_grid_widget.dart';
import '../widgets/audience_list_widget.dart';
import '../widgets/speaker_requests_widget.dart';
import '../../../gifts/domain/entities/gift.dart';
import '../../../gifts/data/datasources/gift_remote_datasource.dart';
import '../../../gifts/presentation/widgets/gift_tray_widget.dart';
import '../../../gifts/presentation/widgets/gift_animation_overlay.dart';

/// Interactive Voice Room Page
/// Features: Speaker grid, audience list, real-time updates, audio controls
/// Follows blueprint.md specifications for voice rooms
class InteractiveRoomPage extends StatefulWidget {
  final Room room;

  const InteractiveRoomPage({
    super.key,
    required this.room,
  });

  @override
  State<InteractiveRoomPage> createState() => _InteractiveRoomPageState();
}

class _InteractiveRoomPageState extends State<InteractiveRoomPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late final ZegoAudioDataSource _zego;
  late final RoomRealtimeService _realtimeService;
  late final RoomRemoteDataSource _roomDataSource;

  bool _isMuted = false;

  /// Whether Zego audio engine is initialized
  bool _zegoInitialized = false;
  bool _isLoading = true;
  String? _currentUserId;
  String _currentUserRole = 'audience';
  String? _errorMessage;

  // Real participants from Supabase Realtime
  List<LiveRoomParticipant> _speakers = [];
  List<LiveRoomParticipant> _audience = [];
  StreamSubscription<List<LiveRoomParticipant>>? _participantsSubscription;

  // Speaker requests for owners/admins
  List<Map<String, dynamic>> _speakerRequests = [];
  StreamSubscription<List<Map<String, dynamic>>>? _speakerRequestsSubscription;

  // Gift system
  List<Gift> _availableGifts = [];
  int _userCoins = 0;
  late final GiftRemoteDataSource _giftDataSource;
  final StreamController<RoomGift> _giftStreamController =
      StreamController<RoomGift>.broadcast();
  RealtimeChannel? _giftsChannel;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Initialize services
    _zego = di.sl<ZegoAudioDataSource>();
    _realtimeService = RoomRealtimeService(supabase: Supabase.instance.client);
    _roomDataSource = di.sl<RoomRemoteDataSource>();
    _giftDataSource =
        GiftRemoteDataSourceImpl(supabase: Supabase.instance.client);

    // Get current user
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user.uid;
      _currentUserRole =
          authState.user.uid == widget.room.ownerId ? 'owner' : 'audience';
    }

    // Initialize everything
    _initializeRoom();
  }

  /// Initialize room: subscribe to realtime + init Zego
  Future<void> _initializeRoom() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      debugPrint(
          '\n╔══════════════════════════════════════════════════════════════');
      debugPrint('║ 🎵 INITIALIZING VOICE ROOM');
      debugPrint(
          '╠══════════════════════════════════════════════════════════════');
      debugPrint('║ Room: ${widget.room.title}');
      debugPrint('║ Room ID: ${widget.room.id}');
      debugPrint('║ User: $_currentUserId');
      debugPrint('║ Role: $_currentUserRole');
      debugPrint(
          '╚══════════════════════════════════════════════════════════════');

      // Step 1: Subscribe to realtime participants
      debugPrint('\n📡 Step 1: Setting up Realtime subscriptions...');
      await _realtimeService.subscribeToRoom(widget.room.id);

      // Listen to participant changes
      _participantsSubscription = _realtimeService.participantsStream.listen(
        (participants) {
          if (mounted) {
            setState(() {
              _speakers = participants.where((p) => p.canSpeak).toList();
              _audience = participants.where((p) => p.isAudience).toList();
            });
            debugPrint(
                '   👥 Participants updated: ${_speakers.length} speakers, ${_audience.length} audience');

            // Check if current user was kicked
            final currentUser = participants.firstWhere(
              (p) => p.userId == _currentUserId,
              orElse: () => participants.first, // dummy value
            );

            if (currentUser.userId != _currentUserId) {
              // Current user was kicked
              debugPrint('   ⚠️  Current user was kicked from the room');
              _handleKicked();
              return;
            }

            // Check if admin muted current user (if speaker)
            if (currentUser.canSpeak && currentUser.isMuted != _isMuted) {
              debugPrint(
                  '   🔇 Mute state changed by admin: ${currentUser.isMuted}');
              setState(() {
                _isMuted = currentUser.isMuted;
              });

              // Update Zego mute state
              if (_isMuted) {
                _zego.muteMicrophone(true);
              } else {
                _zego.muteMicrophone(false);
              }

              // Show notification
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _isMuted
                        ? 'You have been muted by the moderator'
                        : 'You have been unmuted by the moderator',
                  ),
                  duration: const Duration(seconds: 3),
                ),
              );
            }

            // Update current user role if changed
            if (currentUser.role != _currentUserRole) {
              final oldRole = _currentUserRole;
              final newRole = currentUser.role;
              debugPrint('   👤 Role changed: $oldRole → $newRole');

              setState(() {
                _currentUserRole = newRole;
              });

              // If promoted to speaker, start publishing audio
              if (oldRole == 'audience' && newRole == 'speaker') {
                _handlePromotedToSpeaker();
              }
              // If demoted from speaker to audience, stop publishing
              else if (oldRole == 'speaker' && newRole == 'audience') {
                _handleDemotedToAudience();
              }
            }
          }
        },
        onError: (error) {
          debugPrint('   ❌ Realtime error: $error');
        },
      );

      // Initial data
      _speakers = _realtimeService.speakers;
      _audience = _realtimeService.audience;

      // Subscribe to speaker requests (for owners/admins)
      if (_currentUserRole == 'owner' || _currentUserRole == 'admin') {
        _speakerRequestsSubscription =
            _realtimeService.speakerRequestsStream.listen(
          (requests) {
            if (mounted) {
              setState(() {
                _speakerRequests = requests;
              });
              debugPrint(
                  '   🔔 Speaker requests updated: ${requests.length} pending');
            }
          },
          onError: (error) {
            debugPrint('   ❌ Speaker requests error: $error');
          },
        );

        // Initial requests data
        _speakerRequests = _realtimeService.speakerRequests;
      }

      // Step 2: Initialize Zego voice
      debugPrint('\n🎤 Step 2: Initializing Zego voice engine...');
      await _initZego();

      // Step 3: Load gifts and user balance
      debugPrint('\n🎁 Step 3: Loading gifts and user balance...');
      await _loadGiftsAndBalance();

      // Step 4: Subscribe to gift stream
      debugPrint('\n🎁 Step 4: Subscribing to gift stream...');
      _subscribeToGifts();

      setState(() {
        _isLoading = false;
        _zegoInitialized = true;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _currentUserRole == 'owner'
                        ? 'Room created! You are the host.'
                        : 'Joined room successfully!',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint('\n❌ Room initialization failed: $e');
      debugPrint(stackTrace.toString());

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to join room: ${e.toString().split(':').last.trim()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _initializeRoom,
            ),
          ),
        );
      }
    }
  }

  /// Initialize Zego voice engine and join room
  Future<void> _initZego() async {
    try {
      // 1. Initialize Engine
      debugPrint('\n   🎤 Initializing Zego Engine...');
      await _zego.initEngine();

      // 2. Set Callbacks
      debugPrint('   📡 Setting up connection callbacks...');
      _zego.setRoomStateUpdateCallback((roomID, state) {
        if (!mounted) return;

        debugPrint('\n📡 CONNECTION STATE CHANGED:');
        debugPrint('   Room: $roomID');
        debugPrint('   New State: $state');

        // Handle room state changes (disconnected, connecting, connected)
        if (state == ZegoRoomState.Connected) {
          debugPrint('   🎉 STATUS: Successfully connected to voice chat!');
        } else if (state == ZegoRoomState.Disconnected) {
          debugPrint('   ⚠️  STATUS: Disconnected from voice chat');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Disconnected from voice chat. Tap to retry.',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 5),
                action: SnackBarAction(
                  label: 'Retry',
                  textColor: Colors.white,
                  onPressed: _initializeRoom,
                ),
              ),
            );
          }
        } else if (state == ZegoRoomState.Connecting) {
          debugPrint('   🔄 STATUS: Connecting to voice chat...');
        }
      });

      // 3. Get Token & Join
      debugPrint(
          '\n╔══════════════════════════════════════════════════════════════');
      debugPrint('║ 🔑 REQUESTING ZEGO TOKEN FROM SUPABASE EDGE FUNCTION');
      debugPrint(
          '╚══════════════════════════════════════════════════════════════');

      if (_currentUserId == null) {
        throw Exception('User ID is null. Please login first.');
      }

      debugPrint('   📤 OUTGOING REQUEST:');
      debugPrint('   ├─ Function: generate-zego-token');
      debugPrint('   ├─ User ID: $_currentUserId');
      debugPrint('   └─ Room ID: ${widget.room.id}');

      final stopwatch = Stopwatch()..start();
      final response = await Supabase.instance.client.functions.invoke(
        'generate-zego-token',
        body: {
          'userId': _currentUserId,
          'roomId': widget.room.id,
        },
      );
      stopwatch.stop();

      debugPrint('\n   📥 INCOMING RESPONSE:');
      debugPrint('   ├─ Status Code: ${response.status}');
      debugPrint('   ├─ Response Time: ${stopwatch.elapsedMilliseconds}ms');
      debugPrint('   └─ Response Data: ${response.data}');

      if (response.status != 200) {
        throw Exception('Token generation failed: ${response.status}');
      }

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null || responseData['token'] == null) {
        throw Exception('Invalid token response');
      }

      final token = responseData['token'] as String;
      debugPrint('\n   ✅ TOKEN RECEIVED SUCCESSFULLY!');
      debugPrint('   ├─ App ID: ${responseData['appID']}');
      debugPrint('   ├─ Token Length: ${token.length} chars');
      debugPrint('   └─ Expires In: ${responseData['expiresIn']} seconds');

      // 4. Join Zego Room
      final authState = context.read<AuthBloc>().state;
      final userName = authState is AuthAuthenticated
          ? (authState.user.name ?? 'User')
          : 'Guest';

      final isHost = _currentUserRole == 'owner';
      debugPrint(
          '\n╔══════════════════════════════════════════════════════════════');
      debugPrint('║ 🚪 JOINING ZEGO VOICE ROOM');
      debugPrint(
          '╚══════════════════════════════════════════════════════════════');
      debugPrint('   ├─ Room ID: ${widget.room.id}');
      debugPrint('   ├─ User: $userName ($_currentUserId)');
      debugPrint('   └─ Role: ${isHost ? "Host (Speaker)" : "Audience"}');

      await _zego.joinRoom(
        roomId: widget.room.id,
        userId: _currentUserId!,
        userName: userName,
        token: token,
        isSpeaker: isHost,
      );

      debugPrint(
          '\n╔══════════════════════════════════════════════════════════════');
      debugPrint('║ ✅ VOICE CHAT INITIALIZATION COMPLETE!');
      debugPrint(
          '╚══════════════════════════════════════════════════════════════\n');
    } catch (e, stackTrace) {
      debugPrint('\n❌ ZEGO INITIALIZATION FAILED: $e');
      debugPrint(stackTrace.toString());
      rethrow;
    }
  }

  /// Handle leaving the room
  Future<void> _leaveRoom() async {
    try {
      debugPrint(
          '\n╔══════════════════════════════════════════════════════════════');
      debugPrint('║ 🚪 LEAVING ROOM');
      debugPrint(
          '╚══════════════════════════════════════════════════════════════');

      // Leave Zego room
      await _zego.leaveRoom(widget.room.id);
      debugPrint('   ✅ Left Zego room');

      // Update database - mark as offline/left
      if (_currentUserId != null) {
        await _roomDataSource.leaveRoom(
          roomId: widget.room.id,
          userId: _currentUserId!,
        );
        debugPrint('   ✅ Updated database');
      }

      // Unsubscribe from realtime
      await _realtimeService.unsubscribe();
      debugPrint('   ✅ Unsubscribed from realtime');
    } catch (e) {
      debugPrint('   ❌ Error leaving room: $e');
    }
  }

  /// Handle mute/unmute
  Future<void> _toggleMute() async {
    try {
      setState(() => _isMuted = !_isMuted);
      await _zego.muteMicrophone(_isMuted);

      // Update database
      if (_currentUserId != null) {
        await _realtimeService.updateMuteStatus(
          widget.room.id,
          _currentUserId!,
          _isMuted,
        );
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                _isMuted ? '🔇 Microphone muted' : '🔊 Microphone unmuted'),
            duration: const Duration(seconds: 1),
            backgroundColor: _isMuted ? Colors.orange : Colors.green,
          ),
        );
      }
    } catch (e) {
      debugPrint('   ❌ Error toggling mute: $e');
    }
  }

  /// Handle when user is promoted to speaker
  Future<void> _handlePromotedToSpeaker() async {
    try {
      debugPrint('\n🎤 ===== USER PROMOTED TO SPEAKER =====');
      debugPrint('   Starting audio publishing...');

      // Start publishing audio stream
      final streamId = '${widget.room.id}_${_currentUserId}_main';
      await _zego.startPublishing(streamId);

      debugPrint('   ✅ Now publishing audio as speaker!');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.mic, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '🎉 You are now a speaker! Your microphone is live.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('   ❌ Error starting audio publishing: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to start audio: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handle when user is demoted from speaker to audience
  Future<void> _handleDemotedToAudience() async {
    try {
      debugPrint('\n👂 ===== USER DEMOTED TO AUDIENCE =====');
      debugPrint('   Stopping audio publishing...');

      // Stop publishing audio stream
      await _zego.stopPublishing();

      debugPrint('   ✅ Stopped publishing audio');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                Icon(Icons.hearing, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'You are now in the audience. Listening mode activated.',
                    style: TextStyle(fontSize: 14),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('   ❌ Error stopping audio publishing: $e');
    }
  }

  @override
  void dispose() {
    debugPrint('🧹 Disposing InteractiveRoomPage...');
    _participantsSubscription?.cancel();
    _speakerRequestsSubscription?.cancel();
    _giftStreamController.close();
    if (_giftsChannel != null) {
      Supabase.instance.client.removeChannel(_giftsChannel!);
    }
    _tabController.dispose();
    if (_zegoInitialized) {
      _leaveRoom();
    }
    _realtimeService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOwnerOrAdmin =
        _currentUserRole == 'owner' || _currentUserRole == 'admin';
    final isSpeaker = _speakers.any((s) => s.userId == _currentUserId);

    // Show loading state
    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          title: Text(widget.room.title),
          backgroundColor: Colors.transparent,
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Joining room...'),
            ],
          ),
        ),
      );
    }

    // Show error state
    if (_errorMessage != null) {
      return Scaffold(
        backgroundColor: colorScheme.surfaceContainerLowest,
        appBar: AppBar(
          title: Text(widget.room.title),
          backgroundColor: Colors.transparent,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text('Failed to join room',
                  style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colorScheme.onSurfaceVariant),
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _initializeRoom,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainerLowest,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.room.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            Text(
              '${_speakers.length} speaking • ${_audience.length} listening',
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          // Live indicator with pulse
          Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.red,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.red.withOpacity(0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.circle, size: 6, color: Colors.white),
                SizedBox(width: 5),
                Text(
                  'LIVE',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) {
              final items = <PopupMenuEntry<String>>[
                const PopupMenuItem(
                  value: 'info',
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, size: 20),
                      SizedBox(width: 12),
                      Text('Room Info'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'share',
                  child: Row(
                    children: [
                      Icon(Icons.share, size: 20),
                      SizedBox(width: 12),
                      Text('Share Room'),
                    ],
                  ),
                ),
              ];

              if (isOwnerOrAdmin) {
                items.add(const PopupMenuDivider());
                items.add(
                  const PopupMenuItem(
                    value: 'end',
                    child: Row(
                      children: [
                        Icon(Icons.stop_circle, size: 20, color: Colors.red),
                        SizedBox(width: 12),
                        Text(
                          'End Room',
                          style: TextStyle(color: Colors.red),
                        ),
                      ],
                    ),
                  ),
                );
              }

              return items;
            },
            onSelected: (value) => _handleMenuAction(value),
          ),
        ],
      ),
      body: Column(
        children: [
          // Room category and type banner
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  colorScheme.primaryContainer.withOpacity(0.7),
                  colorScheme.secondaryContainer.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                _buildInfoChip(
                  colorScheme,
                  Icons.category,
                  widget.room.category,
                ),
                const SizedBox(width: 8),
                _buildInfoChip(
                  colorScheme,
                  widget.room.isPublic ? Icons.public : Icons.lock,
                  widget.room.roomType,
                ),
                const Spacer(),
                if (widget.room.tags.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.surface.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#${widget.room.tags.first}',
                      style: TextStyle(
                        fontSize: 11,
                        color: colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Speaker Requests (for owners/admins)
          if (_speakerRequests.isNotEmpty &&
              (_currentUserRole == 'owner' || _currentUserRole == 'admin'))
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SpeakerRequestsWidget(
                roomId: widget.room.id,
                requests: _speakerRequests,
                onRequestProcessed: () {
                  // Refresh handled by real-time subscription
                },
              ),
            ),

          if (_speakerRequests.isNotEmpty &&
              (_currentUserRole == 'owner' || _currentUserRole == 'admin'))
            const SizedBox(height: 16),

          // Speaker Grid
          if (_speakers.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Icon(
                    Icons.mic,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Speakers (${_speakers.length})',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ],
              ),
            ),
          if (_speakers.isNotEmpty) const SizedBox(height: 12),
          if (_speakers.isNotEmpty)
            SpeakerGridWidget(
              speakers: _speakers,
              currentUserId: _currentUserId,
              onSpeakerTap: _handleSpeakerTap,
            ),

          const SizedBox(height: 16),

          // Audience section with tabs
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: colorScheme.surface,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Tab Bar
                  Container(
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                    ),
                    child: TabBar(
                      controller: _tabController,
                      indicatorColor: colorScheme.primary,
                      labelColor: colorScheme.primary,
                      unselectedLabelColor: colorScheme.onSurfaceVariant,
                      tabs: [
                        Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.people_outline, size: 18),
                              const SizedBox(width: 8),
                              Text('Audience (${_audience.length})'),
                            ],
                          ),
                        ),
                        const Tab(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 18),
                              SizedBox(width: 8),
                              Text('Chat'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Tab Views
                  Expanded(
                    child: TabBarView(
                      controller: _tabController,
                      children: [
                        // Audience List
                        AudienceListWidget(
                          audience: _audience,
                          currentUserId: _currentUserId,
                          onAudienceTap: _handleAudienceTap,
                        ),

                        // Chat (placeholder)
                        _buildChatPlaceholder(colorScheme),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Control Panel
          _buildControlPanel(colorScheme, isSpeaker),
        ],
      ),

      // Gift Animation Overlay
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: GiftAnimationOverlay(
        giftStream: _giftStreamController.stream,
      ),
    );
  }

  Widget _buildInfoChip(ColorScheme colorScheme, IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colorScheme.primary),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatPlaceholder(ColorScheme colorScheme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: colorScheme.onSurfaceVariant.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Text chat coming soon',
            style: TextStyle(
              color: colorScheme.onSurfaceVariant,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlPanel(ColorScheme colorScheme, bool isSpeaker) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Mute button (only for speakers)
            if (isSpeaker)
              _buildControlButton(
                colorScheme,
                icon: _isMuted ? Icons.mic_off : Icons.mic,
                label: _isMuted ? 'Unmute' : 'Mute',
                onPressed: _toggleMute,
                color: _isMuted ? Colors.red : null,
              )
            else
              // Request to speak button (for audience)
              _buildControlButton(
                colorScheme,
                icon: Icons.front_hand,
                label: 'Request',
                onPressed: _handleRequestToSpeak,
                color: Colors.blue,
              ),

            // Gift button
            _buildControlButton(
              colorScheme,
              icon: Icons.card_giftcard,
              label: 'Gift',
              onPressed: _showGiftTray,
              color: Colors.amber,
            ),

            // Leave button
            _buildControlButton(
              colorScheme,
              icon: Icons.call_end,
              label: 'Leave',
              onPressed: () => _handleLeaveRoom(context),
              color: Colors.red,
            ),

            // Settings/More button
            _buildControlButton(
              colorScheme,
              icon: Icons.settings,
              label: 'Settings',
              onPressed: () {
                // TODO: Show audio settings
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton(
    ColorScheme colorScheme, {
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    Color? color,
  }) {
    final buttonColor = color ?? colorScheme.primaryContainer;
    final iconColor =
        color != null ? Colors.white : colorScheme.onPrimaryContainer;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Material(
          color: buttonColor,
          elevation: 2,
          shadowColor: buttonColor.withOpacity(0.3),
          borderRadius: BorderRadius.circular(16),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, size: 24, color: iconColor),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  void _handleSpeakerTap(LiveRoomParticipant speaker) {
    final isOwnerOrAdmin =
        _currentUserRole == 'owner' || _currentUserRole == 'admin';
    final canModerate = isOwnerOrAdmin && speaker.userId != _currentUserId;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // User info header
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor:
                        Theme.of(context).colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person,
                      color: Theme.of(context).colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          speaker.userId.length > 20
                              ? '${speaker.userId.substring(0, 20)}...'
                              : speaker.userId,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          speaker.role == 'owner'
                              ? 'Host'
                              : speaker.role.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // View Profile
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to profile
              },
            ),

            // Mute/Unmute (for admins)
            if (canModerate)
              ListTile(
                leading: Icon(
                  speaker.isMuted ? Icons.mic : Icons.mic_off,
                  color: Colors.orange,
                ),
                title: Text(speaker.isMuted ? 'Unmute' : 'Mute'),
                onTap: () async {
                  Navigator.pop(context);
                  await _handleAdminMute(speaker);
                },
              ),

            // Kick participant (for owner/admin, can't kick owner)
            if (canModerate && speaker.role != 'owner')
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.red),
                title: const Text(
                  'Kick from Room',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _handleKickParticipant(speaker);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _handleAudienceTap(LiveRoomParticipant member) {
    // Show audience member options
    final isOwnerOrAdmin =
        _currentUserRole == 'owner' || _currentUserRole == 'admin';

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('View Profile'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Navigate to profile
              },
            ),

            // Kick participant (for owner/admin)
            if (isOwnerOrAdmin && member.userId != _currentUserId)
              ListTile(
                leading: const Icon(Icons.exit_to_app, color: Colors.red),
                title: const Text(
                  'Kick from Room',
                  style: TextStyle(color: Colors.red),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _handleKickParticipant(member);
                },
              ),
          ],
        ),
      ),
    );
  }

  /// Admin mutes/unmutes a speaker
  Future<void> _handleAdminMute(LiveRoomParticipant speaker) async {
    try {
      debugPrint(
          '\n🔇 Admin ${speaker.isMuted ? "unmuting" : "muting"} speaker: ${speaker.userId}');

      final newMutedState = !speaker.isMuted;

      // Update in Supabase
      await _roomDataSource.toggleMute(
        roomId: widget.room.id,
        userId: speaker.userId,
        mute: newMutedState,
      );

      // If muting, also mute in Zego (remote mute)
      if (newMutedState) {
        // Note: Zego SDK doesn't support remote mute directly
        // The speaker's client should listen to the database change and mute locally
        debugPrint(
            '   ℹ️  Speaker should mute locally based on database update');
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              newMutedState ? 'Speaker muted' : 'Speaker unmuted',
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error toggling mute: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to ${speaker.isMuted ? "unmute" : "mute"} speaker'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Kick participant from room
  Future<void> _handleKickParticipant(LiveRoomParticipant participant) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kick Participant'),
        content: Text(
          'Are you sure you want to kick this user from the room?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Kick'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      debugPrint('\n🚪 Kicking participant: ${participant.userId}');

      // Kick from database
      await _roomDataSource.kickParticipant(
        roomId: widget.room.id,
        userId: participant.userId,
      );

      debugPrint('   ✅ Participant kicked from database');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Participant removed from room'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error kicking participant: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to kick participant: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handle when current user is kicked
  void _handleKicked() {
    debugPrint('\n⚠️  You have been kicked from the room');

    // Leave Zego room immediately
    _leaveRoom();

    // Navigate back and show message
    if (mounted) {
      Navigator.pop(context);

      // Show message after a brief delay to ensure navigation completes
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('You have been removed from the room'),
              backgroundColor: Colors.red,
              duration: Duration(seconds: 4),
            ),
          );
        }
      });
    }
  }

  /// Subscribe to real-time gift updates
  void _subscribeToGifts() {
    _giftsChannel = Supabase.instance.client
        .channel('room_gifts:${widget.room.id}')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'room_gifts',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'room_id',
            value: widget.room.id,
          ),
          callback: (payload) async {
            debugPrint('\n🎁 New gift received in room!');
            try {
              // Fetch full gift details with joins
              final giftData =
                  await Supabase.instance.client.from('room_gifts').select('''
                    *,
                    sender:sender_id (name, photo_url),
                    receiver:receiver_id (name),
                    gift:gift_id (name, image_url, coin_cost, animation_type)
                  ''').eq('id', payload.newRecord['id']).single();

              // Parse to RoomGift
              final roomGift = RoomGift(
                id: giftData['id'] as String,
                roomId: giftData['room_id'] as String,
                senderId: giftData['sender_id'] as String,
                senderName: giftData['sender']?['name'] as String?,
                senderPhotoUrl: giftData['sender']?['photo_url'] as String?,
                receiverId: giftData['receiver_id'] as String,
                receiverName: giftData['receiver']?['name'] as String?,
                giftId: giftData['gift_id'] as String,
                giftName: giftData['gift']?['name'] as String? ?? 'Gift',
                giftImageUrl: giftData['gift']?['image_url'] as String? ?? '',
                coinValue: giftData['coin_value'] as int? ?? 0,
                animationType:
                    giftData['gift']?['animation_type'] as String? ?? 'simple',
                createdAt: DateTime.parse(giftData['created_at'] as String),
              );

              // Add to stream for animation
              _giftStreamController.add(roomGift);

              debugPrint('   ✅ Gift animation triggered');
            } catch (e) {
              debugPrint('   ❌ Error processing gift: $e');
            }
          },
        )
        .subscribe();

    debugPrint('   ✅ Subscribed to gift stream');
  }

  /// Load available gifts and user coin balance
  Future<void> _loadGiftsAndBalance() async {
    try {
      // Load available gifts
      final gifts = await _giftDataSource.getAvailableGifts();

      // Get user coin balance
      final userResponse = await Supabase.instance.client
          .from('users')
          .select('coins')
          .eq('id', _currentUserId!)
          .single();

      if (mounted) {
        setState(() {
          _availableGifts = gifts;
          _userCoins = userResponse['coins'] as int? ?? 0;
        });
        debugPrint(
            '   ✅ Loaded ${_availableGifts.length} gifts, balance: $_userCoins coins');
      }
    } catch (e) {
      debugPrint('   ⚠️  Failed to load gifts: $e');
      // Non-critical, continue without gifts
    }
  }

  /// Show gift tray bottom sheet
  void _showGiftTray() {
    // Get speakers who can receive gifts (excluding current user)
    final recipients = _speakers
        .where((s) => s.userId != _currentUserId)
        .map((s) => s.userId)
        .toList();

    if (recipients.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No speakers available to receive gifts'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Build recipient names map
    final recipientNames = <String, String>{};
    for (final speaker in _speakers) {
      if (speaker.userId != _currentUserId) {
        recipientNames[speaker.userId] = speaker.userName ?? 'User';
      }
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => GiftTrayWidget(
        gifts: _availableGifts,
        recipients: recipients,
        recipientNames: recipientNames,
        userCoins: _userCoins,
        onSendGift: (giftId, recipientId) {
          _handleSendGift(giftId, recipientId);
        },
      ),
    );
  }

  /// Handle sending a gift
  Future<void> _handleSendGift(String giftId, String recipientId) async {
    try {
      debugPrint('\\n🎁 Sending gift: $giftId to $recipientId');

      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Text('Sending gift...'),
              ],
            ),
            duration: Duration(seconds: 2),
          ),
        );
      }

      // Send gift via datasource
      final roomGift = await _giftDataSource.sendGift(
        roomId: widget.room.id,
        senderId: _currentUserId!,
        receiverId: recipientId,
        giftId: giftId,
      );

      debugPrint('   ✅ Gift sent successfully!');

      // Reload balance
      await _loadGiftsAndBalance();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Gift sent to ${roomGift.receiverName ?? "user"}!',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error sending gift: $e');
      if (mounted) {
        String errorMessage = 'Failed to send gift';
        if (e.toString().contains('Insufficient')) {
          errorMessage = 'Insufficient coins';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _handleRequestToSpeak() async {
    try {
      debugPrint('\n🎤 User requesting to speak...');

      // Use the datasource directly for now (could be moved to use case later)
      await _roomDataSource.requestToSpeak(
        roomId: widget.room.id,
        userId: _currentUserId!,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: const [
                Icon(Icons.front_hand, color: Colors.white),
                SizedBox(width: 8),
                Expanded(
                  child: Text('Request sent! Waiting for host approval...'),
                ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error requesting to speak: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to send request: ${e.toString().split(':').last.trim()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  void _handleLeaveRoom(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Room'),
        content: const Text('Are you sure you want to leave this room?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Leave room
              // TODO: Leave Zego room and update Supabase
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'info':
        _showRoomInfo();
        break;
      case 'share':
        // TODO: Share room link
        break;
      case 'end':
        _handleEndRoom();
        break;
    }
  }

  void _showRoomInfo() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Room Information'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _infoRow('Title', widget.room.title),
            _infoRow('Category', widget.room.category),
            _infoRow('Type', widget.room.roomType),
            _infoRow('Max Speakers', widget.room.maxSpeakers.toString()),
            if (widget.room.tags.isNotEmpty)
              _infoRow('Tags', widget.room.tags.join(', ')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }

  void _handleEndRoom() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('End Room'),
        content: const Text(
          'Are you sure you want to end this room? All participants will be removed and the room will be closed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.pop(context); // Close dialog
              await _endRoom();
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('End Room'),
          ),
        ],
      ),
    );
  }

  /// End the room and cleanup
  Future<void> _endRoom() async {
    try {
      debugPrint('\n🛑 Ending room: ${widget.room.id}');

      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Row(
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12),
                Text('Ending room...'),
              ],
            ),
            duration: Duration(seconds: 10),
          ),
        );
      }

      // End room in database
      await _roomDataSource.endRoom(widget.room.id);

      debugPrint('   ✅ Room ended in database');

      // Leave Zego room
      await _leaveRoom();

      // Navigate back
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Room ended successfully'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      debugPrint('❌ Error ending room: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to end room: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}
