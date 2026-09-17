import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_text.dart';
import 'icon_action_button_widget.dart';

/// Cabeçalho da Gameplay — voltar, "FASE N" + título, chip final opcional.
/// Reaproveitado por `GameplayScreen` (Mundo 1), `ConveyorGameplayScreen`
/// (Mundo 2) e `CodePuzzleGameplayScreen` (Mundo 5); extraído para não
/// duplicar a mesma árvore de widgets nos 3 motores. Sem botão de mute —
/// o som só é controlado pela `SettingsView` da Seleção de Mundo agora (ver
/// `.claude/memory/decisions.md`).
///
/// O chip final é um texto livre (`trailingChipText`) em vez de
/// `blocksUsed`/`maxBlocks` fixos — o Mundo 5 não tem "blocos", mostra a
/// tentativa atual ali (ver `.claude/memory/decisions.md`). `null` esconde
/// o chip inteiro.
class GameplayHeader extends StatelessWidget {
  final int levelNumber;
  final String title;
  final String? trailingChipText;
  final VoidCallback onBack;

  const GameplayHeader({
    super.key,
    required this.levelNumber,
    required this.title,
    this.trailingChipText,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconActionButton(
          size: 48,
          borderRadius: 14,
          background: AppColors.grayButton,
          shadowColor: Colors.transparent,
          icon: AppIcons.chevronLeft(size: 20, color: AppColors.white),
          onTap: onBack,
        ),
        Expanded(
          child: Column(
            children: [
              Text('FASE $levelNumber', style: AppText.eyebrow(size: 11)),
              Text(title, style: AppText.style(size: 18, weight: FontWeight.w900, color: AppColors.white)),
            ],
          ),
        ),
        if (trailingChipText != null)
          Container(
            height: 48,
            // Teto de largura + `FittedBox` — sem isso, um `trailingChipText`
            // mais longo (varia por mundo: "0 / 8 blocos" vs "Tentativa 3")
            // podia estourar o cabeçalho em telas de 320px (achado ao rodar
            // `no_overflow_test.dart` depois de generalizar este widget).
            constraints: const BoxConstraints(maxWidth: 120),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            decoration: BoxDecoration(color: AppColors.purpleDark, borderRadius: BorderRadius.circular(14)),
            alignment: Alignment.center,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                trailingChipText!,
                maxLines: 1,
                style: AppText.style(size: 14, weight: FontWeight.w900, color: AppColors.yellowNeon),
              ),
            ),
          ),
      ],
    );
  }
}
