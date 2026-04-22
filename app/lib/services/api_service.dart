import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/env.dart';
import '../models/room.dart';
import '../models/story.dart';

class ApiService {
  factory ApiService() => _instance;
  static final _instance = ApiService._();
  ApiService._();

  final String _base = Env.apiUrl;

  Map<String, String> get _headers {
    final session = Supabase.instance.client.auth.currentSession;
    return {
      'Content-Type': 'application/json',
      if (session != null) 'Authorization': 'Bearer ${session.accessToken}',
    };
  }

  Future<T> _get<T>(String path, T Function(dynamic) parse) async {
    final res = await http.get(Uri.parse('$_base$path'), headers: _headers);
    _assertOk(res);
    return parse(jsonDecode(res.body));
  }

  Future<T> _post<T>(String path, Map<String, dynamic> body, T Function(dynamic) parse) async {
    final res = await http.post(
      Uri.parse('$_base$path'),
      headers: _headers,
      body: jsonEncode(body),
    );
    _assertOk(res);
    return parse(jsonDecode(res.body));
  }

  static T Function(dynamic) _wrap<T>(T Function(Map<String, dynamic>) fromJson) =>
      (dynamic j) => fromJson(j as Map<String, dynamic>);

  void _assertOk(http.Response res) {
    if (res.statusCode >= 400) {
      final body = jsonDecode(res.body);
      throw ApiException(body['error']?.toString() ?? 'Unknown error', res.statusCode);
    }
  }

  // Rooms
  Future<Room> createRoom(GameMode mode, {int maxPlayers = 6}) =>
      _post('/api/rooms', {'mode': mode.value, 'maxPlayers': maxPlayers}, _wrap(Room.fromJson));

  Future<Room> getRoom(String code) =>
      _get('/api/rooms/$code', _wrap(Room.fromJson));

  Future<Room> joinRoom(String code) =>
      _post('/api/rooms/$code/join', {}, _wrap(Room.fromJson));

  Future<void> leaveRoom(String code) =>
      _post('/api/rooms/$code/leave', {}, (_) {});

  Future<Room> startGame(String code) =>
      _post('/api/rooms/$code/start', {}, _wrap(Room.fromJson));

  // Stories (fill & reveal + battle template)
  Future<Story> createStory(String roomCode, String content) =>
      _post('/api/rooms/$roomCode/stories', {'content': content}, _wrap(Story.fromJson));

  Future<List<Story>> getStories(String roomCode) =>
      _get('/api/rooms/$roomCode/stories', (j) => (j as List).map((s) => Story.fromJson(s as Map<String, dynamic>)).toList());

  Future<Map<String, dynamic>> fillBlank(String roomCode, String storyId, int position, String adjective) =>
      _post('/api/rooms/$roomCode/stories/$storyId/blanks', {'position': position, 'adjective': adjective}, (j) => j as Map<String, dynamic>);

  Future<Story> revealStory(String roomCode, String storyId) =>
      _get('/api/rooms/$roomCode/stories/$storyId/reveal', _wrap(Story.fromJson));

  // Chain (mode 2)
  Future<List<ChainSegment>> getChain(String roomCode) =>
      _get('/api/rooms/$roomCode/chain', (j) => (j as List).map((s) => ChainSegment.fromJson(s as Map<String, dynamic>)).toList());

  Future<Map<String, dynamic>> getChainTurn(String roomCode) =>
      _get('/api/rooms/$roomCode/chain/turn', (j) => j as Map<String, dynamic>);

  Future<ChainSegment> submitChainSegment(String roomCode, SegmentType segmentType, String content) =>
      _post('/api/rooms/$roomCode/chain/submit', {'segmentType': segmentType.value, 'content': content}, _wrap(ChainSegment.fromJson));

  // Battle (mode 3)
  Future<Map<String, dynamic>> getBattlePrompt(String roomCode) =>
      _get('/api/rooms/$roomCode/battle/prompt', (j) => j as Map<String, dynamic>);

  Future<Map<String, dynamic>> submitBattleEntry(
    String roomCode,
    String templateStoryId,
    List<Map<String, dynamic>> filledBlanks,
    String continuation,
  ) =>
      _post('/api/rooms/$roomCode/battle/submit', {
        'templateStoryId': templateStoryId,
        'filledBlanks': filledBlanks,
        'continuation': continuation,
      }, (j) => j as Map<String, dynamic>);

  Future<void> castVote(String roomCode, String entryId) =>
      _post('/api/rooms/$roomCode/battle/vote', {'entryId': entryId}, (_) {});

  Future<List<BattleEntry>> getBattleResults(String roomCode) =>
      _get('/api/rooms/$roomCode/battle/results', (j) => (j as List).map((e) => BattleEntry.fromJson(e as Map<String, dynamic>)).toList());
}

class ApiException implements Exception {
  final String message;
  final int statusCode;
  ApiException(this.message, this.statusCode);

  @override
  String toString() => 'ApiException($statusCode): $message';
}
