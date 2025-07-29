import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/user_entity.dart';

// Provider for FirebaseAuth instance
final Provider<FirebaseAuth> firebaseAuthProvider = Provider<FirebaseAuth>((ProviderRef<FirebaseAuth> ref) {
  return FirebaseAuth.instance;
});

// Provider for GoogleSignIn instance
final Provider<GoogleSignIn?> googleSignInProvider = Provider<GoogleSignIn?>((ProviderRef<GoogleSignIn?> ref) {
  // GoogleSignIn is not supported on Windows or Linux
  if (kIsWeb || Platform.isAndroid || Platform.isIOS || Platform.isMacOS) {
    return GoogleSignIn.instance;
  }
  return null;
});

// Provider for AuthRepository
final Provider<AuthRepository> authRepositoryProvider = Provider<AuthRepository>((ProviderRef<AuthRepository> ref) {
  return AuthRepositoryImpl(
    firebaseAuth: ref.watch(firebaseAuthProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  );
});

// Stream provider for auth state changes
final StreamProvider<UserEntity?> authStateProvider = StreamProvider<UserEntity?>((StreamProviderRef<UserEntity?> ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

// Provider for current user
final Provider<UserEntity?> currentUserProvider = Provider<UserEntity?>((ProviderRef<UserEntity?> ref) {
  return ref.watch(authRepositoryProvider).currentUser;
});
