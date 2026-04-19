import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class BlankInputSheet extends StatefulWidget {
  final int position;
  const BlankInputSheet({super.key, required this.position});

  @override
  State<BlankInputSheet> createState() => _BlankInputSheetState();
}

class _BlankInputSheetState extends State<BlankInputSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24, 24, 24, MediaQuery.of(context).viewInsets.bottom + 24),
      decoration: BoxDecoration(
        color: const Color(0xFF192C44),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border.all(color: const Color(0xFF38BDF8).withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.08),
            blurRadius: 30,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF818CF8).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFF818CF8).withValues(alpha: 0.3)),
                ),
                child: const Center(
                  child: Icon(Icons.edit, color: Color(0xFF818CF8), size: 18),
                ),
              ),
              const Gap(12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Blank ${widget.position + 1}',
                    style: const TextStyle(color: Color(0xFFEBF4FF), fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const Text(
                    'Enter an adjective',
                    style: TextStyle(color: Color(0xFF7DB9D8), fontSize: 13),
                  ),
                ],
              ),
            ],
          ),
          const Gap(18),
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFF101D2E),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: const Color(0xFF284D6E)),
            ),
            child: TextField(
              controller: _controller,
              autofocus: true,
              textCapitalization: TextCapitalization.none,
              style: const TextStyle(color: Color(0xFFEBF4FF), fontSize: 20),
              decoration: const InputDecoration(
                hintText: 'e.g. mysterious, fluffy, ancient…',
                hintStyle: TextStyle(color: Color(0xFF7DB9D8)),
                filled: false,
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              onSubmitted: (val) => Navigator.of(context).pop(val.trim()),
            ),
          ),
          const Gap(16),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(_controller.text.trim()),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF818CF8),
                elevation: 8,
                shadowColor: const Color(0xFF818CF8).withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Confirm', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
}
