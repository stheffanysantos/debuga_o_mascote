import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_text.dart';
import 'pulse_tap_widget.dart';

/// Um nó do `ZigzagMap` — já resolvido pelo chamador (rótulo, ícone, estado
/// de bloqueio/`comingSoon`, se é tocável e o que fazer ao tocar). O widget
/// não conhece `GameWorld`/`GameTrack`; quem monta a lista decide o que cada
/// nó representa.
class ZigzagMapNode {
  final String label;
  final String iconAsset;

  /// `true` quando o item não é `comingSoon` mas ainda está bloqueado por
  /// progresso (item anterior não concluído) — mostra o cadeado.
  final bool locked;

  /// `true` quando o item ainda não existe de verdade (badge "EM BREVE").
  final bool comingSoon;

  /// `true` só quando o toque realmente navega — controla o pulso visual.
  /// `onTap` é sempre não-nulo mesmo quando `false` (mostra uma mensagem em
  /// vez de navegar), pra o toque nunca cair no vazio sem feedback nenhum.
  final bool tappable;

  final VoidCallback onTap;

  const ZigzagMapNode({
    required this.label,
    required this.iconAsset,
    required this.locked,
    required this.comingSoon,
    required this.tappable,
    required this.onTap,
  });
}

/// Mapa em zigue-zague — nós circulares ligados por uma trilha pontilhada
/// (pedido explícito do usuário, ver `.claude/memory/decisions.md`).
/// Extraído de dentro de `WorldSelectScreen` (`_WorldMapPath`/`_WorldMapNode`)
/// pra ficar reaproveitável — hoje `WorldSelectScreen` instancia um
/// `ZigzagMap` por seção de `GameTrack` jogável na mesma tela.
class ZigzagMap extends StatelessWidget {
  final List<ZigzagMapNode> nodes;

  const ZigzagMap({super.key, required this.nodes});

  /// Altura reservada por nó (espaço suficiente para o círculo grande +
  /// rótulo + respiro até o próximo nó) — pedido explícito do usuário de
  /// deixar os círculos "bem maiores"/"maximalista" (depois ajustado um
  /// pouco menor, ver `.claude/memory/decisions.md`).
  static const _nodeSpacing = 250.0;

  /// Posição horizontal (fração da largura disponível) de cada nó, criando o
  /// zigue-zague — repete em ciclo se a lista crescer.
  static const _xFractions = [0.28, 0.72, 0.28];

  double _xFractionFor(int index) => _xFractions[index % _xFractions.length];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final centers = [
          for (var i = 0; i < nodes.length; i++) Offset(_xFractionFor(i) * width, i * _nodeSpacing + _nodeSpacing / 2),
        ];
        const nodeWidth = 180.0;

        return SizedBox(
          width: width,
          height: nodes.length * _nodeSpacing,
          child: Stack(
            children: [
              Positioned.fill(child: CustomPaint(painter: _DashedPathPainter(points: centers))),
              for (var i = 0; i < nodes.length; i++)
                Positioned(
                  left: (centers[i].dx - nodeWidth / 2).clamp(0.0, width - nodeWidth),
                  top: centers[i].dy - _ZigzagMapNodeView.circleSize / 2,
                  width: nodeWidth,
                  child: _ZigzagMapNodeView(node: nodes[i]),
                ),
            ],
          ),
        );
      },
    );
  }
}

/// Linha pontilhada conectando os centros dos nós, em segmentos retos (um
/// segmento por par de nós consecutivos).
class _DashedPathPainter extends CustomPainter {
  final List<Offset> points;

  const _DashedPathPainter({required this.points});

  static const _dashWidth = 10.0;
  static const _dashSpace = 8.0;

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;
    final paint = Paint()
      ..color = AppColors.grayDashedBorder
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    for (var i = 0; i < points.length - 1; i++) {
      final start = points[i];
      final end = points[i + 1];
      final segment = end - start;
      final distance = segment.distance;
      if (distance == 0) continue;
      final direction = segment / distance;
      final dashCount = (distance / (_dashWidth + _dashSpace)).floor();
      var cursor = start;
      for (var d = 0; d < dashCount; d++) {
        final dashEnd = cursor + direction * _dashWidth;
        canvas.drawLine(cursor, dashEnd, paint);
        cursor = dashEnd + direction * _dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedPathPainter oldDelegate) => oldDelegate.points != points;
}

/// Renderização de um `ZigzagMapNode` — círculo com a imagem ilustrada +
/// rótulo abaixo. Estado (jogável/bloqueado/`comingSoon`) é comunicado por
/// imagem em escala de cinza + texto acinzentado.
class _ZigzagMapNodeView extends StatelessWidget {
  final ZigzagMapNode node;

  const _ZigzagMapNodeView({required this.node});

  /// Bem maior que o card antigo (84px) — pedido explícito do usuário
  /// ("maximalista"), o círculo é o elemento dominante do mapa. Ajustado um
  /// pouco menor que a primeira versão (168px), ver
  /// `.claude/memory/decisions.md`.
  static const circleSize = 132.0;

  @override
  Widget build(BuildContext context) {
    final blocked = node.locked || node.comingSoon;
    final ringColor = blocked ? AppColors.grayLocked : AppColors.yellowNeon;
    final ringShadow = blocked ? AppColors.grayLockedShadow : AppColors.yellowShadow;

    final rawImage = Image.asset(node.iconAsset, fit: BoxFit.cover);
    final circle = Container(
      width: circleSize,
      height: circleSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ringColor, width: 6),
        boxShadow: [BoxShadow(color: ringShadow, offset: const Offset(0, 8), blurRadius: 0)],
      ),
      child: ClipOval(
        child: blocked ? ColorFiltered(colorFilter: const ColorFilter.matrix(_grayscaleMatrix), child: rawImage) : rawImage,
      ),
    );

    final badge = node.locked
        ? Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.grayLocked,
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.background, width: 3),
              ),
              child: AppIcons.lock(size: 18, color: AppColors.grayLockIcon),
            ),
          )
        : null;

    final label = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(color: AppColors.panel, borderRadius: BorderRadius.circular(999)),
      child: Text(
        node.label,
        textAlign: TextAlign.center,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppText.style(size: 13, weight: FontWeight.w900, color: blocked ? AppColors.grayLockIcon : AppColors.white, height: 1.15),
      ),
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(clipBehavior: Clip.none, children: [circle, ?badge]),
        const SizedBox(height: 8),
        label,
        if (node.comingSoon) ...[
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(color: AppColors.grayLocked, borderRadius: BorderRadius.circular(999)),
            child: Text('EM BREVE', style: AppText.style(size: 9, weight: FontWeight.w900, color: AppColors.grayLockIcon, letterSpacing: 1)),
          ),
        ],
      ],
    );

    if (node.tappable) {
      return PulseTap(maxScale: 1.05, onTap: node.onTap, child: content);
    }
    return GestureDetector(onTap: node.onTap, child: content);
  }
}

// Dessaturação total (escala de cinza) para o ícone quando bloqueado/
// `comingSoon` — mesma família de matriz de `MascotImage`
// (`lib/widgets/mascot_image_widget.dart`), aqui com saturação 0 em vez de
// parcial.
const _grayscaleMatrix = <double>[
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0.2126, 0.7152, 0.0722, 0, 0,
  0, 0, 0, 1, 0,
];
