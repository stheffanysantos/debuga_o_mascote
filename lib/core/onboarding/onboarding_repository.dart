import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'onboarding_state.dart';
import 'shared_preferences_onboarding_repository.dart';

part 'onboarding_repository.g.dart';

/// Abstração sobre onde "o jogador já viu isso antes" é persistido — mesmo
/// espírito de `ProgressRepository`/`LeaderboardRepository`: permite um fake
/// nos testes. `fetch()` devolve `null` quando não há nada salvo ainda ou a
/// infraestrutura está indisponível (nunca lança) — nesse caso o jogo segue
/// com o `OnboardingState` vazio padrão (mostra tudo de novo, pior caso
/// aceitável, nunca travar o app).
///
/// Device-local (`shared_preferences`), não Firestore/conta — "já vi o
/// tutorial" é sobre este navegador/aparelho, não precisa de login nem
/// sincronizar entre dispositivos (diferente de `ProgressState`, que é
/// progresso de jogo de verdade). Ver `.claude/memory/decisions.md`.
abstract class OnboardingRepository {
  Future<OnboardingState?> fetch();
  Future<void> save(OnboardingState state);
}

@Riverpod(keepAlive: true)
OnboardingRepository onboardingRepository(Ref ref) => SharedPreferencesOnboardingRepository();
