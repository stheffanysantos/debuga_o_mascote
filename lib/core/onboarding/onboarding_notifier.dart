import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'onboarding_state.dart';

part 'onboarding_notifier.g.dart';

/// `SplashView` consulta `seenWelcome` antes de navegar ao tocar "JOGAR"; se
/// `false`, empurra `WelcomeView` (3 slides + escolha de conta) em vez de ir
/// direto pra Seleção de Mundo. `WorldSelectView` consulta `hasSeen(world.number)`
/// antes de navegar; se `false`, empurra a `TutorialView` do mundo em vez de
/// navegar direto, e `markSeen` é chamado quando o jogador termina o
/// tutorial. `keepAlive: true` — pelo mesmo motivo de `ProgressNotifier`.
@Riverpod(keepAlive: true)
class OnboardingNotifier extends _$OnboardingNotifier {
  @override
  OnboardingState build() => const OnboardingState();

  void markSeen(int worldNumber) => state = state.copyWith(seenWorldNumbers: {...state.seenWorldNumbers, worldNumber});

  void markWelcomeSeen() => state = state.copyWith(seenWelcome: true);

  void markRecapSeen(int worldNumber) =>
      state = state.copyWith(seenRecapWorldNumbers: {...state.seenRecapWorldNumbers, worldNumber});
}
