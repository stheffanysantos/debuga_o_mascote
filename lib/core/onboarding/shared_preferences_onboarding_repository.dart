import 'package:shared_preferences/shared_preferences.dart';

import 'onboarding_repository.dart';
import 'onboarding_state.dart';

/// Guarda `OnboardingState` no `shared_preferences` do aparelho — mesmo
/// pacote já usado por `LocalLeaderboardRepository`. `fetch()`/`save()`
/// nunca lançam (try/catch engolindo qualquer erro de plataforma/storage),
/// mesmo princípio de nunca deixar infraestrutura travar o jogo.
class SharedPreferencesOnboardingRepository implements OnboardingRepository {
  static const _seenWelcomeKey = 'onboarding_seen_welcome';
  static const _seenWorldsKey = 'onboarding_seen_worlds';
  static const _seenRecapWorldsKey = 'onboarding_seen_recap_worlds';

  @override
  Future<OnboardingState?> fetch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey(_seenWelcomeKey)) return null;
      return OnboardingState(
        seenWelcome: prefs.getBool(_seenWelcomeKey) ?? false,
        seenWorldNumbers: (prefs.getStringList(_seenWorldsKey) ?? const []).map(int.parse).toSet(),
        seenRecapWorldNumbers: (prefs.getStringList(_seenRecapWorldsKey) ?? const []).map(int.parse).toSet(),
      );
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> save(OnboardingState state) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_seenWelcomeKey, state.seenWelcome);
      await prefs.setStringList(_seenWorldsKey, state.seenWorldNumbers.map((n) => n.toString()).toList());
      await prefs.setStringList(_seenRecapWorldsKey, state.seenRecapWorldNumbers.map((n) => n.toString()).toList());
    } catch (_) {
      // Nunca deve travar o fluxo do jogador por falha de storage.
    }
  }
}
