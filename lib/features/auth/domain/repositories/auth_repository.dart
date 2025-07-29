import '../entities/user_entity.dart';
import '../../data/models/auth_models.dart';

abstract class AuthRepository {
  Stream<UserEntity?> get authStateChanges;
  UserEntity? get currentUser;
  
  Future<AuthResult> loginWithEmailAndPassword(LoginRequest request);
  Future<AuthResult> registerWithEmailAndPassword(RegisterRequest request);
  Future<AuthResult?> loginWithGoogle();
  Future<AuthResult?> loginWithFacebook();
  Future<void> logout();
  Future<void> sendPasswordResetEmail(String email);
  Future<void> sendEmailVerification();
  Future<void> updateProfile({String? displayName, String? photoURL});
  Future<void> updatePassword(String newPassword);
  Future<void> deleteAccount();
}
