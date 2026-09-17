import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/onboarding/onboarding_notifier.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/hard_shadow_box_widget.dart';
import '../../../widgets/primary_pill_button_widget.dart';
import '../../../widgets/tutorial_content.dart';
import '../../auth/presentation/register/register_state.dart';
import '../../auth/presentation/register/register_view.dart';
import '../../tutorial/presentation/tutorial_view.dart';
import '../../world_select/presentation/world_select_view.dart';

/// Boas-vindas de 1ª execução — mostrada ao tocar "JOGAR" na Splash pela
/// primeira vez (`OnboardingState.seenWelcome == false`), antes da Seleção
/// de Mundo. 3 slides (`welcomeSlides`, `lib/widgets/tutorial_content.dart`)
/// explicando o que é o jogo, terminando na escolha de conta em vez de um
/// botão único de "continuar" — pedido explícito do usuário. Substitui o
/// antigo `programmingConceptSlides` (mostrado por Mundo); ver
/// `.claude/memory/decisions.md`.
///
/// `ConsumerWidget` sem ViewModel — não há orquestração além de navegar e
/// marcar `seenWelcome` (ver `.claude/rules/architecture.md`, "Quando dar
/// ViewModel a uma tela").
class WelcomeView extends ConsumerWidget {
  const WelcomeView({super.key});

  /// Marca o intro como visto e vai pra Seleção de Mundo, removendo tudo
  /// entre a Splash e ela (a Splash continua embaixo na pilha, igual ao
  /// caminho de quem já tinha visto o intro). Usado por "Pular", "Jogar
  /// sem conta" e pelo `onDone` do `RegisterView` (criar conta/entrar).
  static void _finish(BuildContext context, WidgetRef ref) {
    ref.read(onboardingNotifierProvider.notifier).markWelcomeSeen();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const WorldSelectView()),
      (route) => route.isFirst,
    );
  }

  static void _openRegister(BuildContext context, WidgetRef ref, AuthMode mode) {
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RegisterView(
        mandatory: false,
        initialMode: mode,
        onDone: () {
          Navigator.of(context).pop();
          _finish(context, ref);
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TutorialView(
      slides: welcomeSlides,
      narrationAssets: const [],
      onFinish: () => _finish(context, ref),
      finalActionsBuilder: (context) => _AccountChoices(
        onCreateAccount: () => _openRegister(context, ref, AuthMode.register),
        onLogIn: () => _openRegister(context, ref, AuthMode.login),
        onPlayWithoutAccount: () => _finish(context, ref),
      ),
    );
  }
}

/// As 3 escolhas do último slide — "Criar conta" (ação mais desejada pro
/// produto: progresso salvo + aparecer no Placar) e "Já tenho conta" lado a
/// lado (mesmo peso visual, pedido explícito do usuário — nenhuma das duas
/// é "secundária" o bastante pra virar só um link), e "Jogar sem conta" como
/// link discreto abaixo dos dois.
class _AccountChoices extends StatelessWidget {
  final VoidCallback onCreateAccount;
  final VoidCallback onLogIn;
  final VoidCallback onPlayWithoutAccount;

  const _AccountChoices({required this.onCreateAccount, required this.onLogIn, required this.onPlayWithoutAccount});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: PrimaryPillButton(label: 'Criar conta', height: 64, fontSize: 18, onTap: onCreateAccount),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: HardShadowBox(
                color: AppColors.panel,
                shadows: AppShadows.hard(AppColors.grayButton),
                border: Border.all(color: AppColors.grayButton, width: 2),
                onTap: onLogIn,
                padding: const EdgeInsets.symmetric(vertical: 18),
                child: Center(
                  child: Text('Já tenho conta', style: AppText.style(size: 15, weight: FontWeight.w900, color: AppColors.white)),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: onPlayWithoutAccount,
          child: Text(
            'Jogar sem conta',
            style: AppText.style(size: 14, weight: FontWeight.w800, color: AppColors.white.withValues(alpha: 0.55)),
          ),
        ),
      ],
    );
  }
}
