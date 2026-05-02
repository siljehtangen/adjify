import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

abstract final class AppTextStyle {
  static final appBarTitle = GoogleFonts.lora(color: kText, fontWeight: FontWeight.w600);
  static final sectionTitle = GoogleFonts.lora(color: kText, fontSize: 17, fontWeight: FontWeight.w600);
  static final screenHeading = GoogleFonts.lora(fontSize: 26, fontWeight: FontWeight.w700, color: kText);
  static final buttonLabel = GoogleFonts.lora(fontSize: 17, fontWeight: FontWeight.w600, color: Colors.white);
  static final buttonLabelDark = GoogleFonts.lora(fontSize: 17, fontWeight: FontWeight.w600, color: kNight);
  static final roomCode = GoogleFonts.lora(color: kAccent, fontSize: 30, fontWeight: FontWeight.w800, letterSpacing: 4);
}
