import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import '../../models/room.dart';
import '../../services/api_service.dart';

class CreateRoomScreen extends StatefulWidget {
  final GameMode mode;
  const CreateRoomScreen({super.key, required this.mode});

  @override
  State<CreateRoomScreen> createState() => _CreateRoomScreenState();
}

class _CreateRoomScreenState extends State<CreateRoomScreen> {
  final _api = ApiService();
  bool _loading = false;
  int _maxPlayers = 6;

  Future<void> _create() async {
    setState(() => _loading = true);
    try {
      final room = await _api.createRoom(widget.mode, maxPlayers: _maxPlayers);
      if (mounted) context.push('/lobby/${room.code}', extra: room);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final modeColor = _modeColor(widget.mode);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: BackButton(color: Colors.white),
        title: Text(widget.mode.displayName, style: const TextStyle(color: Colors.white)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Max players', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
            const Gap(12),
            Row(
              children: [
                for (final n in [2, 4, 6, 8])
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _maxPlayers = n),
                      child: Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: _maxPlayers == n ? modeColor : modeColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: modeColor.withOpacity(0.5)),
                        ),
                        child: Center(
                          child: Text(
                            '$n',
                            style: TextStyle(
                              color: _maxPlayers == n ? Colors.white : modeColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: _loading ? null : _create,
                style: ElevatedButton.styleFrom(
                  backgroundColor: modeColor,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2)
                    : const Text('Create Room', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _modeColor(GameMode mode) => switch (mode) {
        GameMode.fillReveal => const Color(0xFF6C63FF),
        GameMode.rotatingChain => const Color(0xFF43AA8B),
        GameMode.battle => const Color(0xFFFF6B6B),
      };
}
