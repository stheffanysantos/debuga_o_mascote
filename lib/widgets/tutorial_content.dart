/// Conteúdo textual do tutorial, mostrado por `TutorialView`
/// (`lib/features/tutorial/presentation/tutorial_view.dart`). Texto já
/// revisado contra as regras reais de cada motor — não alterar sem
/// confirmar com o usuário (ver `.claude/memory/decisions.md`). Se o texto
/// de um slide mudar, a narração gerada em `assets/audio/tutorial/`
/// (`tool/generate_tutorial_narration.py`) precisa ser regerada — os dois
/// ficam dessincronizados senão.
class TutorialSlide {
  /// `null` num slide de continuação (só o corpo, sem título novo).
  final String? title;
  final String body;

  /// Arte mostrada acima do texto — o Mascote por padrão (`worldTutorials`/
  /// `worldRecapSlides`); `welcomeSlides` usa a abelhinha em 2 dos 3 slides
  /// (`assets/images/leaderboard_bee.png`), pedido explícito do usuário.
  final String imageAsset;

  const TutorialSlide({this.title, required this.body, this.imageAsset = 'assets/images/mascot_tutorial.png'});
}

String _worldNarrationAsset(int worldNumber, int index) => 'tutorial/world${worldNumber}_$index.mp3';

/// Monta os slides + narração do tutorial de um Mundo — usado por
/// `WorldSelectView`/telas de Seleção de Fases para não duplicar essa
/// composição em cada chamador.
({List<TutorialSlide> slides, List<String> narrationAssets}) tutorialSlidesFor(int worldNumber) {
  final worldSlides = worldTutorials[worldNumber] ?? const [];
  final narrationAssets = [for (var i = 0; i < worldSlides.length; i++) _worldNarrationAsset(worldNumber, i)];
  return (slides: worldSlides, narrationAssets: narrationAssets);
}

/// Intro de boas-vindas — mostrado uma única vez (`OnboardingState.seenWelcome`),
/// ao tocar "JOGAR" na Splash pela 1ª vez, antes de entrar na Seleção de
/// Mundo. Explica o que é o jogo e como ele funciona (2 slides com a
/// abelhinha, que se apresenta como "Libug") e termina com o Mascote
/// ("Lili") pedindo pro jogador escolher entre criar conta, entrar numa
/// conta existente, ou jogar sem conta (`WelcomeView`, que mostra os
/// botões de escolha no lugar do botão "Próximo" no último slide).
/// Substitui o antigo `programmingConceptSlides` (mostrado por Mundo) —
/// pedido explícito do usuário, ver `.claude/memory/decisions.md`.
/// Sem narração gerada ainda (`TutorialView` tolera `narrationAssets`
/// vazio, só não toca nada).
const welcomeSlides = <TutorialSlide>[
  TutorialSlide(
    title: 'Oi, eu sou o Libug!',
    body: 'Sou a abelhinha guia do jogo — vou te acompanhar por aqui! Debuga o Mascote é um mini-jogo de lógica de programação: você ajuda o Mascote a resolver desafios usando comandos, como um programador de verdade.',
    imageAsset: 'assets/images/leaderboard_bee.png',
  ),
  TutorialSlide(
    body: 'Em cada mundo você monta uma sequência de comandos e aperta Play pra ver o que acontece. Errou? Sem problema — aqui errar faz parte de aprender.',
    imageAsset: 'assets/images/leaderboard_bee.png',
  ),
  TutorialSlide(
    title: 'Oi, eu sou a Lili!',
    body: 'Eu sou a mascote do jogo! Vamos começar? Você pode criar uma conta pra salvar seu progresso e aparecer no Placar, entrar numa conta que já tem, ou jogar sem se cadastrar — do jeito que preferir.',
  ),
];

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
    TutorialSlide(title: 'Como jogar: Preveja a Saída', body: 'Vamos aprender rapidinho:'),
    TutorialSlide(body: 'Você vai ler um trecho de código de verdade, já pronto — sem montar nada.'),
    TutorialSlide(body: 'Depois de ler, escolha entre as opções qual é o resultado.'),
    TutorialSlide(body: "Confirme sua resposta — aqui não existe 'quase certo', só certo ou errado."),
  ],
  4: [
    TutorialSlide(title: 'Como jogar: Complete o Código', body: 'Vamos aprender rapidinho:'),
    TutorialSlide(body: 'O código tem um espaço em branco no lugar de uma linha.'),
    TutorialSlide(body: 'Toque na linha, entre as opções, que completa certo o espaço em branco.'),
    TutorialSlide(body: "Confirme sua resposta — aqui não existe 'quase certo', só certo ou errado."),
  ],
  5: [
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
      body: 'Você aprendeu Se e Enquanto — decisão e repetição condicional. Agora vem o mais parecido com programar de verdade: ler código!',
    ),
  ],
  3: [
    TutorialSlide(
      title: 'Trilha 1 completa!',
      body: 'Você já lê código de verdade e prevê o resultado. Agora vem a Trilha Avançada — lá você vai completar e depurar código de verdade!',
    ),
  ],
  4: [
    TutorialSlide(
      title: 'Mundo 4 completo!',
      body: 'Você já sabe completar código de verdade. Agora vem o Modo Debug — juntar tudo: reordenar e achar bugs em código real!',
    ),
  ],
  5: [
    TutorialSlide(
      title: 'Você terminou os 5 Mundos!',
      body: 'Sequência, decisão, repetição, leitura, escrita e depuração de código — você já pensa como um programador!',
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
