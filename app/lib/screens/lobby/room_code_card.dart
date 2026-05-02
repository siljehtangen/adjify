import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:gap/gap.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../config/app_colors.dart';
import '../../widgets/game_card.dart';
import '../../widgets/snackbars.dart';

class RoomCodeCard extends StatelessWidget {
  final String roomCode;
  const RoomCodeCard({super.key, required this.roomCode});

  @override
  Widget build(BuildContext context) {
    return GameCard(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      borderColor: kAccent.withValues(alpha: 0.3),
      shadowColor: kAccent.withValues(alpha: 0.1),
      borderRadius: 18,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Room Code', style: TextStyle(color: kTextSub, fontSize: 12)),
              const Gap(2),
              Text(
                roomCode,
                style: GoogleFonts.lora(
                  color: kAccent,
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 4,
                ),
              ),
            ],
          ),
          const Spacer(),
          MouseRegion(
            cursor: SystemMouseCursors.click,
            child: GestureDetector(
              onTap: () {
                Clipboard.setData(ClipboardData(text: roomCode));
                showSuccessToast('Room code copied!');
              },
              child: Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: kAccent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: kAccent.withValues(alpha: 0.3)),
                ),
                child: const Center(child: FaIcon(FontAwesomeIcons.copy, size: 16, color: kAccent)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
