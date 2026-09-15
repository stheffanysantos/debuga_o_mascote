/// Controla se o tutorial de um Mundo (e o slide geral de "o que é
/// programar") já foram vistos — sessão apenas (mesmo padrão de `Progress`,
/// `lib/models/progress.dart`; reinicia ao reabrir o app, decisão de
/// persistência entre sessões ainda em aberto, ver
/// `.claude/memory/decisions.md`). `WorldSelectScreen` consulta
/// `hasSeen(world.number)` antes de navegar; se `false`, empurra a
/// `TutorialScreen` do mundo em vez de navegar direto (incluindo os slides
/// de `programmingConceptSlides` só se `!hasSeenIntro`), e `markSeen`/
/// `markIntroSeen` são chamados quando o jogador termina o tutorial.
class Onboarding {
  Onboarding._();

  static final Onboarding instance = Onboarding._();

  final Set<int> _seenWorldNumbers = {};
  final Set<int> _seenRecapWorldNumbers = {};
  bool _seenIntro = false;

  bool hasSeen(int worldNumber) => _seenWorldNumbers.contains(worldNumber);

  void markSeen(int worldNumber) => _seenWorldNumbers.add(worldNumber);

  /// `true` depois que o jogador já viu os slides gerais de "o que é
  /// programar" (`programmingConceptSlides`, `lib/widgets/tutorial_content.dart`)
  /// pelo menos uma vez, em qualquer Mundo.
  bool get hasSeenIntro => _seenIntro;

  void markIntroSeen() => _seenIntro = true;

  /// `true` depois que o jogador já viu a recapitulação de fim daquele
  /// Mundo (`worldRecapSlides`, `lib/widgets/tutorial_content.dart`) — evita
  /// mostrar de novo se ele rejogar a última fase de um Mundo já completo.
  bool hasSeenRecap(int worldNumber) => _seenRecapWorldNumbers.contains(worldNumber);

  void markRecapSeen(int worldNumber) => _seenRecapWorldNumbers.add(worldNumber);

  /// Só para testes — volta ao estado inicial (nenhum Mundo/intro/recap visto).
  void reset() {
    _seenWorldNumbers.clear();
    _seenRecapWorldNumbers.clear();
    _seenIntro = false;
  }
}
