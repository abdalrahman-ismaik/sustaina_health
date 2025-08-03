import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import '../models/auth_models.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/repositories/auth_repository.dart';
// import '../datasources/auth_remote_datasource.dart'; // Uncomment if you have a remote datasource

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn? _googleSignIn;

  AuthRepositoryImpl({
    required FirebaseAuth firebaseAuth,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth,
        _googleSignIn = googleSignIn;

  @override
  Stream<UserEntity?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((User? user) {
      if (user == null) return null;
      return UserModel.fromFirebaseUser(user).toEntity();
    });
  }

  @override
  UserEntity? get currentUser {
    final User? user = _firebaseAuth.currentUser;
    if (user == null) return null;
    return UserModel.fromFirebaseUser(user).toEntity();
  }

  @override
  Future<AuthResult> loginWithEmailAndPassword(LoginRequest request) async {
    final UserCredential credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: request.email,
      password: request.password,
    );
    if (credential.user == null) {
      throw Exception('Login failed: No user returned');
    }
    final UserModel userModel = UserModel.fromFirebaseUser(credential.user!);
    return AuthResult(user: userModel.toEntity(), isNewUser: false);
  }

  @override
  Future<AuthResult> registerWithEmailAndPassword(RegisterRequest request) async {
    final UserCredential credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: request.email,
      password: request.password,
    );
    if (credential.user == null) {
      throw Exception('Registration failed: No user returned');
    }
    await credential.user!.updateDisplayName(request.displayName);
    await credential.user!.reload();
    final User updatedUser = _firebaseAuth.currentUser!;
    final UserModel userModel = UserModel.fromFirebaseUser(updatedUser);
    return AuthResult(user: userModel.toEntity(), isNewUser: true);
  }

  @override
  Future<AuthResult?> loginWithGoogle() async {
    if (_googleSignIn == null) {
      throw UnsupportedError('Google sign-in is not supported on this platform.');
    }
    
    try {
      // Try to authenticate with Google
      final GoogleSignInAccount? googleUser = await _googleSignIn!.authenticate();
      if (googleUser == null) return null; // User cancelled the sign-in
      
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      // Create credential with idToken
      final OAuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );
      
      final UserCredential userCredential = await _firebaseAuth.signInWithCredential(credential);
      if (userCredential.user == null) return null;
      
      final UserModel userModel = UserModel.fromFirebaseUser(userCredential.user!);
      return AuthResult(
        user: userModel.toEntity(),
        isNewUser: userCredential.additionalUserInfo?.isNewUser ?? false,
      );
    } catch (e) {
      print('Google Sign-In Error: $e'); // Add logging for debugging
      
      // Handle specific Google Sign-In errors
      if (e.toString().contains('serverClientId') || 
          e.toString().contains('configuration') ||
          e.toString().contains('DEVELOPER_ERROR') ||
          e.toString().contains('GoogleSignIn') ||
          e.runtimeType.toString().contains('GoogleSignIn')) {
        throw Exception('Google Sign-In configuration error. Please check your Firebase configuration, SHA-1 fingerprint, and google-services.json file.');
      }
      rethrow;
    }
  }

  @override
  Future<AuthResult?> loginWithFacebook() async {
    final LoginResult result = await FacebookAuth.instance.login();
    if (result.status != LoginStatus.success) return null;
    final OAuthCredential facebookAuthCredential = FacebookAuthProvider.credential(result.accessToken!.tokenString);
    final UserCredential userCredential = await _firebaseAuth.signInWithCredential(facebookAuthCredential);
    if (userCredential.user == null) return null;
    final UserModel userModel = UserModel.fromFirebaseUser(userCredential.user!);
    return AuthResult(
      user: userModel.toEntity(),
      isNewUser: userCredential.additionalUserInfo?.isNewUser ?? false,
    );
  }

  @override
  Future<void> logout() async {
    final List<Future<void>> futures = <Future<void>>[
      _firebaseAuth.signOut(),
      FacebookAuth.instance.logOut(),
    ];
    if (_googleSignIn != null) {
      futures.add(_googleSignIn!.signOut());
    }
    await Future.wait(futures);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> sendEmailVerification() async {
    final User? user = _firebaseAuth.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  @override
  Future<void> updateProfile({String? displayName, String? photoURL}) async {
    final User? user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
      await user.updatePhotoURL(photoURL);
      await user.reload();
    }
  }

  @override
  Future<void> updatePassword(String newPassword) async {
    final User? user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.updatePassword(newPassword);
    }
  }

  @override
  Future<void> deleteAccount() async {
    final User? user = _firebaseAuth.currentUser;
    if (user != null) {
      await user.delete();
    }
  }
}
