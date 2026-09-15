import 'package:flutter/material.dart';

import '../audio/app_sounds.dart';
import '../data/app_auth.dart';
import '../screens/register_screen.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import 'icon_action_button_widget.dart';

/// Dialog modal de Configurações — toggle de Som
/// (`AppSounds.instance.muted`, invertido: "ligado" = não mutado) + seção
/// "Conta" (cadastro voluntário antes de terminar a Trilha 1, ver
/// `.claude/memory/decisions.md`). Aberto pelo botão de engrenagem
/// (`AppIcons.settings`) da Seleção de Trilha/Mundo via
/// `showDialog(context: context, builder: (_) => const SettingsDialog())`.
///
/// `StatefulWidget` porque `AppSounds.instance.muted` é um campo simples
/// (não um `ValueNotifier`/stream) — sem `setState` próprio o toggle não
/// re-renderiza ao ser tocado. Único controle de som do app hoje: o antigo
/// `MuteButton` (que aparecia em Gameplay/Vitória/Falha/Resultado) foi
/// removido — ver `.claude/memory/decisions.md`.
class SettingsDialog extends StatefulWidget {
  const SettingsDialog({super.key});

  @override
  State<SettingsDialog> createState() => _SettingsDialogState();
}

class _SettingsDialogState extends State<SettingsDialog> {
  void _toggleSound() => setState(() => AppSounds.instance.toggleMute());

  Future<void> _openRegister(BuildContext context) async {
    await Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RegisterScreen(mandatory: false, onDone: () => Navigator.of(context).pop()),
    ));
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final soundOn = !AppSounds.instance.muted;
    final hasAccount = AppAuth.instance.hasAccount;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 380),
        padding: const EdgeInsets.fromLTRB(22, 20, 18, 22),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: AppColors.grayButton, width: 3),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(child: Text('CONFIGURAÇÕES', style: AppText.eyebrow(size: 14))),
                IconActionButton(
                  size: 40,
                  borderRadius: 12,
                  background: AppColors.grayButton,
                  shadowColor: Colors.transparent,
                  icon: const Icon(Icons.close, color: AppColors.white, size: 20),
                  onTap: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: Text('Som', style: AppText.style(size: 17, weight: FontWeight.w800, color: AppColors.white)),
                ),
                Switch(
                  value: soundOn,
                  onChanged: (_) => _toggleSound(),
                  activeThumbColor: AppColors.purpleDark,
                  activeTrackColor: AppColors.yellowNeon,
                  inactiveThumbColor: AppColors.white,
                  inactiveTrackColor: AppColors.grayButton,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Text(
                    hasAccount ? 'Conectado como ${AppAuth.instance.displayName}' : 'Conta',
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
          ],
        ),
      ),
    );
  }
}
