import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_providers.dart';
import '../../../core/auth/auth_providers.dart';
import '../../../core/progress/progress_notifier.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/character_avatar_widget.dart';
import '../../../widgets/dotted_background_widget.dart';
import '../../../widgets/hard_shadow_box_widget.dart';
import '../../../widgets/icon_action_button_widget.dart';
import '../../auth/presentation/register/register_view.dart';
import 'profile_edit_view.dart';

/// Tela cheia de Configurações — substituiu o antigo `SettingsDialog`
/// (`Dialog` modal), pedido explícito do usuário: um círculo de avatar no
/// topo (o personagem escolhido pelo jogador, `ProgressState.avatarId`) com
/// um lápis sobreposto que abre `ProfileEditView` (nome de usuário + o
/// carrossel de personagens), toggle de Som e a seção "Conta".
///
/// Nome de usuário/foto de perfil só são editáveis por quem tem conta —
/// pedido explícito do usuário: sem conta, o lápis não aparece (editar
/// "quem eu sou" sem persistir em lugar nenhum não faz sentido, e essa
/// escolha só é salva no Firestore da conta via `ProgressNotifier`).
/// Estando logado, um link "Sair da conta" aparece no fim da tela (não mais
/// escondido dentro da linha "Conectado como" — pedido explícito do
/// usuário, ver `.claude/memory/decisions.md`).
///
/// Aberta pelo botão de engrenagem da Seleção de Mundo via `Navigator.push`
/// (era `showDialog`). `ConsumerStatefulWidget` pelo mesmo motivo de antes:
/// `AuthService.hasAccount`/`displayName` são getters que leem o Firebase
/// Auth ao vivo, não estado de provider — sem `setState` próprio depois de
/// voltar do cadastro/logout, a tela não re-renderiza.
class SettingsView extends ConsumerStatefulWidget {
  const SettingsView({super.key});

  @override
  ConsumerState<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends ConsumerState<SettingsView> {
  Future<void> _openRegister(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RegisterView(mandatory: false, onDone: () => Navigator.of(context).pop()),
    ));
    if (mounted) setState(() {});
  }

  /// "Sair" — pensado pro estande (aparelho compartilhado entre jogadores):
  /// volta pro estado "sem conta" e zera o progresso local (o progresso da
  /// conta que saiu continua salvo no Firestore dela, ver
  /// `ProgressNotifier.resetForNewPlayer`).
  Future<void> _signOut() async {
    await ref.read(authServiceProvider).signOut();
    ref.read(progressNotifierProvider.notifier).resetForNewPlayer();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final soundOn = !ref.watch(mutedProvider);
    final authService = ref.watch(authServiceProvider);
    final hasAccount = authService.hasAccount;
    final progress = ref.watch(progressNotifierProvider);
    final displayName = progress.username ?? authService.displayName;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const DottedBackground(),
          SafeArea(
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
                  const SizedBox(height: 8),
                  Center(child: Text('CONFIGURAÇÕES', style: AppText.eyebrow(size: 13))),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 20),
                          Center(
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CharacterAvatarCircle(avatarId: progress.displayAvatarId, size: 108, ringColor: AppColors.purple, ringWidth: 4),
                                // Lápis só aparece com conta — nome/foto de
                                // perfil só são editáveis por quem tem conta
                                // (pedido explícito do usuário, ver
                                // `.claude/memory/decisions.md`).
                                if (hasAccount)
                                  Positioned(
                                    right: -6,
                                    bottom: -6,
                                    child: GestureDetector(
                                      onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ProfileEditView())),
                                      child: Container(
                                        width: 38,
                                        height: 38,
                                        decoration: BoxDecoration(
                                          color: AppColors.yellowNeon,
                                          shape: BoxShape.circle,
                                          border: Border.all(color: AppColors.background, width: 3),
                                          boxShadow: AppShadows.hard(AppColors.yellowShadow),
                                        ),
                                        child: const Icon(Icons.edit, color: AppColors.purpleDark, size: 18),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (displayName != null) ...[
                            const SizedBox(height: 12),
                            Center(
                              child: Text(
                                displayName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: AppText.style(size: 18, weight: FontWeight.w900, color: AppColors.white),
                              ),
                            ),
                          ],
                          const SizedBox(height: 32),
                          HardShadowBox(
                            color: AppColors.panel,
                            shadows: AppShadows.hard(AppColors.black, dy: 4),
                            borderRadius: BorderRadius.circular(18),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text('Som', style: AppText.style(size: 17, weight: FontWeight.w800, color: AppColors.white)),
                                ),
                                Switch(
                                  value: soundOn,
                                  onChanged: (_) => ref.read(mutedProvider.notifier).toggle(),
                                  activeThumbColor: AppColors.purpleDark,
                                  activeTrackColor: AppColors.yellowNeon,
                                  inactiveThumbColor: AppColors.white,
                                  inactiveTrackColor: AppColors.grayButton,
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          HardShadowBox(
                            color: AppColors.panel,
                            shadows: AppShadows.hard(AppColors.black, dy: 4),
                            borderRadius: BorderRadius.circular(18),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    hasAccount ? 'Conectado como ${authService.displayName}' : 'Conta',
                                    style: AppText.style(size: 17, weight: FontWeight.w800, color: AppColors.white),
                                  ),
                                ),
                                if (!hasAccount)
                                  GestureDetector(
                                    onTap: () => _openRegister(context),
                                    child: Text('Criar conta', style: AppText.style(size: 15, weight: FontWeight.w900, color: AppColors.lilac)),
                                  ),
                              ],
                            ),
                          ),
                          // "Sair da conta" — no fim da tela, não mais um
                          // link pequeno dentro da linha "Conectado como"
                          // (pedido explícito do usuário, ver
                          // `.claude/memory/decisions.md`).
                          if (hasAccount) ...[
                            const SizedBox(height: 28),
                            Center(
                              child: GestureDetector(
                                onTap: _signOut,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(Icons.logout, color: AppColors.lilac, size: 18),
                                    const SizedBox(width: 8),
                                    Text('Sair da conta', style: AppText.style(size: 15, weight: FontWeight.w900, color: AppColors.lilac)),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
