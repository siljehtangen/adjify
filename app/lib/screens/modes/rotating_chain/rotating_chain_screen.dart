import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:gap/gap.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../services/api_service.dart';
import '../../../services/socket_service.dart';

class RotatingChainScreen extends StatefulWidget {
  final String roomCode;
  const RotatingChainScreen({super.key, required this.roomCode});

  @override
  State<RotatingChainScreen> createState() => _RotatingChainScreenState();
}

class _RotatingChainScreenState extends State<RotatingChainScreen> {
  final _api = ApiService();
  final _socket = SocketService();
  final _controller = TextEditingController();

  Map<String, dynamic>? _turnInfo;
  bool _loading = true;
  bool _submitting = false;
  bool _submitted = false;

  String get _myId => Supabase.instance.client.auth.currentUser!.id;
  bool get _isMyTurn => _turnInfo?['isYourTurn'] == true;

  @override
  void initState() {
    super.initState();
    _loadTurn();
    _socket.connect();
    _socket.joinRoom(widget.roomCode);
    _socket.on('game:chain_submitted', (_) { setState(() => _submitted = false); _loadTurn(); });
  }

  @override
  void dispose() {
    _socket.leaveRoom(widget.roomCode);
    _socket.disconnect();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadTurn() async {
    try {
      final info = await _api.getChainTurn(widget.roomCode);
      if (mounted) setState(() { _turnInfo = info; _loading = false; });
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    setState(() => _submitting = true);
    try {
      final type = _turnInfo!['segmentType'] as String;
      await _api.submitChainSegment(widget.roomCode, type, content);
      _controller.clear();
      setState(() { _submitted = true; _submitting = false; });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: const BackButton(color: Colors.white),
        title: const Text('Rotating Chain', style: TextStyle(color: Colors.white)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24),
              child: _isMyTurn && !_submitted
                  ? _buildMyTurn()
                  : _buildWaiting(),
            ),
    );
  }

  Widget _buildWaiting() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('⏳', style: TextStyle(fontSize: 64)).animate().scale(),
          const Gap(16),
          const Text(
            'Waiting for your turn…',
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const Gap(8),
          Text(
            'Round ${_turnInfo?['roundNumber'] ?? '?'}',
            style: TextStyle(color: Colors.white.withOpacity(0.5)),
          ),
        ],
      ),
    );
  }

  Widget _buildMyTurn() {
    final type = _turnInfo?['segmentType'] as String? ?? 'sentence';
    final previous = _turnInfo?['previousContent'] as String?;
    final isSentence = type == 'sentence';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF43AA8B).withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF43AA8B).withOpacity(0.4)),
          ),
          child: Row(
            children: [
              Text(isSentence ? '✍️' : '🔤', style: const TextStyle(fontSize: 24)),
              const Gap(12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isSentence ? 'Your turn: write a sentence' : 'Your turn: fill the adjective blank',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isSentence
                        ? 'Include [ADJ] as a placeholder'
                        : 'What adjective fits here?',
                    style: TextStyle(color: Colors.white.withOpacity(0.6), fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (previous != null) ...[
          const Gap(16),
          Text('Previous:', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
          const Gap(4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(previous, style: TextStyle(color: Colors.white.withOpacity(0.8), fontStyle: FontStyle.italic)),
          ),
        ],
        const Gap(20),
        Expanded(
          child: TextField(
            controller: _controller,
            maxLines: null,
            expands: true,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: isSentence
                  ? 'The [ADJ] wizard walked into the [ADJ] forest…'
                  : 'mysterious, ancient, fluffy…',
              hintStyle: TextStyle(color: Colors.white.withOpacity(0.3)),
              filled: true,
              fillColor: Colors.white.withOpacity(0.05),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
            ),
          ),
        ),
        const Gap(16),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: _submitting ? null : _submit,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF43AA8B),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: _submitting
                ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                : const Text('Submit', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }
}
