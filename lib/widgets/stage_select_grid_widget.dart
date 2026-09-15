import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_text.dart';
import 'pulse_tap_widget.dart';
import 'star_row_widget.dart';

/// Estado visual de uma fase na grade de seleção — concluída (roxo +
/// estrelas), atual (amarelo pulsando) ou bloqueada (cinza + cadeado). Ver
/// `.claude/memory/design-system.md`.
enum StageStatus { done, current, locked }

/// Dado de uma fase na grade — desacoplado do `Level` do labirinto para que
/// `StageSelectGrid` sirva qualquer motor de jogo (Mundo 1 hoje; Mundos 2/3
/// quando tiverem fases, ver `.claude/plans/Mundos.md`).
class StageTileData {
  final int number;
  final StageStatus status;
  final int stars;

  const StageTileData({required this.number, required this.status, this.stars = 0});
}

/// Grade de seleção de fase (3 colunas; 4 em telas ≥620px) — extraída de
/// `LevelSelectScreen` para ser reaproveitada pelas telas de seleção de fase
/// dos Mundos 2/3 no futuro. Ver `.claude/memory/design-system.md`
/// (inventário de componentes).
class StageSelectGrid extends StatelessWidget {
  final List<StageTileData> stages;
  final ValueChanged<int> onTap;

  const StageSelectGrid({super.key, required this.stages, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Colunas fixas para telas de celular; ganha uma coluna a mais em
        // telas largas (tablet/paisagem) para o toque continuar confortável
        // em qualquer tamanho de dispositivo.
        final crossAxisCount = constraints.maxWidth >= 620 ? 4 : 3;
        return GridView.builder(
          itemCount: stages.length,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 14,
            crossAxisSpacing: 14,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) => _StageTile(data: stages[index], onTap: () => onTap(index)),
        );
      },
    );
  }
}

class _StageTile extends StatelessWidget {
  final StageTileData data;
  final VoidCallback onTap;

  const _StageTile({required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Tamanho do avatar sempre derivado do espaço real que a célula da
        // grade tem disponível — nunca um px fixo — para nunca estourar a
        // célula, seja num celular estreito ou num tablet.
        const reservedForLabel = 30.0;
        // Só limita o teto (telas enormes) — nunca o piso: exigir um
        // mínimo aqui faria o avatar pedir mais espaço do que a célula da
        // grade realmente tem, estourando em telas estreitas.
        final avatarSize = math
            .min(constraints.maxWidth, math.max(constraints.maxHeight - reservedForLabel, 0.0))
            .clamp(0.0, 128.0);
        final numberSize = avatarSize * 0.4;
        final iconSize = avatarSize * 0.34;
        final radius = avatarSize * 0.32;
        final number = data.number;

        switch (data.status) {
          case StageStatus.done:
            final boxSize = avatarSize * 0.92;
            return PulseTap(
              maxScale: 1.0,
              onTap: onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: boxSize,
                    height: boxSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.purple,
                      borderRadius: BorderRadius.circular(radius),
                      boxShadow: [BoxShadow(color: AppColors.purpleShadow, offset: Offset(0, boxSize * 0.09), blurRadius: 0)],
                    ),
                    child: Text('$number', style: AppText.style(size: numberSize, weight: FontWeight.w900, color: AppColors.white)),
                  ),
                  SizedBox(height: avatarSize * 0.08),
                  StarRow(lit: data.stars, size: avatarSize * 0.2),
                ],
              ),
            );
          case StageStatus.current:
            return PulseTap(
              onTap: onTap,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: avatarSize,
                    height: avatarSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.yellowNeon,
                      borderRadius: BorderRadius.circular(radius * 1.05),
                      boxShadow: [
                        BoxShadow(color: AppColors.yellowShadow, offset: Offset(0, avatarSize * 0.09), blurRadius: 0),
                        BoxShadow(color: AppColors.yellowNeon.withValues(alpha: 0.25), blurRadius: 0, spreadRadius: avatarSize * 0.06),
                      ],
                    ),
                    child: Text('$number', style: AppText.style(size: numberSize * 1.05, weight: FontWeight.w900, color: AppColors.purpleDark)),
                  ),
                  SizedBox(height: avatarSize * 0.08),
                  Text(
                    'JOGAR',
                    style: AppText.style(size: (avatarSize * 0.13).clamp(9.0, 13.0), weight: FontWeight.w900, color: AppColors.yellowNeon, letterSpacing: 1.4),
                  ),
                ],
              ),
            );
          case StageStatus.locked:
            final boxSize = avatarSize * 0.92;
            return Opacity(
              opacity: 0.75,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: boxSize,
                    height: boxSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.grayLocked,
                      borderRadius: BorderRadius.circular(radius),
                      boxShadow: [BoxShadow(color: AppColors.grayLockedShadow, offset: Offset(0, boxSize * 0.09), blurRadius: 0)],
                    ),
                    child: AppIcons.lock(size: iconSize, color: AppColors.grayLockIcon),
                  ),
                ],
              ),
            );
        }
      },
    );
  }
}
