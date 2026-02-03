import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/get_current_user.dart';
import '../../features/auth/domain/usecases/login_with_email.dart';
import '../../features/auth/domain/usecases/login_with_google.dart';
import '../../features/auth/domain/usecases/login_with_phone.dart';
import '../../features/auth/domain/usecases/logout.dart';
import '../../features/auth/domain/usecases/register_with_email.dart';
import '../../features/auth/domain/usecases/verify_phone_code.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/room/data/datasources/room_remote_datasource.dart';
import '../../features/room/data/datasources/zego_audio_datasource.dart';
import '../../features/room/data/repositories/room_repository_impl.dart';
import '../../features/room/domain/repositories/room_repository.dart';
import '../../features/room/domain/usecases/create_room.dart';
import '../../features/room/domain/usecases/get_live_rooms.dart';
import '../../features/room/domain/usecases/join_room.dart';
import '../../features/room/domain/usecases/request_to_speak.dart';
import '../../features/room/domain/usecases/get_speaker_requests.dart';
import '../../features/room/domain/usecases/approve_speaker_request.dart';
import '../../features/room/domain/usecases/reject_speaker_request.dart';
import '../../features/room/presentation/bloc/room_bloc.dart';
import '../network/network_info.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // External Dependencies
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);

  // Supabase client - initialized in main.dart before this function
  sl.registerLazySingleton(() => Supabase.instance.client);

  sl.registerLazySingleton(() => Connectivity());

  // Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  // Features - Auth
  _initAuth();

  // Features - Room
  _initRoom();
}

void _initAuth() {
  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(supabase: sl()),
  );

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetCurrentUser(sl()));
  sl.registerLazySingleton(() => LoginWithPhone(sl()));
  sl.registerLazySingleton(() => VerifyPhoneCode(sl()));
  sl.registerLazySingleton(() => LoginWithGoogle(sl()));
  sl.registerLazySingleton(() => LoginWithEmail(sl()));
  sl.registerLazySingleton(() => RegisterWithEmail(sl()));
  sl.registerLazySingleton(() => Logout(sl()));

  // Bloc
  sl.registerFactory(
    () => AuthBloc(
      getCurrentUser: sl(),
      loginWithPhone: sl(),
      verifyPhoneCode: sl(),
      loginWithGoogle: sl(),
      loginWithEmail: sl(),
      registerWithEmail: sl(),
      logout: sl(),
    ),
  );
}

void _initRoom() {
  // Data sources
  sl.registerLazySingleton<RoomRemoteDataSource>(
    () => RoomRemoteDataSourceImpl(supabase: sl()),
  );

  // Zego Audio Engine for Express Engine
  sl.registerLazySingleton<ZegoAudioDataSource>(
    () => ZegoAudioDataSourceImpl(),
  );

  // Repository
  sl.registerLazySingleton<RoomRepository>(
    () => RoomRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Use cases
  sl.registerLazySingleton(() => GetLiveRooms(sl()));
  sl.registerLazySingleton(() => CreateRoom(sl()));
  sl.registerLazySingleton(() => JoinRoom(sl()));
  sl.registerLazySingleton(() => RequestToSpeak(sl()));
  sl.registerLazySingleton(() => GetSpeakerRequests(sl()));
  sl.registerLazySingleton(() => ApproveSpeakerRequest(sl()));
  sl.registerLazySingleton(() => RejectSpeakerRequest(sl()));

  // Bloc
  sl.registerFactory(
    () => RoomBloc(
      getLiveRooms: sl(),
      createRoom: sl(),
      joinRoom: sl(),
    ),
  );
}
