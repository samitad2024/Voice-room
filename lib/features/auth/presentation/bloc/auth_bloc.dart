import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/login_with_email.dart';
import '../../domain/usecases/login_with_google.dart';
import '../../domain/usecases/login_with_phone.dart';
import '../../domain/usecases/logout.dart';
import '../../domain/usecases/register_with_email.dart';
import '../../domain/usecases/verify_phone_code.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final GetCurrentUser getCurrentUser;
  final LoginWithPhone loginWithPhone;
  final VerifyPhoneCode verifyPhoneCode;
  final LoginWithGoogle loginWithGoogle;
  final LoginWithEmail loginWithEmail;
  final RegisterWithEmail registerWithEmail;
  final Logout logout;

  AuthBloc({
    required this.getCurrentUser,
    required this.loginWithPhone,
    required this.verifyPhoneCode,
    required this.loginWithGoogle,
    required this.loginWithEmail,
    required this.registerWithEmail,
    required this.logout,
  }) : super(AuthInitial()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<LoginWithPhoneRequested>(_onLoginWithPhoneRequested);
    on<VerifyPhoneCodeRequested>(_onVerifyPhoneCodeRequested);
    on<LoginWithGoogleRequested>(_onLoginWithGoogleRequested);
    on<LoginWithEmailRequested>(_onLoginWithEmailRequested);
    on<RegisterWithEmailRequested>(_onRegisterWithEmailRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await getCurrentUser(NoParams());
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLoginWithPhoneRequested(
    LoginWithPhoneRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await loginWithPhone(
      LoginWithPhoneParams(phoneNumber: event.phoneNumber),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (verificationId) => emit(AuthPhoneCodeSent(verificationId)),
    );
  }

  Future<void> _onVerifyPhoneCodeRequested(
    VerifyPhoneCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await verifyPhoneCode(
      VerifyPhoneCodeParams(
        verificationId: event.verificationId,
        smsCode: event.smsCode,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLoginWithGoogleRequested(
    LoginWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await loginWithGoogle(NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLoginWithEmailRequested(
    LoginWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await loginWithEmail(
      LoginWithEmailParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onRegisterWithEmailRequested(
    RegisterWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await registerWithEmail(
      RegisterWithEmailParams(
        email: event.email,
        password: event.password,
        name: event.name,
      ),
    );
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (user) => emit(AuthAuthenticated(user)),
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    final result = await logout(NoParams());
    result.fold(
      (failure) => emit(AuthError(failure.message)),
      (_) => emit(AuthUnauthenticated()),
    );
  }
}
