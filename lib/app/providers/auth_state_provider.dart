import 'package:flutter_riverpod/flutter_riverpod.dart';
// Uncomment and configure if using Firebase Auth
// import 'package:firebase_auth/firebase_auth.dart';

// Placeholder for user model, replace with your actual user model
class User {}

// Simulate auth state changes (replace with Firebase or your backend logic)
final StreamProvider<User?> authStateProvider = StreamProvider<User?>((StreamProviderRef<User?> ref) async* {
  // yield null for unauthenticated, or User() for authenticated
  yield null;
});

final Provider<bool> isAuthenticatedProvider = Provider<bool>((ProviderRef<bool> ref) {
  final AsyncValue<User?> authState = ref.watch(authStateProvider);
  return authState.hasValue && authState.value != null;
});

final Provider<User?> currentUserProvider = Provider<User?>((ProviderRef<User?> ref) {
  final AsyncValue<User?> authState = ref.watch(authStateProvider);
  return authState.value;
});
