import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthService {
  factory AuthService() => _instance;
  static final _instance = AuthService._();
  AuthService._();

  final _client = Supabase.instance.client;

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  Future<void> signInWithGoogle() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.google,
      redirectTo: kIsWeb ? null : 'io.supabase.adjify://login-callback',
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  bool get isSignedIn => currentUser != null;
}
