import 'package:flutter_riverpod/flutter_riverpod.dart';
// Uncomment and configure if using Firebase Auth
// import 'package:firebase_auth/firebase_auth.dart';

// Placeholder for user model, replace with your actual user model
class User {}

// Simulate auth state changes (replace with Firebase or your backend logic)
final authStateProvider = StreamProvider<User?>((ref) async* {
  // yield null for unauthenticated, or User() for authenticated
  yield null;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.hasValue && authState.value != null;
});

final currentUserProvider = Provider<User?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.value;
});
