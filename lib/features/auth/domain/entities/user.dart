import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? phone;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.phone,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, email, name, phone, avatarUrl];
}
