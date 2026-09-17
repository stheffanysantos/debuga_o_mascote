import 'package:flutter/material.dart';

import '../models/character_avatar.dart';
import '../theme/app_colors.dart';

/// Círculo com a arte de um `CharacterAvatar` — reaproveitado no topo de
/// `SettingsView` (avatar do jogador), no carrossel de `ProfileEditView`
/// (opções selecionáveis) e em `_RankRow` do Placar Geral (identifica quem é
/// quem no ranking). `ringColor`/`ringWidth` deixam quem chama destacar a
/// opção selecionada sem duplicar o widget inteiro.
class CharacterAvatarCircle extends StatelessWidget {
  final String avatarId;
  final double size;
  final Color ringColor;
  final double ringWidth;

  const CharacterAvatarCircle({
    super.key,
    required this.avatarId,
    this.size = 48,
    this.ringColor = AppColors.purple,
    this.ringWidth = 3,
  });

  @override
  Widget build(BuildContext context) {
    final avatar = avatarById(avatarId);
    return Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(ringWidth),
      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ringColor, width: ringWidth)),
      child: ClipOval(
        child: Container(
          color: AppColors.purpleDark,
          child: Image.asset(avatar.assetPath, fit: BoxFit.cover),
        ),
      ),
    );
  }
}
