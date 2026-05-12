import 'package:firebase_auth/firebase_auth.dart' as firebase;
import 'package:google_sign_in/google_sign_in.dart';
import '../../../../core/error/exceptions.dart';
import '../../domain/entities/user.dart';

abstract class AuthRemoteDataSource {
  Future<User> loginWithEmailAndPassword(String email, String password);
  Future<User> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String phone,
    required int avatarId,
  });
  Future<User> loginWithGoogle();
  Future<void> logout();
  Future<void> resetPassword(String email);
  Future<User?> getCurrentUser();
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final firebase.FirebaseAuth firebaseAuth;
  final GoogleSignIn googleSignIn;

  AuthRemoteDataSourceImpl({
    required this.firebaseAuth,
    required this.googleSignIn,
  });

  @override
  Future<User> loginWithEmailAndPassword(String email, String password) async {
    try {
      final credential = await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        return _mapFirebaseUser(credential.user!);
      } else {
        throw AuthException('User not found after login');
      }
    } on firebase.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Authentication failed');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<User> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
    required String phone,
    required int avatarId,
  }) async {
    try {
      final credential = await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user != null) {
        // Here we could save name, phone, and avatarId to Firestore, but for now we'll just update the display name.
        await credential.user!.updateDisplayName(name);
        return _mapFirebaseUser(credential.user!);
      } else {
        throw AuthException('User not created');
      }
    } on firebase.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Registration failed');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<User> loginWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        throw AuthException('Google sign in aborted');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final credential = firebase.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await firebaseAuth.signInWithCredential(credential);
      if (userCredential.user != null) {
        return _mapFirebaseUser(userCredential.user!);
      } else {
        throw AuthException('Failed to login with Google');
      }
    } on firebase.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Google Sign-In failed');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<void> logout() async {
    await googleSignIn.signOut();
    await firebaseAuth.signOut();
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase.FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Failed to send reset email');
    } catch (e) {
      throw AuthException(e.toString());
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    final user = firebaseAuth.currentUser;
    if (user != null) {
      return _mapFirebaseUser(user);
    }
    return null;
  }

  User _mapFirebaseUser(firebase.User fbUser) {
    return User(
      id: fbUser.uid,
      email: fbUser.email ?? '',
      name: fbUser.displayName,
      phone: fbUser.phoneNumber,
      avatarUrl: fbUser.photoURL,
    );
  }
}
