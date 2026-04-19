import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'models/room.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/lobby/create_room_screen.dart';
import 'screens/lobby/join_room_screen.dart';
import 'screens/lobby/lobby_screen.dart';
import 'screens/modes/fill_reveal/fill_reveal_screen.dart';
import 'screens/modes/rotating_chain/rotating_chain_screen.dart';
import 'screens/modes/battle/battle_screen.dart';

class _AuthNotifier extends ChangeNotifier {
  late final StreamSubscription<AuthState> _sub;

  _AuthNotifier() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((_) {
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final _authNotifier = _AuthNotifier();

final router = GoRouter(
  initialLocation: '/',
  refreshListenable: _authNotifier,
  redirect: (context, state) {
    final isLoggedIn = Supabase.instance.client.auth.currentUser != null;
    final onLoginPage = state.matchedLocation == '/login';

    if (!isLoggedIn && !onLoginPage) return '/login';
    if (isLoggedIn && onLoginPage) return '/';
    return null;
  },
  routes: [
    GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
    GoRoute(path: '/', builder: (_, __) => HomeScreen()),
    GoRoute(
      path: '/create',
      builder: (_, state) => CreateRoomScreen(mode: state.extra as GameMode),
    ),
    GoRoute(path: '/join', builder: (_, __) => const JoinRoomScreen()),
    GoRoute(
      path: '/lobby/:code',
      builder: (_, state) => LobbyScreen(roomCode: state.pathParameters['code']!),
    ),
    GoRoute(
      path: '/game/fill-reveal/:code',
      builder: (_, state) => FillRevealScreen(roomCode: state.pathParameters['code']!),
    ),
    GoRoute(
      path: '/game/chain/:code',
      builder: (_, state) => RotatingChainScreen(roomCode: state.pathParameters['code']!),
    ),
    GoRoute(
      path: '/game/battle/:code',
      builder: (_, state) => BattleScreen(roomCode: state.pathParameters['code']!),
    ),
  ],
  errorBuilder: (_, state) => Scaffold(
    body: Center(child: Text('Page not found: ${state.error}')),
  ),
);
