import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_providers.dart';
import '../../../core/leaderboard/leaderboard_sync_service.dart';
import '../../../core/progress/progress_notifier.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/dotted_background_widget.dart';
import '../../../widgets/icon_action_button_widget.dart';
import '../../../widgets/labeled_text_field_widget.dart';
import '../../../widgets/primary_pill_button_widget.dart';
import '../../leaderboard/presentation/leaderboard_view.dart';
import '../../leaderboard/presentation/leaderboard_view_model.dart';

/// Pesquisa opcional (idade, "já programou antes?") — só quem responde
/// aparece no Placar Geral (`LeaderboardView`). O nome não é mais digitado
/// aqui — vem da conta logada (`authServiceProvider.displayName`); só é
/// possível chegar nesta tela já com uma conta (`LeaderboardView` pede
/// login antes, se preciso). Ver `.claude/memory/decisions.md`.
///
/// `ConsumerStatefulWidget` com estado local (não um ViewModel próprio) — o
/// único ponto de orquestração real é o `_submit()` de um único disparo, sem
/// estado async intermediário (loading/erro) que valesse a pena extrair (ver
/// plano de migração, §6).
class SurveyView extends ConsumerStatefulWidget {
  const SurveyView({super.key});

  @override
  ConsumerState<SurveyView> createState() => _SurveyViewState();
}

class _SurveyViewState extends ConsumerState<SurveyView> {
  final _ageController = TextEditingController();
  bool? _hasProgrammedBefore;

  @override
  void dispose() {
    _ageController.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    final age = int.tryParse(_ageController.text);
    return age != null && age > 0 && _hasProgrammedBefore != null;
  }

  Future<void> _submit() async {
    // Guarda idade/resposta no progresso (não só `hasSubmittedToLeaderboard`)
    // — é o que permite `LeaderboardSyncService` reenviar a entrada sozinho
    // a cada vitória nova, sem pedir a pesquisa de novo.
    ref.read(progressNotifierProvider.notifier).submitToLeaderboard(
          age: int.parse(_ageController.text),
          hasProgrammedBefore: _hasProgrammedBefore!,
        );
    await ref.read(leaderboardSyncServiceProvider).resync();
    // `leaderboardViewModelProvider` não é `.family` — é a MESMA instância
    // de provider em qualquer `LeaderboardView` da árvore. A tela de onde
    // viemos (`_JoinCard`) normalmente continua montada (offstage) na pilha
    // do `Navigator` por baixo desta, então ela ainda segura uma assinatura
    // viva do provider — sem invalidar, o `pushReplacement` abaixo montava
    // uma `LeaderboardView` nova que reusava o resultado *cacheado* de
    // ANTES do envio (vazio/sem o registro recém-criado), em vez de buscar
    // de novo. Achado real do usuário: "por que no placar não está
    // aparecendo meu nome?" — o placar nunca tinha sido recarregado depois
    // do envio. Ver `.claude/memory/decisions.md`.
    ref.invalidate(leaderboardViewModelProvider);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LeaderboardView()));
  }

  @override
  Widget build(BuildContext context) {
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
                  const SizedBox(height: 22),
                  Text('PLACAR GERAL', style: AppText.eyebrow(size: 13)),
                  Text('Quer aparecer no ranking?', style: AppText.style(size: 28, weight: FontWeight.w900, color: AppColors.white, height: 1.05)),
                  const SizedBox(height: 8),
                  Text(
                    'Responda 2 perguntinhas rápidas — você vai aparecer no Placar Geral como "${ref.watch(progressNotifierProvider).username ?? ref.watch(authServiceProvider).displayName ?? 'Jogador'}".',
                    style: AppText.style(size: 14, weight: FontWeight.w800, color: AppColors.white.withValues(alpha: 0.7), height: 1.3),
                  ),
                  const SizedBox(height: 28),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          LabeledTextField(
                            label: 'Sua idade',
                            controller: _ageController,
                            hint: 'Quantos anos você tem?',
                            keyboardType: TextInputType.number,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 20),
                          Text('Você já programou antes?', style: AppText.style(size: 13, weight: FontWeight.w900, color: AppColors.lilac)),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: _YesNoOption(label: 'Sim', selected: _hasProgrammedBefore == true, onTap: () => setState(() => _hasProgrammedBefore = true))),
                              const SizedBox(width: 12),
                              Expanded(child: _YesNoOption(label: 'Não', selected: _hasProgrammedBefore == false, onTap: () => setState(() => _hasProgrammedBefore = false))),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  PrimaryPillButton(label: 'Ver meu Placar', height: 64, fontSize: 20, enabled: _canSubmit, onTap: _submit),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _YesNoOption extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _YesNoOption({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.yellowNeon : AppColors.panel,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? AppColors.yellowNeon : AppColors.grayButton, width: 2),
        ),
        child: Text(
          label,
          style: AppText.style(size: 16, weight: FontWeight.w900, color: selected ? AppColors.purpleDark : AppColors.white),
        ),
      ),
    );
  }
}
