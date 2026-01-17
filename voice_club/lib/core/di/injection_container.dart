import 'package:get_it/get_it.dart';
import '../../data/datasources/mock_firebase_service.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../data/repositories/room_repository_impl.dart';
import '../../data/repositories/gift_repository_impl.dart';
import '../../data/repositories/wallet_repository_impl.dart';
import '../../data/repositories/notification_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/room_repository.dart';
import '../../domain/repositories/gift_repository.dart';
import '../../domain/repositories/wallet_repository.dart';
import '../../domain/repositories/notification_repository.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/get_active_rooms_usecase.dart';
import '../../domain/usecases/join_room_usecase.dart';
import '../../presentation/auth/bloc/auth_bloc.dart';
import '../../presentation/home/bloc/home_bloc.dart';
import '../../presentation/room/bloc/room_bloc.dart';
import '../../presentation/wallet/bloc/wallet_bloc.dart';

final sl = GetIt.instance;

Future<void> initializeDependencies() async {
  // Data Sources
  sl.registerLazySingleton<MockFirebaseService>(() => MockFirebaseService());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));

  sl.registerLazySingleton<RoomRepository>(() => RoomRepositoryImpl(sl()));

  sl.registerLazySingleton<GiftRepository>(
    () => GiftRepositoryImpl(firebaseService: sl()),
  );

  sl.registerLazySingleton<WalletRepository>(
    () => WalletRepositoryImpl(firebaseService: sl()),
  );

  sl.registerLazySingleton<NotificationRepository>(
    () => NotificationRepositoryImpl(firebaseService: sl()),
  );

  // Use Cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => GetActiveRoomsUseCase(sl()));
  sl.registerLazySingleton(() => JoinRoomUseCase(sl()));

  // BLoC
  sl.registerFactory(() => AuthBloc(loginUseCase: sl(), authRepository: sl()));

  sl.registerFactory(
    () => HomeBloc(getActiveRoomsUseCase: sl(), roomRepository: sl()),
  );

  sl.registerFactory(
    () => RoomBloc(joinRoomUseCase: sl(), roomRepository: sl()),
  );

  sl.registerFactory(() => WalletBloc(walletRepository: sl()));
}
