/// Conteúdo textual do tutorial, mostrado por `TutorialScreen`
/// (`lib/screens/tutorial_screen.dart`). Texto já revisado contra as regras
/// reais de cada motor — não alterar sem confirmar com o usuário (ver
/// `.claude/memory/decisions.md`). Se o texto de um slide mudar, a narração
/// gerada em `assets/audio/tutorial/` (`tool/generate_tutorial_narration.py`)
/// precisa ser regerada — os dois ficam dessincronizados senão.
class TutorialSlide {
  /// `null` num slide de continuação (só o corpo, sem título novo).
  final String? title;
  final String body;

  const TutorialSlide({this.title, required this.body});
}

/// Mostrado uma única vez, antes do tutorial do primeiro Mundo que o
/// jogador tocar (ver `Onboarding.hasSeenIntro`) — explica o conceito geral
/// de "programar" antes de entrar nas regras de um Mundo específico.
const programmingConceptSlides = <TutorialSlide>[
  TutorialSlide(
    title: 'O que é programar?',
    body: 'Programar é dar instruções, uma de cada vez, pra alguém seguir certinho.',
  ),
  TutorialSlide(
    body: 'Cada instrução é um Bloco — tipo uma peça de encaixe.',
  ),
  TutorialSlide(
    body: 'Você junta os Blocos em ordem pra montar um Programa.',
  ),
  TutorialSlide(
    body: 'Quem executa o Programa só faz exatamente o que você mandou. A ordem importa!',
  ),
  TutorialSlide(
    body: 'Errou? Sem problema — ajuste o Programa e tente de novo.',
  ),
];

/// Caminho (relativo a `assets/audio/`) do arquivo de narração de um slide
/// do tutorial — `null` se esse tipo de slide não tiver narração gerada
/// (hoje todos têm; a checagem de existência real do asset é feita ao
/// tentar tocar, ver `AppSounds.playNarration`). Índice é a posição do
/// slide dentro da sua própria lista (`programmingConceptSlides` ou
/// `worldTutorials[worldNumber]`), não da lista combinada mostrada na tela.
String _introNarrationAsset(int index) => 'tutorial/intro_$index.mp3';

String _worldNarrationAsset(int worldNumber, int index) => 'tutorial/world${worldNumber}_$index.mp3';

/// Monta a lista combinada de slides (intro geral + slides do Mundo) e a
/// lista paralela de trilhas de narração, na ordem em que `TutorialScreen`
/// deve mostrar/tocar — usado por `WorldSelectScreen`/telas de Seleção de
/// Fases para não duplicar essa composição em cada chamador.
({List<TutorialSlide> slides, List<String> narrationAssets}) tutorialSlidesFor(int worldNumber, {required bool includeIntro}) {
  final slides = <TutorialSlide>[];
  final narrationAssets = <String>[];
  if (includeIntro) {
    for (var i = 0; i < programmingConceptSlides.length; i++) {
      slides.add(programmingConceptSlides[i]);
      narrationAssets.add(_introNarrationAsset(i));
    }
  }
  final worldSlides = worldTutorials[worldNumber] ?? const [];
  for (var i = 0; i < worldSlides.length; i++) {
    slides.add(worldSlides[i]);
    narrationAssets.add(_worldNarrationAsset(worldNumber, i));
  }
  return (slides: slides, narrationAssets: narrationAssets);
}

const worldTutorials = <int, List<TutorialSlide>>{
  1: [
    TutorialSlide(title: 'Como jogar: Labirinto', body: 'Vamos aprender rapidinho:'),
    TutorialSlide(body: 'Monte um Programa tocando os blocos: Andar, Virar ← / →, Repetir 3×.'),
    TutorialSlide(body: 'Aperte Play para ver o Mascote seguir seus comandos, passo a passo.'),
    TutorialSlide(body: 'Chegue exatamente no alvo </> para vencer a fase.'),
  ],
  2: [
    TutorialSlide(title: 'Como jogar: Esteira de Bugs', body: 'Vamos aprender rapidinho:'),
    TutorialSlide(body: "Os itens chegam um de cada vez. Monte blocos 'Se [cor] → Caixa' para classificar certo."),
    TutorialSlide(body: "'Repetir 3×' repete um número fixo de vezes; 'Enquanto [cor]' repete até a cor mudar."),
    TutorialSlide(body: 'Classifique toda a fila certinho para vencer — errar a cor é falha.'),
  ],
  3: [
    TutorialSlide(title: 'Como jogar: Modo Debug', body: 'Vamos aprender rapidinho:'),
    TutorialSlide(body: "Em 'Reordenar', toque nas linhas de código na ordem certa."),
    TutorialSlide(body: "Em 'Achar o Bug', toque na linha que tem o erro."),
    TutorialSlide(body: "Confirme sua resposta — aqui não existe 'quase certo', só certo ou errado."),
  ],
};

/// Mostrada uma única vez (`Onboarding.hasSeenRecap`), quando o jogador
/// termina a última fase pendente de um Mundo — liga os 3 mundos numa
/// progressão pedagógica clara antes de voltar para a Seleção de Mundo. Ver
/// `.claude/memory/decisions.md`.
const worldRecapSlides = <int, List<TutorialSlide>>{
  1: [
    TutorialSlide(
      title: 'Mundo 1 completo!',
      body: 'Você aprendeu Sequência, Repetir e Virar. Agora vem a Decisão — no próximo mundo, o Mascote aprende a escolher!',
    ),
  ],
  2: [
    TutorialSlide(
      title: 'Mundo 2 completo!',
      body: 'Você aprendeu Se e Enquanto — decisão e repetição condicional. Agora vem o mais parecido com programar de verdade: ler e consertar código!',
    ),
  ],
  3: [
    TutorialSlide(
      title: 'Você terminou os 3 Mundos!',
      body: 'Sequência, decisão, repetição e leitura de código — você já pensa como um programador!',
    ),
  ],
};

String _recapNarrationAsset(int worldNumber, int index) => 'tutorial/recap${worldNumber}_$index.mp3';

/// Monta os slides + narração da recapitulação de um Mundo — mesmo espírito
/// de `tutorialSlidesFor`, mas sem a opção de incluir a intro geral (a
/// recapitulação nunca reexplica "o que é programar").
({List<TutorialSlide> slides, List<String> narrationAssets}) recapSlidesFor(int worldNumber) {
  final slides = worldRecapSlides[worldNumber] ?? const [];
  final narrationAssets = [for (var i = 0; i < slides.length; i++) _recapNarrationAsset(worldNumber, i)];
  return (slides: slides, narrationAssets: narrationAssets);
}
