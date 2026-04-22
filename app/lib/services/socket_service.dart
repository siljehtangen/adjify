import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';

abstract final class SocketEvent {
  // Lobby
  static const playerJoined = 'room:player_joined';
  static const playerLeft = 'room:player_left';
  static const gameStarted = 'room:game_started';

  // Fill & Reveal
  static const blankFilled = 'game:blank_filled';
  static const storyRevealed = 'game:story_revealed';
  static const storyCreated = 'game:story_created';

  // Rotating Chain
  static const chainSubmitted = 'game:chain_submitted';

  // Battle
  static const battleReveal = 'game:battle_reveal';
  static const voteCast = 'game:vote_cast';
}

class SocketService {
  io.Socket? _socket;

  io.Socket get socket {
    assert(_socket != null, 'Call connect() before using the socket');
    return _socket!;
  }

  bool get isConnected => _socket?.connected ?? false;

  void connect() {
    final session = Supabase.instance.client.auth.currentSession;
    if (session == null) return;

    _socket = io.io(
      Env.apiUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': session.accessToken})
          .enableAutoConnect()
          .build(),
    );
  }

  void joinRoom(String roomCode) {
    _socket?.emit('join_room', roomCode);
  }

  void leaveRoom(String roomCode) {
    _socket?.emit('leave_room', roomCode);
  }

  void on(String event, Function(dynamic) handler) {
    _socket?.on(event, handler);
  }

  void off(String event) {
    _socket?.off(event);
  }

  void disconnect() {
    _socket?.disconnect();
    _socket = null;
  }
}
