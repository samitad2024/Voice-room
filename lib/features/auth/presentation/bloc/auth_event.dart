part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthCheckRequested extends AuthEvent {
  const AuthCheckRequested();
}

class LoginWithPhoneRequested extends AuthEvent {
  final String phoneNumber;

  const LoginWithPhoneRequested(this.phoneNumber);

  @override
  List<Object> get props => [phoneNumber];
}

class VerifyPhoneCodeRequested extends AuthEvent {
  final String verificationId;
  final String smsCode;

  const VerifyPhoneCodeRequested({
    required this.verificationId,
    required this.smsCode,
  });

  @override
  List<Object> get props => [verificationId, smsCode];
}

class LoginWithGoogleRequested extends AuthEvent {
  const LoginWithGoogleRequested();
}

class LoginWithEmailRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginWithEmailRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class RegisterWithEmailRequested extends AuthEvent {
  final String email;
  final String password;
  final String name;

  const RegisterWithEmailRequested({
    required this.email,
    required this.password,
    required this.name,
  });

  @override
  List<Object> get props => [email, password, name];
}

class LogoutRequested extends AuthEvent {
  const LogoutRequested();
}
