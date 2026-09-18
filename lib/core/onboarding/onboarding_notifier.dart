import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'onboarding_repository.dart';
import 'onboarding_state.dart';

part 'onboarding_notifier.g.dart';

/// `SplashView` consulta `seenWelcome` antes de navegar ao tocar "JOGAR"; se
/// `false`, empurra `WelcomeView` (3 slides + escolha de conta) em vez de ir
/// direto pra Seleção de Mundo. `WorldSelectView` consulta `hasSeen(world.number)`
/// antes de navegar; se `false`, empurra a `TutorialView` do mundo em vez de
/// navegar direto, e `markSeen` é chamado quando o jogador termina o
/// tutorial. `keepAlive: true` — pelo mesmo motivo de `ProgressNotifier`.
///
/// Persistido via `OnboardingRepository` (device-local, `shared_preferences`)
/// — antes ficava só em memória e resetava a cada reload da página/restart
/// do app, mostrando a apresentação da Libug/Lili de novo a cada visita
/// (achado real do usuário). `build()` devolve o estado vazio
/// **sincronamente** e hidrata como `Future` fire-and-forget, mesmo padrão
/// de `ProgressNotifier` — o jogo não espera a leitura do storage pra
/// renderizar a Splash.
@Riverpod(keepAlive: true)
class OnboardingNotifier extends _$OnboardingNotifier {
  bool _disposed = false;

  @override
  OnboardingState build() {
    ref.onDispose(() => _disposed = true);
    Future.microtask(_hydrate);
    return const OnboardingState();
  }

  Future<void> _hydrate() async {
    final saved = await ref.read(onboardingRepositoryProvider).fetch();
    if (_disposed) return;
    if (saved != null) state = saved;
  }

  void markSeen(int worldNumber) {
    state = state.copyWith(seenWorldNumbers: {...state.seenWorldNumbers, worldNumber});
    _syncNow();
  }

  void markWelcomeSeen() {
    state = state.copyWith(seenWelcome: true);
    _syncNow();
  }

  void markRecapSeen(int worldNumber) {
    state = state.copyWith(seenRecapWorldNumbers: {...state.seenRecapWorldNumbers, worldNumber});
    _syncNow();
  }

  void _syncNow() => unawaited(ref.read(onboardingRepositoryProvider).save(state));
}
