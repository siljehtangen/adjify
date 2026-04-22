import 'package:flutter/material.dart';
import '../models/room.dart';

// Core palette
const kBg = Color(0xFF101D2E);
const kSurface = Color(0xFF192C44);
const kBorder = Color(0xFF284D6E);
const kText = Color(0xFFEBF4FF);
const kTextSub = Color(0xFF7DB9D8);
const kTextHint = Color(0x7F7DB9D8);
const kGold = Color(0xFFFBBF24);
const kAccent = Color(0xFF38BDF8);

// Mode accent colors
const kFillReveal = Color(0xFF818CF8);
const kChain = Color(0xFF2DD4BF);
const kBattle = Color(0xFFFB7185);

// Dark tones (used for gradients, cards, button foregrounds)
const kNight = Color(0xFF060F1E);
const kCardDark = Color(0xFF0B1D35);
const kBorderDeep = Color(0xFF1A3A5C);
const kGradMid = Color(0xFF172938);
const kGradEnd = Color(0xFF1B3050);

extension GameModeColor on GameMode {
  Color get color => switch (this) {
        GameMode.fillReveal => kFillReveal,
        GameMode.rotatingChain => kChain,
        GameMode.battle => kBattle,
      };
}
