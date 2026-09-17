import 'package:freezed_annotation/freezed_annotation.dart';

part 'onboarding_state.freezed.dart';

/// Controla se o tutorial de um Mundo já foi visto, e se o jogador já passou
/// pelo intro de boas-vindas (`welcomeSlides`, `lib/widgets/tutorial_content.dart`)
/// — sessão apenas (reinicia ao reabrir o app, decisão de persistência entre
/// sessões ainda em aberto, ver `.claude/memory/decisions.md`).
@freezed
class OnboardingState with _$OnboardingState {
  const factory OnboardingState({
    @Default({}) Set<int> seenWorldNumbers,
    @Default({}) Set<int> seenRecapWorldNumbers,

    /// `true` depois que o jogador já viu o intro de boas-vindas (3 slides +
    /// escolha de conta) pelo menos uma vez, ao tocar "JOGAR" na Splash.
    @Default(false) bool seenWelcome,
  }) = _OnboardingState;

  const OnboardingState._();

  bool hasSeen(int worldNumber) => seenWorldNumbers.contains(worldNumber);

  /// `true` depois que o jogador já viu a recapitulação de fim daquele
  /// Mundo (`worldRecapSlides`, `lib/widgets/tutorial_content.dart`) — evita
  /// mostrar de novo se ele rejogar a última fase de um Mundo já completo.
  bool hasSeenRecap(int worldNumber) => seenRecapWorldNumbers.contains(worldNumber);
}
