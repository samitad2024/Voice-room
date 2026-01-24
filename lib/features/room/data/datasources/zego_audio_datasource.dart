import 'package:flutter/foundation.dart';
import 'package:zego_express_engine/zego_express_engine.dart';
import '../../../../core/constants/zego_config.dart';
import '../../../../core/error/exceptions.dart';

/// Zego Audio Data Source
/// Manages ZegoExpressEngine for real-time audio streaming
abstract class ZegoAudioDataSource {
  Future<void> initEngine();
  Future<void> joinRoom({
    required String roomId,
    required String userId,
    required String userName,
    required String token,
    required bool isSpeaker,
  });
  Future<void> leaveRoom(String roomId);
  Future<void> startPublishing(String streamId);
  Future<void> stopPublishing();
  Future<void> muteMicrophone(bool mute);
  Future<void> muteAllPlayStreams(bool mute);
  Future<void> setAudioQuality(bool isVip);
  void dispose();

  // Event handlers
  void setRoomStateUpdateCallback(
      Function(String roomID, ZegoRoomState state) callback);
  void setPlayerStateUpdateCallback(
      Function(String streamID, ZegoPlayerState state) callback);
  void setPublisherStateUpdateCallback(
      Function(String streamID, ZegoPublisherState state) callback);
  void setNetworkQualityCallback(
      Function(String userID, ZegoStreamQualityLevel quality) callback);
}

class ZegoAudioDataSourceImpl implements ZegoAudioDataSource {
  ZegoExpressEngine? _engine;
  bool _isInitialized = false;

  @override
  Future<void> initEngine() async {
    if (_isInitialized) {
      debugPrint('ℹ️  Zego Engine already initialized, skipping...');
      return;
    }

    try {
      debugPrint('\n🎬 ===== ZEGO ENGINE INITIALIZATION =====');

      // Check if AppID is configured
      if (ZegoConfig.appID == 0) {
        debugPrint('❌ ERROR: Zego AppID is 0 (not configured)');
        debugPrint('💡 Solution: Set ZegoConfig.appID in zego_config.dart');
        throw ServerException(
          'Zego AppID not configured. Please set ZegoConfig.appID',
        );
      }

      debugPrint('✅ App ID verified: ${ZegoConfig.appID}');

      // Create engine profile
      // Use StandardVoiceCall for voice chat rooms
      debugPrint(
          '🔧 Creating engine profile with StandardVoiceCall scenario...');
      final profile = ZegoEngineProfile(
        ZegoConfig.appID,
        ZegoScenario
            .StandardVoiceCall, // Standard voice call scenario for voice chat rooms
      );

      // Initialize engine
      debugPrint('⚙️  Initializing Zego Express Engine...');
      await ZegoExpressEngine.createEngineWithProfile(profile);
      _engine = ZegoExpressEngine.instance;
      debugPrint('✅ Engine instance created');

      // Configure audio settings for voice chat
      debugPrint('🎛️  Configuring audio settings...');
      await _engine!.enableHardwareEncoder(false);
      debugPrint('   ✓ Hardware encoder: disabled');

      // Enable noise suppression, echo cancellation, and auto gain control
      await _engine!.enableAEC(true);
      debugPrint('   ✓ Echo cancellation (AEC): enabled');

      await _engine!.enableAGC(true);
      debugPrint('   ✓ Auto gain control (AGC): enabled');

      await _engine!.enableANS(true);
      debugPrint('   ✓ Noise suppression (ANS): enabled');

      // Set audio quality to standard by default (48kbps for voice)
      await _engine!.setAudioConfig(
          ZegoAudioConfig.preset(ZegoAudioConfigPreset.StandardQuality));
      debugPrint('   ✓ Audio quality: Standard (48kbps)');

      // Setup stream update callback to auto-play incoming audio
      debugPrint('🔊 Setting up auto-play for incoming audio streams...');
      ZegoExpressEngine.onRoomStreamUpdate =
          (roomID, updateType, streamList, extendedData) {
        debugPrint('\n📡 Stream Update in Room: $roomID');
        debugPrint(
            '   Update Type: ${updateType == ZegoUpdateType.Add ? "ADD" : "REMOVE"}');
        debugPrint('   Streams: ${streamList.length}');

        if (updateType == ZegoUpdateType.Add) {
          // Auto-play all new streams (so audience can hear speakers)
          for (var stream in streamList) {
            debugPrint('   🎵 Auto-playing stream: ${stream.streamID}');
            ZegoExpressEngine.instance.startPlayingStream(stream.streamID);
          }
        } else {
          // Stop playing removed streams
          for (var stream in streamList) {
            debugPrint('   🛑 Stopping stream: ${stream.streamID}');
            ZegoExpressEngine.instance.stopPlayingStream(stream.streamID);
          }
        }
      };
      debugPrint('   ✓ Auto-play enabled for all incoming streams');

      _isInitialized = true;
      debugPrint('\n✅ SUCCESS: Zego Engine initialized successfully!');
      debugPrint('=========================================\n');
    } catch (e, stackTrace) {
      debugPrint('\n❌ CRITICAL ERROR: Failed to initialize Zego Engine');
      debugPrint('Error Type: ${e.runtimeType}');
      debugPrint('Error Message: $e');
      debugPrint('\n📋 Stack Trace:');
      debugPrint(stackTrace.toString());
      debugPrint('\n💡 Common Solutions:');
      debugPrint('   1. Check your internet connection');
      debugPrint('   2. Verify Zego AppID is correct in zego_config.dart');
      debugPrint('   3. Ensure Zego SDK version is compatible');
      debugPrint('   4. Check device permissions (microphone access)');
      debugPrint('=========================================\n');
      throw ServerException('Failed to initialize Zego Engine: $e');
    }
  }

  @override
  Future<void> joinRoom({
    required String roomId,
    required String userId,
    required String userName,
    required String token,
    required bool isSpeaker,
  }) async {
    try {
      debugPrint('\n🚪 ===== JOINING ROOM =====');

      if (!_isInitialized || _engine == null) {
        debugPrint('⚠️  Engine not initialized, initializing now...');
        await initEngine();
      }

      // Validate inputs
      if (roomId.isEmpty) {
        throw ServerException('Room ID cannot be empty');
      }
      if (userId.isEmpty) {
        throw ServerException('User ID cannot be empty');
      }
      if (token.isEmpty) {
        throw ServerException('Authentication token cannot be empty');
      }

      debugPrint('📋 Room Join Details:');
      debugPrint('   🏠 Room ID: $roomId');
      debugPrint('   👤 User ID: $userId');
      debugPrint('   📝 User Name: $userName');
      debugPrint('   🎙️  Role: ${isSpeaker ? "Speaker" : "Listener"}');
      debugPrint(
          '   🔐 Token: ${token.length > 40 ? "${token.substring(0, 20)}...${token.substring(token.length - 20)}" : token} (${token.length} chars)');

      // Create user info
      final user = ZegoUser(userId, userName);

      // Configure room settings
      final roomConfig = ZegoRoomConfig(
        0, // Max member count (0 = no limit up to Zego's tier limit)
        true, // Is user status notify enabled
        token, // Token from server
      );

      // Join the room
      debugPrint('\n🔄 Attempting to join room...');
      await _engine!.loginRoom(roomId, user, config: roomConfig);
      debugPrint('✅ SUCCESS: Joined room successfully!');

      // If speaker, start publishing
      if (isSpeaker) {
        final streamId = '${roomId}_${userId}_main';
        debugPrint('\n🎤 User is a speaker, starting audio stream...');
        debugPrint('   Stream ID: $streamId');
        await startPublishing(streamId);
      } else {
        debugPrint('👂 User is a listener (audience)');
      }

      debugPrint('=============================\n');
    } catch (e, stackTrace) {
      debugPrint('\n❌ CRITICAL ERROR: Failed to join room');
      debugPrint('Room ID: $roomId');
      debugPrint('User ID: $userId');
      debugPrint('Error Type: ${e.runtimeType}');
      debugPrint('Error Message: $e');

      // Provide helpful error explanations
      if (e.toString().contains('50119') ||
          e.toString().contains('token auth err')) {
        debugPrint('\n🔍 Error Analysis: TOKEN AUTHENTICATION FAILED');
        debugPrint('💡 Possible Causes:');
        debugPrint('   1. Token expired (tokens are valid for 24 hours)');
        debugPrint('   2. Token generated for wrong room/user ID');
        debugPrint('   3. Edge Function not deployed or outdated');
        debugPrint('   4. Server secret mismatch in Edge Function');
        debugPrint('\n🛠️  Solutions:');
        debugPrint('   1. Generate a new token by rejoining the room');
        debugPrint(
            '   2. Verify Edge Function is deployed: supabase/functions/generate-zego-token');
        debugPrint(
            '   3. Check Zego Console for correct App ID and Server Secret');
      } else if (e.toString().contains('network')) {
        debugPrint('\n🔍 Error Analysis: NETWORK CONNECTION ISSUE');
        debugPrint('💡 Solutions:');
        debugPrint('   1. Check your internet connection');
        debugPrint('   2. Try switching networks (WiFi/Mobile data)');
        debugPrint('   3. Check firewall settings');
      } else if (e.toString().contains('permission')) {
        debugPrint('\n🔍 Error Analysis: PERMISSION DENIED');
        debugPrint('💡 Solutions:');
        debugPrint('   1. Grant microphone permissions in device settings');
        debugPrint('   2. Restart the app after granting permissions');
      }

      debugPrint('\n📋 Stack Trace:');
      debugPrint(stackTrace.toString());
      debugPrint('=============================\n');

      throw ServerException('Failed to join room: $e');
    }
  }

  @override
  Future<void> leaveRoom(String roomId) async {
    try {
      debugPrint('\n🚪 ===== LEAVING ROOM =====');
      debugPrint('   Room ID: $roomId');

      // Stop publishing if active
      debugPrint('🛑 Stopping audio stream...');
      await stopPublishing();
      debugPrint('   ✓ Audio stream stopped');

      // Leave the room
      debugPrint('👋 Logging out of room...');
      await _engine?.logoutRoom(roomId);
      debugPrint('✅ SUCCESS: Left room successfully');
      debugPrint('==========================\n');
    } catch (e, stackTrace) {
      debugPrint('\n❌ ERROR: Failed to leave room cleanly');
      debugPrint('Room ID: $roomId');
      debugPrint('Error: $e');
      debugPrint('Note: This may be normal if already disconnected');
      debugPrint('Stack Trace:');
      debugPrint(stackTrace.toString());
      debugPrint('==========================\n');
      throw ServerException('Failed to leave room: $e');
    }
  }

  @override
  Future<void> startPublishing(String streamId) async {
    try {
      debugPrint('\n🎤 ===== STARTING AUDIO STREAM =====');
      debugPrint('   Stream ID: $streamId');

      if (_engine == null) {
        throw ServerException('Zego engine not initialized');
      }

      debugPrint('🔊 Publishing audio stream...');
      await _engine!.startPublishingStream(streamId);
      debugPrint('✅ SUCCESS: Audio stream started');
      debugPrint('====================================\n');
    } catch (e, stackTrace) {
      debugPrint('\n❌ CRITICAL ERROR: Failed to start audio stream');
      debugPrint('Stream ID: $streamId');
      debugPrint('Error: $e');
      debugPrint('\n💡 Common Solutions:');
      debugPrint('   1. Check microphone permissions');
      debugPrint('   2. Ensure you\'re logged into a room first');
      debugPrint('   3. Verify your role allows publishing (speaker/host)');
      debugPrint('   4. Check if another app is using the microphone');
      debugPrint('\nStack Trace:');
      debugPrint(stackTrace.toString());
      debugPrint('====================================\n');
      throw ServerException('Failed to start publishing: $e');
    }
  }

  @override
  Future<void> stopPublishing() async {
    try {
      debugPrint('🛑 Stopping audio stream...');
      await _engine?.stopPublishingStream();
      debugPrint('✅ Audio stream stopped successfully');
    } catch (e) {
      debugPrint('⚠️  Warning: Failed to stop publishing: $e');
      debugPrint('(This is often normal if not currently publishing)');
      // Don't throw - stopping an inactive stream is not critical
      // throw ServerException('Failed to stop publishing: $e');
    }
  }

  @override
  Future<void> muteMicrophone(bool mute) async {
    try {
      debugPrint('🎙️  ${mute ? "Muting" : "Unmuting"} microphone...');
      await _engine?.muteMicrophone(mute);
      debugPrint('✅ Microphone ${mute ? "muted" : "unmuted"} successfully');
    } catch (e) {
      debugPrint('❌ ERROR: Failed to ${mute ? "mute" : "unmute"} microphone');
      debugPrint('Error: $e');
      debugPrint('💡 Solution: Check microphone permissions');
      throw ServerException('Failed to mute microphone: $e');
    }
  }

  @override
  Future<void> muteAllPlayStreams(bool mute) async {
    try {
      await _engine?.muteAllPlayStreamAudio(mute);
    } catch (e) {
      throw ServerException('Failed to mute play streams: $e');
    }
  }

  @override
  Future<void> setAudioQuality(bool isVip) async {
    try {
      final preset = isVip
          ? ZegoAudioConfigPreset.HighQuality
          : ZegoAudioConfigPreset.StandardQuality;
      await _engine?.setAudioConfig(ZegoAudioConfig.preset(preset));
    } catch (e) {
      throw ServerException('Failed to set audio quality: $e');
    }
  }

  @override
  void setRoomStateUpdateCallback(
    Function(String roomID, ZegoRoomState state) callback,
  ) {
    debugPrint('📡 Registering room state update callback...');
    ZegoExpressEngine.onRoomStateUpdate =
        (roomID, state, errorCode, extendedData) {
      debugPrint('\n📊 ROOM STATE UPDATE:');
      debugPrint('   Room: $roomID');
      debugPrint('   State: $state');

      if (errorCode != 0) {
        debugPrint('   ⚠️  Error Code: $errorCode');
        debugPrint('   Extended Data: $extendedData');

        // Explain common error codes
        switch (errorCode) {
          case 1102016:
            debugPrint('   🔍 Analysis: Liveroom error (likely auth failure)');
            break;
          case 1000002:
            debugPrint('   🔍 Analysis: Not logged in (call loginRoom first)');
            break;
          case 1100012:
            debugPrint('   🔍 Analysis: Socket is idle (network disconnected)');
            break;
          default:
            debugPrint('   🔍 Analysis: Unknown error $errorCode');
        }
      } else {
        debugPrint('   ✅ No errors');
      }
      debugPrint('');

      callback(roomID, state);
    };
  }

  @override
  void setPlayerStateUpdateCallback(
    Function(String streamID, ZegoPlayerState state) callback,
  ) {
    ZegoExpressEngine.onPlayerStateUpdate =
        (streamID, state, errorCode, extendedData) {
      callback(streamID, state);
    };
  }

  @override
  void setPublisherStateUpdateCallback(
    Function(String streamID, ZegoPublisherState state) callback,
  ) {
    ZegoExpressEngine.onPublisherStateUpdate =
        (streamID, state, errorCode, extendedData) {
      callback(streamID, state);
    };
  }

  @override
  void setNetworkQualityCallback(
    Function(String userID, ZegoStreamQualityLevel quality) callback,
  ) {
    ZegoExpressEngine.onNetworkQuality =
        (userID, upstreamQuality, downstreamQuality) {
      callback(userID, downstreamQuality);
    };
  }

  @override
  void dispose() {
    ZegoExpressEngine.destroyEngine();
    _isInitialized = false;
    _engine = null;
  }
}
