import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_providers.dart';
import '../../../core/progress/progress_notifier.dart';
import '../../../models/character_avatar.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/character_avatar_widget.dart';
import '../../../widgets/icon_action_button_widget.dart';
import '../../../widgets/labeled_text_field_widget.dart';
import '../../../widgets/primary_pill_button_widget.dart';
import '../../../theme/app_icons.dart';

/// Tela de "Configuração de Usuário" aberta pelo lápis em `SettingsView` —
/// edita o nome de exibição (`ProgressState.username`, mostrado no Placar
/// Geral no lugar do nome da conta quando preenchido) e a foto de perfil
/// (`ProgressState.avatarId`, um seletor de `CharacterAvatar` — pedido
/// explícito do usuário). 5 personagens hoje (Lili, Libug + 3 novos); mais
/// opções futuras bastam um item a mais em `characterAvatars`
/// (`lib/models/character_avatar.dart`) sem tocar nesta tela. `Wrap` (não
/// `ListView` horizontal) — os avatares quebram em quantas linhas forem
/// necessárias em vez de só rolar pro lado, então uma lista maior nunca fica
/// "escondida" fora da tela. Ver `.claude/memory/decisions.md`.
class ProfileEditView extends ConsumerStatefulWidget {
  const ProfileEditView({super.key});

  @override
  ConsumerState<ProfileEditView> createState() => _ProfileEditViewState();
}

class _ProfileEditViewState extends ConsumerState<ProfileEditView> {
  late final TextEditingController _nameController;
  late String _selectedAvatarId;

  @override
  void initState() {
    super.initState();
    final progress = ref.read(progressNotifierProvider);
    final auth = ref.read(authServiceProvider);
    _nameController = TextEditingController(text: progress.username ?? auth.displayName ?? '');
    _selectedAvatarId = progress.displayAvatarId;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save() {
    final name = _nameController.text.trim();
    final notifier = ref.read(progressNotifierProvider.notifier);
    if (name.isNotEmpty) notifier.setUsername(name);
    notifier.setAvatarId(_selectedAvatarId);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconActionButton(
                background: AppColors.grayButton,
                shadowColor: Colors.transparent,
                icon: AppIcons.chevronLeft(size: 22, color: AppColors.white),
                onTap: () => Navigator.of(context).pop(),
              ),
              const SizedBox(height: 22),
              Text('SEU PERFIL', style: AppText.eyebrow(size: 13)),
              Text('Configuração de usuário', style: AppText.style(size: 26, weight: FontWeight.w900, color: AppColors.white, height: 1.05)),
              const SizedBox(height: 28),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      LabeledTextField(
                        label: 'Nome de usuário',
                        controller: _nameController,
                        hint: 'Como você quer aparecer no Placar?',
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 28),
                      Text('Escolha seu personagem', style: AppText.style(size: 13, weight: FontWeight.w900, color: AppColors.lilac)),
                      const SizedBox(height: 12),
                      // `Wrap`, não `ListView` horizontal — cada avatar tem
                      // largura fixa (`_AvatarOption`, 84px), então quantos
                      // couberem numa linha ficam numa linha, e o resto
                      // quebra pra linha(s) de baixo automaticamente (achado
                      // do usuário: uma lista só-horizontal escondia os
                      // avatares que não cabiam na largura da tela).
                      Wrap(
                        spacing: 16,
                        runSpacing: 16,
                        children: [
                          for (final avatar in characterAvatars)
                            _AvatarOption(
                              avatar: avatar,
                              selected: avatar.id == _selectedAvatarId,
                              onTap: () => setState(() => _selectedAvatarId = avatar.id),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              PrimaryPillButton(label: 'Salvar', height: 64, fontSize: 20, onTap: _save),
            ],
          ),
        ),
      ),
    );
  }
}

class _AvatarOption extends StatelessWidget {
  final CharacterAvatar avatar;
  final bool selected;
  final VoidCallback onTap;

  const _AvatarOption({required this.avatar, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: 84,
        child: Column(
          children: [
            CharacterAvatarCircle(
              avatarId: avatar.id,
              size: 76,
              ringColor: selected ? AppColors.yellowNeon : AppColors.grayButton,
              ringWidth: selected ? 4 : 2,
            ),
            const SizedBox(height: 8),
            Text(
              avatar.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.style(size: 13, weight: FontWeight.w800, color: selected ? AppColors.yellowNeon : AppColors.white),
            ),
          ],
        ),
      ),
    );
  }
}
