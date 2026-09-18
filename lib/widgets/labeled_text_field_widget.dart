import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Rótulo pequeno (lilás) + `TextField` estilizado — extraído de
/// `SurveyScreen` (`_fieldDecoration`) quando `RegisterScreen` passou a
/// precisar do mesmo padrão de campo, 2º uso, sobe pra `lib/widgets/`
/// (`.claude/rules/design.md`).
class LabeledTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String hint;
  final TextInputType? keyboardType;
  final bool obscureText;
  final ValueChanged<String>? onChanged;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  const LabeledTextField({
    super.key,
    required this.label,
    required this.controller,
    required this.hint,
    this.keyboardType,
    this.obscureText = false,
    this.onChanged,
    this.inputFormatters,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppText.style(size: 13, weight: FontWeight.w900, color: AppColors.lilac)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          inputFormatters: inputFormatters,
          maxLength: maxLength,
          style: AppText.style(size: 16, weight: FontWeight.w800, color: AppColors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppText.style(size: 16, weight: FontWeight.w800, color: AppColors.white.withValues(alpha: 0.4)),
            filled: true,
            fillColor: AppColors.panel,
            contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: AppColors.yellowNeon, width: 2),
            ),
            counterText: maxLength != null ? '' : null,
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
