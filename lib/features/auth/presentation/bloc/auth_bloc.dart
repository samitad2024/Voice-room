import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
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
    debugPrint(
        '\n╔══════════════════════════════════════════════════════════════');
    debugPrint('║ 🔐 AUTH CHECK REQUESTED');
    debugPrint(
        '╚══════════════════════════════════════════════════════════════');
    emit(AuthLoading());
    debugPrint('   ⏳ Checking for existing session...');
    final result = await getCurrentUser(NoParams());
    result.fold(
      (failure) {
        debugPrint('   ❌ No authenticated user found: ${failure.message}');
        debugPrint('   📍 State → AuthUnauthenticated');
        emit(AuthUnauthenticated());
      },
      (user) {
        debugPrint('   ✅ User authenticated!');
        debugPrint('   👤 User ID: ${user.uid}');
        debugPrint('   📧 Email: ${user.email ?? "N/A"}');
        debugPrint('   📱 Phone: ${user.phone ?? "N/A"}');
        debugPrint('   📍 State → AuthAuthenticated');
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onLoginWithPhoneRequested(
    LoginWithPhoneRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint(
        '\n╔══════════════════════════════════════════════════════════════');
    debugPrint('║ 📱 LOGIN WITH PHONE REQUESTED');
    debugPrint(
        '╚══════════════════════════════════════════════════════════════');
    debugPrint('   📞 Phone: ${event.phoneNumber}');
    emit(AuthLoading());
    debugPrint('   ⏳ Sending OTP...');
    final result = await loginWithPhone(
      LoginWithPhoneParams(phoneNumber: event.phoneNumber),
    );
    result.fold(
      (failure) {
        debugPrint('   ❌ OTP send failed: ${failure.message}');
        debugPrint('   📍 State → AuthError');
        emit(AuthError(failure.message));
      },
      (verificationId) {
        debugPrint('   ✅ OTP sent successfully!');
        debugPrint('   🔑 Verification ID: $verificationId');
        debugPrint('   📍 State → AuthPhoneCodeSent');
        emit(AuthPhoneCodeSent(verificationId));
      },
    );
  }

  Future<void> _onVerifyPhoneCodeRequested(
    VerifyPhoneCodeRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint(
        '\n╔══════════════════════════════════════════════════════════════');
    debugPrint('║ 🔢 VERIFY PHONE CODE REQUESTED');
    debugPrint(
        '╚══════════════════════════════════════════════════════════════');
    debugPrint('   🔑 Verification ID: ${event.verificationId}');
    debugPrint('   🔐 SMS Code: ${event.smsCode}');
    emit(AuthLoading());
    debugPrint('   ⏳ Verifying OTP...');
    final result = await verifyPhoneCode(
      VerifyPhoneCodeParams(
        verificationId: event.verificationId,
        smsCode: event.smsCode,
      ),
    );
    result.fold(
      (failure) {
        debugPrint('   ❌ OTP verification failed: ${failure.message}');
        debugPrint('   📍 State → AuthError');
        emit(AuthError(failure.message));
      },
      (user) {
        debugPrint('   ✅ OTP verified! User authenticated!');
        debugPrint('   👤 User ID: ${user.uid}');
        debugPrint('   📍 State → AuthAuthenticated');
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onLoginWithGoogleRequested(
    LoginWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint(
        '\n╔══════════════════════════════════════════════════════════════');
    debugPrint('║ 🔵 LOGIN WITH GOOGLE REQUESTED');
    debugPrint(
        '╚══════════════════════════════════════════════════════════════');
    emit(AuthLoading());
    debugPrint('   ⏳ Starting Google Sign-In...');
    final result = await loginWithGoogle(NoParams());
    result.fold(
      (failure) {
        debugPrint('   ❌ Google login failed: ${failure.message}');
        debugPrint('   📍 State → AuthError');
        emit(AuthError(failure.message));
      },
      (user) {
        debugPrint('   ✅ Google login successful!');
        debugPrint('   👤 User ID: ${user.uid}');
        debugPrint('   📧 Email: ${user.email ?? "N/A"}');
        debugPrint('   👤 Name: ${user.name ?? "N/A"}');
        debugPrint('   📍 State → AuthAuthenticated');
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onLoginWithEmailRequested(
    LoginWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint(
        '\n╔══════════════════════════════════════════════════════════════');
    debugPrint('║ 📧 LOGIN WITH EMAIL REQUESTED');
    debugPrint(
        '╚══════════════════════════════════════════════════════════════');
    debugPrint('   📧 Email: ${event.email}');
    emit(AuthLoading());
    debugPrint('   ⏳ Authenticating with Supabase...');
    final result = await loginWithEmail(
      LoginWithEmailParams(email: event.email, password: event.password),
    );
    result.fold(
      (failure) {
        debugPrint('   ❌ Email login failed: ${failure.message}');
        debugPrint('   📍 State → AuthError');
        emit(AuthError(failure.message));
      },
      (user) {
        debugPrint('   ✅ Email login successful!');
        debugPrint('   👤 User ID: ${user.uid}');
        debugPrint('   📧 Email: ${user.email ?? "N/A"}');
        debugPrint('   📍 State → AuthAuthenticated');
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onRegisterWithEmailRequested(
    RegisterWithEmailRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint(
        '\n╔══════════════════════════════════════════════════════════════');
    debugPrint('║ 📝 REGISTER WITH EMAIL REQUESTED');
    debugPrint(
        '╚══════════════════════════════════════════════════════════════');
    debugPrint('   📧 Email: ${event.email}');
    debugPrint('   👤 Name: ${event.name}');
    emit(AuthLoading());
    debugPrint('   ⏳ Creating account in Supabase...');
    final result = await registerWithEmail(
      RegisterWithEmailParams(
        email: event.email,
        password: event.password,
        name: event.name,
      ),
    );
    result.fold(
      (failure) {
        debugPrint('   ❌ Registration failed: ${failure.message}');
        debugPrint('   📍 State → AuthError');
        emit(AuthError(failure.message));
      },
      (user) {
        debugPrint('   ✅ Registration successful!');
        debugPrint('   👤 User ID: ${user.uid}');
        debugPrint('   📧 Email: ${user.email ?? "N/A"}');
        debugPrint('   📍 State → AuthAuthenticated');
        emit(AuthAuthenticated(user));
      },
    );
  }

  Future<void> _onLogoutRequested(
    LogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    debugPrint(
        '\n╔══════════════════════════════════════════════════════════════');
    debugPrint('║ 🚪 LOGOUT REQUESTED');
    debugPrint(
        '╚══════════════════════════════════════════════════════════════');
    emit(AuthLoading());
    debugPrint('   ⏳ Signing out...');
    final result = await logout(NoParams());
    result.fold(
      (failure) {
        debugPrint('   ❌ Logout failed: ${failure.message}');
        debugPrint('   📍 State → AuthError');
        emit(AuthError(failure.message));
      },
      (_) {
        debugPrint('   ✅ Logout successful!');
        debugPrint('   📍 State → AuthUnauthenticated');
        emit(AuthUnauthenticated());
      },
    );
  }
}
