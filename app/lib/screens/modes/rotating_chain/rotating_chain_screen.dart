import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import '../../../config/app_colors.dart';
import '../../../models/chain_segment.dart';
import '../../../services/api_service.dart';
import '../../../services/socket_service.dart';
import '../../../widgets/game_widgets.dart';
import 'chain_turn_view.dart';

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
  String? _error;

  bool get _isMyTurn => _turnInfo?['isYourTurn'] == true;

  @override
  void initState() {
    super.initState();
    _loadTurn();
    _socket.connect();
    _socket.joinRoom(widget.roomCode);
    _socket.on(SocketEvent.chainSubmitted, (_) { if (mounted) { setState(() => _submitted = false); _loadTurn(); } });
  }

  @override
  void dispose() {
    _socket.leaveRoom(widget.roomCode);
    _socket.disconnect();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _loadTurn() async {
    if (mounted) setState(() => _error = null);
    try {
      final info = await _api.getChainTurn(widget.roomCode);
      if (mounted) setState(() { _turnInfo = info; _loading = false; });
    } catch (e) {
      if (mounted) setState(() { _loading = false; _error = e is ApiException ? e.message : 'Failed to load turn'; });
    }
  }

  Future<void> _submit() async {
    final content = _controller.text.trim();
    if (content.isEmpty) return;

    setState(() => _submitting = true);
    try {
      final typeStr = _turnInfo!['segmentType'] as String? ?? 'sentence';
      final type = SegmentTypeX.fromString(typeStr);
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
          ? const Center(child: CircularProgressIndicator(color: kChain))
          : _error != null
              ? Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text(_error!, style: const TextStyle(color: kTextSub)),
                  const Gap(12),
                  TextButton(onPressed: _loadTurn, child: const Text('Retry', style: TextStyle(color: kChain))),
                ]))
          : Padding(
              padding: const EdgeInsets.all(24),
              child: _isMyTurn && !_submitted
                  ? ChainTurnView(
                      turnInfo: _turnInfo!,
                      controller: _controller,
                      submitting: _submitting,
                      onSubmit: _submit,
                    )
                  : _buildWaiting(),
            ),
    );
  }

  Widget _buildWaiting() {
    return WaitingPlaceholder(
      icon: const Text('⏳', style: TextStyle(fontSize: 40)),
      title: 'Waiting for your turn…',
      subtitle: 'Round ${_turnInfo?['roundNumber'] ?? '?'}',
      accent: kChain,
      animate: true,
    );
  }

}
