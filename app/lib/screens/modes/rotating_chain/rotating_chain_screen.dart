import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../config/app_colors.dart';
import '../../../services/api_service.dart';
import '../../../services/socket_service.dart';
import '../../../widgets/game_widgets.dart';

const _kAccent = Color(0xFF2DD4BF);

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
        showErrorSnackBar(context, e.toString());
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBg,
      appBar: AppBar(
        backgroundColor: kBg,
        elevation: 0,
        leading: const BackButton(color: kText),
        title: const Text('Rotating Chain', style: TextStyle(color: kText)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator(color: _kAccent))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: _isMyTurn && !_submitted
                  ? _buildMyTurn()
                  : _buildWaiting(),
            ),
    );
  }

  Widget _buildWaiting() {
    return WaitingPlaceholder(
      icon: const Text('⏳', style: TextStyle(fontSize: 40)),
      title: 'Waiting for your turn…',
      subtitle: 'Round ${_turnInfo?['roundNumber'] ?? '?'}',
      accent: _kAccent,
      animate: true,
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
            color: _kAccent.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _kAccent.withValues(alpha: 0.35)),
            boxShadow: [BoxShadow(color: _kAccent.withValues(alpha: 0.1), blurRadius: 16)],
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
                    style: const TextStyle(color: kText, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isSentence ? 'Include [ADJ] as a placeholder' : 'What adjective fits here?',
                    style: const TextStyle(color: kTextSub, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
        ),
        if (previous != null) ...[
          const Gap(16),
          const Text('Previous:', style: TextStyle(color: kTextSub, fontSize: 12)),
          const Gap(4),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: kSurface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: kBorder),
            ),
            child: Text(previous, style: const TextStyle(color: kTextSub, fontStyle: FontStyle.italic)),
          ),
        ],
        const Gap(20),
        Expanded(
          child: GameTextField(
            controller: _controller,
            expands: true,
            autofocus: true,
            borderRadius: 14,
            hintText: isSentence
                ? 'The [ADJ] wizard walked into the [ADJ] forest…'
                : 'mysterious, ancient, fluffy…',
          ),
        ),
        const Gap(16),
        GameSubmitButton(
          onPressed: _submitting ? null : _submit,
          label: 'Submit',
          loading: _submitting,
          accent: _kAccent,
        ),
      ],
    );
  }
}
