import 'package:dartz/dartz.dart';
import '../../../../core/error/failures.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Future<Either<Failure, User>> loginWithEmailAndPassword(String email, String password);
  Future<Either<Failure, User>> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String phone,
    required int avatarId,
  });
  Future<Either<Failure, User>> loginWithGoogle();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, void>> resetPassword(String email);
  Future<Either<Failure, User?>> getCurrentUser();
}
