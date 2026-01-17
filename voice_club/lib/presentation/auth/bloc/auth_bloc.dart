import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/login_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final AuthRepository authRepository;

  AuthBloc({required this.loginUseCase, required this.authRepository})
    : super(const AuthInitial()) {
    on<LoginEvent>(_onLogin);
    on<CheckAuthStatusEvent>(_onCheckAuthStatus);
    on<LogoutEvent>(_onLogout);
  }

  Future<void> _onLogin(LoginEvent event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());

    final result = await loginUseCase(
      username: event.username,
      password: event.password,
    );

    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onCheckAuthStatus(
    CheckAuthStatusEvent event,
    Emitter<AuthState> emit,
  ) async {
    final result = await authRepository.getCurrentUser();

    result.fold(
      (failure) => emit(const AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLogout(LogoutEvent event, Emitter<AuthState> emit) async {
    await authRepository.logout();
    emit(const AuthUnauthenticated());
  }
}
