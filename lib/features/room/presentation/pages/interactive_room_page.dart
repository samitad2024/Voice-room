import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../data/datasources/zego_audio_datasource.dart';
import '../../domain/entities/room.dart';
import '../../domain/entities/live_room_participant.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../widgets/speaker_grid_widget.dart';
import '../widgets/audience_list_widget.dart';

/// Interactive Voice Room Page
/// Features: Speaker grid, audience list, real-time updates, audio controls
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
  bool _isMuted = false;
  String? _currentUserId;
  String _currentUserRole = 'audience';

  // Mock data - TODO: Replace with real Supabase Realtime subscriptions
  final List<LiveRoomParticipant> _speakers = [];
  final List<LiveRoomParticipant> _audience = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);

    // Get current user
    final authState = context.read<AuthBloc>().state;
    if (authState is AuthAuthenticated) {
      _currentUserId = authState.user.uid;
      _currentUserRole =
          authState.user.uid == widget.room.ownerId ? 'owner' : 'audience';

      // Add mock participants for demo
      _addMockParticipants();
    }

    // TODO: Subscribe to Supabase Realtime for participant updates

    _zego = di.sl<ZegoAudioDataSource>();
    _initZego();
  }

  Future<void> _initZego() async {
    try {
      debugPrint('\n🎵 ===== INITIALIZING VOICE CHAT =====');
      debugPrint('Room: ${widget.room.title} (${widget.room.id})');

      // 1. Initialize Engine
      debugPrint('\nStep 1: Initializing Zego Engine...');
      await _zego.initEngine();

      // 2. Set Callbacks
      debugPrint('\nStep 2: Setting up connection callbacks...');
      _zego.setRoomStateUpdateCallback((roomID, state) {
        if (!mounted) return;

        debugPrint('\n📡 CONNECTION STATE CHANGED:');
        debugPrint('   Room: $roomID');
        debugPrint('   New State: $state');

        // Handle room state changes (disconnected, connecting, connected)
        if (state == ZegoRoomState.Connected) {
          debugPrint('   🎉 STATUS: Successfully connected to voice chat!');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Connected to voice chat',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
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
                  onPressed: () {
                    debugPrint('🔄 User requested reconnection...');
                    _initZego();
                  },
                ),
              ),
            );
          }
        } else if (state == ZegoRoomState.Connecting) {
          debugPrint('   🔄 STATUS: Connecting to voice chat...');
        }
      });

      // 3. Get Token & Join
      debugPrint('\nStep 3: Authenticating user...');
      if (_currentUserId == null) {
        throw Exception('User ID is null. Please login first.');
      }

      debugPrint('   Requesting authentication token from server...');
      debugPrint('   User ID: $_currentUserId');
      debugPrint('   Room ID: ${widget.room.id}');

      final response = await Supabase.instance.client.functions.invoke(
        'generate-zego-token',
        body: {
          'userId': _currentUserId,
          'roomId': widget.room.id,
        },
      );

      debugPrint('   Server Response Status: ${response.status}');

      if (response.status != 200) {
        debugPrint(
            '   ❌ Token generation failed with status ${response.status}');
        throw Exception(
            'Token generation failed: ${response.status}\nPlease ensure Edge Function is deployed.');
      }

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null || responseData['token'] == null) {
        debugPrint('   ❌ Invalid token response: ${response.data}');
        throw Exception('Invalid token response: ${response.data}');
      }

      final token = responseData['token'] as String;
      debugPrint('   ✅ Authentication token received');
      debugPrint('   Token length: ${token.length} characters');

      final authState = context.read<AuthBloc>().state;
      final userName = authState is AuthAuthenticated
          ? (authState.user.name ?? 'User')
          : 'Guest';

      final isHost = _currentUserRole == 'owner';
      debugPrint('\nStep 4: Joining voice room...');
      debugPrint('   User Name: $userName');
      debugPrint(
          '   Role: ${isHost ? "Host (Speaker)" : "Audience (Listener)"}');

      await _zego.joinRoom(
        roomId: widget.room.id,
        userId: _currentUserId!,
        userName: userName,
        token: token,
        isSpeaker: isHost,
      );

      debugPrint('\n✅ SUCCESS: Voice chat initialization complete!');
      debugPrint('=========================================\n');
    } catch (e, stackTrace) {
      debugPrint('\n❌❌❌ CRITICAL ERROR: Voice chat initialization failed ❌❌❌');
      debugPrint('Error Type: ${e.runtimeType}');
      debugPrint('Error Message: $e');

      // Provide user-friendly error explanation
      String userMessage = 'Voice Chat Error';
      String detailMessage = e.toString();

      if (e.toString().contains('50119') ||
          e.toString().contains('token auth')) {
        debugPrint('\n🔍 ERROR CATEGORY: Authentication Failure');
        userMessage = 'Authentication Failed';
        detailMessage =
            'Unable to authenticate with voice server. Please try again or contact support.';
        debugPrint(
            '💡 User Action: Try rejoining or check Edge Function deployment');
      } else if (e.toString().contains('network') ||
          e.toString().contains('connection')) {
        debugPrint('\n🔍 ERROR CATEGORY: Network Connection Issue');
        userMessage = 'Connection Failed';
        detailMessage = 'Please check your internet connection and try again.';
        debugPrint('💡 User Action: Check network connectivity');
      } else if (e.toString().contains('permission')) {
        debugPrint('\n🔍 ERROR CATEGORY: Permission Denied');
        userMessage = 'Microphone Access Denied';
        detailMessage =
            'Please enable microphone permissions in your device settings.';
        debugPrint('💡 User Action: Grant microphone permissions');
      } else if (e.toString().contains('Token generation failed')) {
        debugPrint('\n🔍 ERROR CATEGORY: Server Configuration Issue');
        userMessage = 'Server Error';
        detailMessage =
            'Voice service is temporarily unavailable. Please try again later.';
        debugPrint('💡 Admin Action: Deploy or check Edge Function');
      } else if (e.toString().contains('User ID is null')) {
        debugPrint('\n🔍 ERROR CATEGORY: User Not Logged In');
        userMessage = 'Please Login First';
        detailMessage = 'You must be logged in to join voice chat.';
        debugPrint('💡 User Action: Login to account');
      }

      debugPrint('\n💬 User-Facing Message:');
      debugPrint('   Title: $userMessage');
      debugPrint('   Details: $detailMessage');

      debugPrint('\n📋 Full Stack Trace:');
      debugPrint(stackTrace.toString());
      debugPrint('=========================================\n');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.error, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        userMessage,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  detailMessage,
                  style: const TextStyle(fontSize: 14),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade700,
            duration: const Duration(seconds: 8),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: () {
                debugPrint('🔄 User initiated retry...');
                _initZego();
              },
            ),
          ),
        );
      }
    }
  }

  void _addMockParticipants() {
    // Add owner as speaker
    _speakers.add(LiveRoomParticipant(
      roomId: widget.room.id,
      userId: widget.room.ownerId,
      role: 'owner',
      networkQuality: 'excellent',
      lastSeen: DateTime.now(),
    ));

    // Add some mock speakers
    for (int i = 0; i < 4; i++) {
      _speakers.add(LiveRoomParticipant(
        roomId: widget.room.id,
        userId: 'speaker_$i',
        role: i == 0 ? 'admin' : 'speaker',
        isMuted: i % 3 == 0,
        networkQuality: i % 2 == 0 ? 'good' : 'excellent',
        lastSeen: DateTime.now(),
      ));
    }

    // Add mock audience
    for (int i = 0; i < 15; i++) {
      _audience.add(LiveRoomParticipant(
        roomId: widget.room.id,
        userId: 'audience_$i',
        isOnline: i % 4 != 0,
        lastSeen: DateTime.now().subtract(Duration(minutes: i)),
      ));
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _zego.leaveRoom(widget.room.id);
    // TODO: cleanup Realtime subscriptions
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isOwnerOrAdmin =
        _currentUserRole == 'owner' || _currentUserRole == 'admin';
    final isSpeaker = _speakers.any((s) => s.userId == _currentUserId);

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
                onPressed: () {
                  setState(() => _isMuted = !_isMuted);
                  // TODO: Call Zego muteMicrophone
                },
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
    // TODO: Show speaker actions (view profile, mute if admin, etc.)
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
            if (_currentUserRole == 'owner' || _currentUserRole == 'admin')
              ListTile(
                leading: Icon(
                  speaker.isMuted ? Icons.mic : Icons.mic_off,
                  color: Colors.orange,
                ),
                title: Text(speaker.isMuted ? 'Unmute' : 'Mute'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Toggle mute via Supabase + Zego
                },
              ),
          ],
        ),
      ),
    );
  }

  void _handleAudienceTap(LiveRoomParticipant member) {
    // TODO: Show audience member profile
  }

  void _handleRequestToSpeak() {
    // TODO: Insert speaker request into Supabase
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Request sent! Waiting for approval...'),
        duration: Duration(seconds: 2),
      ),
    );
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
          'Are you sure you want to end this room? All participants will be removed.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Leave room page
              // TODO: End room in Supabase, kick all participants
            },
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('End Room'),
          ),
        ],
      ),
    );
  }
}
