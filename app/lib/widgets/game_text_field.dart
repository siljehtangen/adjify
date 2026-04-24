import 'package:flutter/material.dart';
import '../config/app_colors.dart';

class GameTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final int? maxLines;
  final int? minLines;
  final bool expands;
  final bool autofocus;
  final double borderRadius;
  final EdgeInsetsGeometry contentPadding;

  const GameTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.labelText,
    this.maxLines = 1,
    this.minLines,
    this.expands = false,
    this.autofocus = false,
    this.borderRadius = 12,
    this.contentPadding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: kSurface,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(color: kBorder),
      ),
      child: TextField(
        controller: controller,
        maxLines: expands ? null : maxLines,
        minLines: minLines,
        expands: expands,
        autofocus: autofocus,
        style: const TextStyle(color: kText),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: const TextStyle(color: kTextHint),
          labelText: labelText,
          labelStyle: const TextStyle(color: kTextSub),
          filled: false,
          border: InputBorder.none,
          contentPadding: contentPadding,
        ),
      ),
    );
  }
}
