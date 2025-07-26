import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

final StreamProvider<dynamic> authStateProvider = StreamProvider<User?>((StreamProviderRef<dynamic> ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final Provider<dynamic> authProvider = Provider<FirebaseAuth>((ProviderRef<dynamic> ref) {
  return FirebaseAuth.instance;
}); 