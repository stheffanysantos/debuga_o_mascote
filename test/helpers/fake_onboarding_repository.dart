import 'package:debuga_o_mascote/core/onboarding/onboarding_repository.dart';
import 'package:debuga_o_mascote/core/onboarding/onboarding_state.dart';

/// [OnboardingRepository] de teste — guarda tudo em memória, sem tocar o
/// `shared_preferences` real (mesmo espírito de `FakeSoundPlayer`/
/// `FakeLeaderboardRepository`). `fetch()` devolve `null` até o 1º `save()`,
/// igual ao comportamento real de "nada salvo ainda".
class FakeOnboardingRepository implements OnboardingRepository {
  OnboardingState? saved;

  @override
  Future<OnboardingState?> fetch() async => saved;

  @override
  Future<void> save(OnboardingState state) async => saved = state;
}
