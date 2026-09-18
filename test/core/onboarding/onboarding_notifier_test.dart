import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/core/onboarding/onboarding_notifier.dart';
import 'package:debuga_o_mascote/core/onboarding/onboarding_repository.dart';
import 'package:debuga_o_mascote/core/onboarding/onboarding_state.dart';

/// `OnboardingNotifier` (`lib/core/onboarding/onboarding_notifier.dart`) —
/// achado real do usuário: a apresentação da Libug/Lili (`seenWelcome`)
/// aparecia de novo toda vez que a página do jogo era fechada e reaberta,
/// porque o estado só vivia em memória. Estes testes cobrem a persistência
/// via `OnboardingRepository` (mesmo padrão de `progress_notifier_test.dart`).
class _FakeOnboardingRepository implements OnboardingRepository {
  OnboardingState? seeded;
  OnboardingState? lastSaved;

  @override
  Future<OnboardingState?> fetch() async => seeded;

  @override
  Future<void> save(OnboardingState state) async => lastSaved = state;
}

void main() {
  test('markWelcomeSeen/markSeen/markRecapSeen persistem no OnboardingRepository', () async {
    final repository = _FakeOnboardingRepository();
    final container = ProviderContainer(overrides: [onboardingRepositoryProvider.overrideWithValue(repository)]);
    addTearDown(container.dispose);
    final notifier = container.read(onboardingNotifierProvider.notifier);

    // Aguarda a hidratação inicial (sem nada salvo ainda) antes de mutar.
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    notifier.markWelcomeSeen();
    notifier.markSeen(1);
    notifier.markRecapSeen(2);
    await Future<void>.delayed(Duration.zero);

    final state = container.read(onboardingNotifierProvider);
    expect(state.seenWelcome, isTrue);
    expect(state.hasSeen(1), isTrue);
    expect(state.hasSeenRecap(2), isTrue);
    expect(repository.lastSaved?.seenWelcome, isTrue, reason: 'toda mutação deve sincronizar com o repositório');
  });

  test('build() hidrata a partir do OnboardingRepository — reabrir a página não mostra as boas-vindas de novo', () async {
    final repository = _FakeOnboardingRepository()
      ..seeded = const OnboardingState(seenWelcome: true, seenWorldNumbers: {1}, seenRecapWorldNumbers: {});
    final container = ProviderContainer(overrides: [onboardingRepositoryProvider.overrideWithValue(repository)]);
    addTearDown(container.dispose);

    // `build()` já devolve o estado vazio sincronamente e dispara a
    // hidratação fire-and-forget — precisa dar tempo pro `Future.microtask`
    // rodar antes de checar o estado hidratado.
    container.read(onboardingNotifierProvider);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final state = container.read(onboardingNotifierProvider);
    expect(state.seenWelcome, isTrue, reason: 'sem isso, a apresentação da Libug/Lili apareceria de novo a cada reload');
    expect(state.hasSeen(1), isTrue);
  });

  test('sem nada salvo (1ª visita de verdade), o estado continua vazio depois da hidratação', () async {
    final repository = _FakeOnboardingRepository();
    final container = ProviderContainer(overrides: [onboardingRepositoryProvider.overrideWithValue(repository)]);
    addTearDown(container.dispose);

    container.read(onboardingNotifierProvider);
    await Future<void>.delayed(Duration.zero);
    await Future<void>.delayed(Duration.zero);

    final state = container.read(onboardingNotifierProvider);
    expect(state.seenWelcome, isFalse);
    expect(state.seenWorldNumbers, isEmpty);
  });
}
