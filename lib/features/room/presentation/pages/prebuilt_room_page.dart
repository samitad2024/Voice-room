import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:zego_uikit_prebuilt_live_audio_room/zego_uikit_prebuilt_live_audio_room.dart';
import '../../../../core/constants/zego_config.dart';
import '../../../../core/di/injection_container.dart' as di;
import '../../data/datasources/room_realtime_service.dart';
import '../../data/datasources/room_remote_datasource.dart';
import '../../domain/entities/room.dart';
import '../../domain/entities/live_room_participant.dart';

/// Prebuilt Voice Room Page using ZegoCloud Prebuilt Live Audio Room UIKit v3.16+
/// Simple implementation with default UI
class PrebuiltRoomPage extends StatefulWidget {
  final Room room;
  final String userId;
  final String userName;
  final bool isHost;

  const PrebuiltRoomPage({
    super.key,
    required this.room,
    required this.userId,
    required this.userName,
    required this.isHost,
  });

  @override
  State<PrebuiltRoomPage> createState() => _PrebuiltRoomPageState();
}

class _PrebuiltRoomPageState extends State<PrebuiltRoomPage> {
  late final RoomRealtimeService _realtimeService;
  late final RoomRemoteDataSource _roomDataSource;

  List<Map<String, dynamic>> _speakerRequests = [];
  StreamSubscription<List<LiveRoomParticipant>>? _participantsSubscription;
  StreamSubscription<List<Map<String, dynamic>>>? _speakerRequestsSubscription;

  @override
  void initState() {
    super.initState();
    _realtimeService = RoomRealtimeService(supabase: Supabase.instance.client);
    _roomDataSource = di.sl<RoomRemoteDataSource>();
    _initializeRoom();
  }

  Future<void> _initializeRoom() async {
    try {
      debugPrint('\n🚀 Initializing Prebuilt Room...');
      debugPrint('   Room: ${widget.room.title}');
      debugPrint('   User: ${widget.userName}');
      debugPrint('   IsHost: ${widget.isHost}');

      // Subscribe to realtime participants
      await _realtimeService.subscribeToRoom(widget.room.id);

      _participantsSubscription = _realtimeService.participantsStream.listen(
        (participants) {
          debugPrint('   👥 Participants: ${participants.length}');
        },
      );

      // Subscribe to speaker requests (for owners/admins)
      if (widget.isHost) {
        _speakerRequestsSubscription =
            _realtimeService.speakerRequestsStream.listen(
          (requests) {
            if (mounted) {
              setState(() => _speakerRequests = requests);
              debugPrint('   🔔 Speaker requests: ${requests.length}');
            }
          },
        );
      }

      debugPrint('✅ Room initialized!');
    } catch (e) {
      debugPrint('❌ Failed to initialize: $e');
    }
  }

  Future<void> _handleLeaveRoom() async {
    try {
      await _roomDataSource.leaveRoom(
        roomId: widget.room.id,
        userId: widget.userId,
      );
      await _realtimeService.unsubscribe();
    } catch (e) {
      debugPrint('❌ Error leaving: $e');
    }
  }

  @override
  void dispose() {
    _participantsSubscription?.cancel();
    _speakerRequestsSubscription?.cancel();
    _realtimeService.dispose();
    _handleLeaveRoom();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        children: [
          // Main Prebuilt Room UI
          ZegoUIKitPrebuiltLiveAudioRoom(
            appID: ZegoConfig.appID,
            appSign: ZegoConfig.appSign,
            userID: widget.userId,
            userName: widget.userName,
            roomID: widget.room.id,
            config: widget.isHost
                ? ZegoUIKitPrebuiltLiveAudioRoomConfig.host()
                : ZegoUIKitPrebuiltLiveAudioRoomConfig.audience(),
            events: ZegoUIKitPrebuiltLiveAudioRoomEvents(
              onLeaveConfirmation: (event, defaultAction) async {
                final shouldLeave = await showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor: Colors.grey[900],
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          title: const Text(
                            'Leave Room',
                            style: TextStyle(color: Colors.white),
                          ),
                          content: const Text(
                            'Are you sure you want to leave?',
                            style: TextStyle(color: Colors.white70),
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(context).pop(false),
                              child: const Text('Cancel'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.of(context).pop(true),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Leave'),
                            ),
                          ],
                        );
                      },
                    ) ??
                    false;

                if (shouldLeave) {
                  await _handleLeaveRoom();
                }
                return shouldLeave;
              },
            ),
          ),

          // Speaker Requests Widget (for owners/admins)
          if (widget.isHost && _speakerRequests.isNotEmpty)
            Positioned(
              top: 80,
              right: 16,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.notification_important,
                          color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        '${_speakerRequests.length} request${_speakerRequests.length > 1 ? 's' : ''}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
