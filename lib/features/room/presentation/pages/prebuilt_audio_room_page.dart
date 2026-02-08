import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';
import '../../../../core/constants/zego_config.dart';
import '../../domain/entities/room.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

/// Prebuilt Audio Room Page
/// Uses ZegoCloud's ready-made Prebuilt UIKit for voice rooms
class PrebuiltAudioRoomPage extends StatefulWidget {
  final Room room;
  final bool isHost;

  const PrebuiltAudioRoomPage({
    super.key,
    required this.room,
    this.isHost = false,
  });

  @override
  State<PrebuiltAudioRoomPage> createState() => _PrebuiltAudioRoomPageState();
}

class _PrebuiltAudioRoomPageState extends State<PrebuiltAudioRoomPage> {
  String? _token;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _generateToken();
  }

  Future<void> _generateToken() async {
    try {
      final authState = context.read<AuthBloc>().state;
      if (authState is! AuthAuthenticated) {
        throw Exception('User not authenticated');
      }

      final userId = authState.user.uid;

      debugPrint('🔑 Requesting Zego token...');
      debugPrint('   User ID: $userId');
      debugPrint('   Room ID: ${widget.room.id}');

      final response = await Supabase.instance.client.functions.invoke(
        'generate-zego-token',
        body: {
          'userId': userId,
          'roomId': widget.room.id,
        },
      );

      if (response.status != 200) {
        throw Exception('Token generation failed: ${response.status}');
      }

      final responseData = response.data as Map<String, dynamic>?;
      if (responseData == null || responseData['token'] == null) {
        throw Exception('Invalid token response');
      }

      final token = responseData['token'] as String;
      debugPrint('✅ Token received: ${token.length} chars');

      setState(() {
        _token = token;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('❌ Token generation error: $e');
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate token: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.room.title),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Connecting to voice room...'),
            ],
          ),
        ),
      );
    }

    if (_errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          title: Text(widget.room.title),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Connection Failed',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                    _errorMessage = null;
                  });
                  _generateToken();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final authState = context.read<AuthBloc>().state;
    if (authState is! AuthAuthenticated) {
      return const Scaffold(
        body: Center(child: Text('Please log in first')),
      );
    }

    final userId = authState.user.uid;
    final userName = authState.user.name ?? authState.user.email ?? 'User';

    debugPrint(
        '\n╔══════════════════════════════════════════════════════════════');
    debugPrint('║ 🎵 LAUNCHING PREBUILT AUDIO ROOM');
    debugPrint(
        '╠══════════════════════════════════════════════════════════════');
    debugPrint('║ Room: ${widget.room.title}');
    debugPrint('║ Room ID: ${widget.room.id}');
    debugPrint('║ User: $userName ($userId)');
    debugPrint('║ Role: ${widget.isHost ? "Host" : "Audience"}');
    debugPrint('║ App ID: ${ZegoConfig.appID}');
    debugPrint(
        '╚══════════════════════════════════════════════════════════════');

    return SafeArea(
      child: ZegoUIKitPrebuiltLiveAudioRoom(
        appID: ZegoConfig.appID,
        appSign: ZegoConfig.appSign,
        userID: userId,
        userName: userName,
        roomID: widget.room.id,
        token: _token!,

        // Configure for host or audience
        config: (widget.isHost
            ? ZegoUIKitPrebuiltLiveAudioRoomConfig.host()
            : ZegoUIKitPrebuiltLiveAudioRoomConfig.audience())
          ..seat = (widget.isHost
              ? ZegoLiveAudioRoomSeatConfig(
                  // Host configuration
                  showSoundWaveInAudioMode: true,
                  takeIndexWhenJoining: 0, // Host takes first seat
                )
              : ZegoLiveAudioRoomSeatConfig(
                  // Audience configuration
                  showSoundWaveInAudioMode: true,
                  takeIndexWhenJoining: -1, // Audience starts without seat
                ))
          ..background = Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                ],
              ),
            ),
          ),
        events: ZegoUIKitPrebuiltLiveAudioRoomEvents(
          onLeaveConfirmation: (event, defaultAction) async {
            debugPrint('👋 Leaving audio room...');
            return defaultAction();
          },
        ),
      ),
    );
  }
}
