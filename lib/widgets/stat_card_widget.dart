import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text.dart';

/// Card "PONTOS" / "BLOCOS" da tela de Vitória.
class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? suffix;

  const StatCard({super.key, required this.label, required this.value, this.suffix});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label, style: AppText.eyebrow(), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Text(value, style: AppText.style(size: 32, weight: FontWeight.w900, color: AppColors.white)),
                if (suffix != null) ...[
                  const SizedBox(width: 4),
                  Text(suffix!, style: AppText.style(size: 16, weight: FontWeight.w900, color: AppColors.lilac)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
