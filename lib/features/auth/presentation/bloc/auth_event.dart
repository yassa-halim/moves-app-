import 'package:equatable/equatable.dart';


abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class CheckAuthStatus extends AuthEvent {}

class LoginRequested extends AuthEvent {
  final String email;
  final String password;

  const LoginRequested({required this.email, required this.password});

  @override
  List<Object> get props => [email, password];
}

class RegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String phone;
  final int avatarId;

  const RegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.phone,
    required this.avatarId,
  });

  @override
  List<Object> get props => [name, email, password, phone, avatarId];
}

class GoogleLoginRequested extends AuthEvent {}

class LogoutRequested extends AuthEvent {}

class ResetPasswordRequested extends AuthEvent {
  final String email;

  const ResetPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class UpdateProfileRequested extends AuthEvent {
  final String? name;
  final String? phone;
  final String? avatarUrl;

  const UpdateProfileRequested({this.name, this.phone, this.avatarUrl});

  @override
  List<Object?> get props => [name, phone, avatarUrl];
}
