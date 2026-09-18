import 'code_line.dart';
import 'game_level.dart';

/// Os 2 tipos de puzzle do Mundo 7 ("Modo Debug") — ver
/// `.claude/docs/GAME_DESIGN.md`, seção "Mundo 7 — Modo Debug".
enum CodePuzzleType {
  /// O jogador reordena linhas embaralhadas até bater com `correctOrder`.
  reorder,

  /// O jogador toca a linha que acha que tem o erro em `codeWithBug`.
  findBug,
}

/// Uma fase do Mundo 7 ("Modo Debug"): ou um puzzle `reorder`, ou um puzzle
/// `findBug` — nunca os dois ao mesmo tempo. Mesma forma geral de
/// `Level`/`ConveyorLevel` (id/world/number/title), mas sem tabuleiro nem
/// fila de itens — o "estado" da fase é o próprio trecho de código.
///
/// Como os 2 tipos têm campos diferentes, `CodePuzzleLevel` usa um
/// construtor privado (`_`) mais 2 fábricas nomeadas (`.reorder`/
/// `.findBug`) que preenchem os campos do outro tipo com valores vazios/
/// sentinela — não é possível construir um `reorder` sem `correctOrder`
/// nem um `findBug` sem `buggyLineIndex`/`bugExplanation` (os `assert`s das
/// fábricas garantem isso em modo debug/teste).
class CodePuzzleLevel implements GameLevel {
  @override
  final String id;
  final int world;

  /// Posição da fase dentro do mundo (1-12) — usada na Seleção de Fases e
  /// no cabeçalho da Gameplay ("FASE N").
  final int number;

  /// Instrução curta mostrada no cabeçalho da Gameplay (ex.: "Ache o bug:
  /// soma").
  final String title;

  final CodePuzzleType type;

  /// A ordem certa das linhas — só preenchido quando `type == reorder`. A
  /// UI embaralha essas linhas na hora de montar a fase; este modelo nunca
  /// guarda uma ordem embaralhada fixa. Vazio em fases `findBug`.
  final List<CodeLine> correctOrder;

  /// Grupo de cada linha em `correctOrder` (mesmo índice) — só preenchido
  /// quando `type == reorder`. Linhas com o **mesmo** grupo podem aparecer
  /// em qualquer ordem relativa entre si (ex.: duas declarações
  /// independentes, ambas antes de uma linha que as usa); a ordem **entre**
  /// grupos diferentes continua obrigatória. Sempre não-decrescente (cada
  /// grupo ocupa um intervalo contíguo de `correctOrder`) — verificado por
  /// `assert` na fábrica. Quando não informado na fábrica, cada linha vira
  /// o seu próprio grupo sequencial (`0, 1, 2, ...`), preservando o
  /// comportamento antigo de ordem exata. Ver `checkReorder`
  /// (`lib/game/code_puzzle_checker.dart`) e `.claude/memory/decisions.md`.
  /// Vazio em fases `findBug`.
  final List<int> groupOf;

  /// Código completo, já na ordem certa, com 1 linha errada — só
  /// preenchido quando `type == findBug`. Vazio em fases `reorder`.
  final List<CodeLine> codeWithBug;

  /// Índice 0-based da linha errada em `codeWithBug` — só preenchido
  /// quando `type == findBug`. `-1` (sentinela, "não se aplica") em fases
  /// `reorder`.
  final int buggyLineIndex;

  /// Frase curta explicando o erro — mostrada sempre (não só na falha),
  /// equivalente a uma "Dica" permanente. Só preenchida quando
  /// `type == findBug`. String vazia em fases `reorder`.
  final String bugExplanation;

  const CodePuzzleLevel._({
    required this.id,
    required this.world,
    required this.number,
    required this.title,
    required this.type,
    required this.correctOrder,
    required this.groupOf,
    required this.codeWithBug,
    required this.buggyLineIndex,
    required this.bugExplanation,
  });

  /// Fase de reordenar linhas. `groupOf` (opcional) marca linhas
  /// intercambiáveis entre si — ver o campo `groupOf` acima. Sem ele,
  /// cada linha é seu próprio grupo (ordem exata, comportamento de sempre).
  factory CodePuzzleLevel.reorder({
    required String id,
    required int number,
    required String title,
    required List<CodeLine> correctOrder,
    List<int>? groupOf,
  }) {
    assert(correctOrder.isNotEmpty, 'reorder precisa de correctOrder não vazio ($id)');
    final resolvedGroupOf = groupOf ?? List<int>.generate(correctOrder.length, (i) => i);
    assert(
      resolvedGroupOf.length == correctOrder.length,
      'groupOf precisa ter o mesmo tamanho de correctOrder ($id)',
    );
    assert(
      _isNonDecreasing(resolvedGroupOf),
      'groupOf precisa ser não-decrescente — cada grupo ocupa um intervalo contíguo ($id)',
    );
    return CodePuzzleLevel._(
      id: id,
      world: 7,
      number: number,
      title: title,
      type: CodePuzzleType.reorder,
      correctOrder: correctOrder,
      groupOf: resolvedGroupOf,
      codeWithBug: const [],
      buggyLineIndex: -1,
      bugExplanation: '',
    );
  }

  /// Fase de achar o bug.
  factory CodePuzzleLevel.findBug({
    required String id,
    required int number,
    required String title,
    required List<CodeLine> codeWithBug,
    required int buggyLineIndex,
    required String bugExplanation,
  }) {
    assert(
      buggyLineIndex >= 0 && buggyLineIndex < codeWithBug.length,
      'buggyLineIndex fora dos limites de codeWithBug ($id)',
    );
    assert(bugExplanation.isNotEmpty, 'findBug precisa de bugExplanation não vazia ($id)');
    return CodePuzzleLevel._(
      id: id,
      world: 7,
      number: number,
      title: title,
      type: CodePuzzleType.findBug,
      correctOrder: const [],
      groupOf: const [],
      codeWithBug: codeWithBug,
      buggyLineIndex: buggyLineIndex,
      bugExplanation: bugExplanation,
    );
  }
}

bool _isNonDecreasing(List<int> values) {
  for (var i = 1; i < values.length; i++) {
    if (values[i] < values[i - 1]) return false;
  }
  return true;
}

/// As 12 fases do Mundo 7 ("Modo Debug"): começa só com `reorder` (mecânica
/// já conhecida de "tocar para montar" dos outros mundos) e mistura
/// `findBug` a partir da metade, com trechos cada vez um pouco mais
/// longos/sutis. Dados consistentes verificados em
/// `test/game/code_puzzle_catalog_test.dart`.
final world7Levels = <CodePuzzleLevel>[
  CodePuzzleLevel.reorder(
    id: 'world7_level1',
    number: 1,
    title: 'Primeira linha',
    correctOrder: const [
      CodeLine('int x = 5;'),
      CodeLine('print(x);'),
    ],
  ),
  CodePuzzleLevel.reorder(
    id: 'world7_level2',
    number: 2,
    title: 'Some dois números',
    correctOrder: const [
      CodeLine('int a = 2;'),
      CodeLine('int b = 3;'),
      CodeLine('print(a + b);'),
    ],
    // As duas declarações são independentes entre si (nenhuma usa a
    // outra) — só precisam vir antes do print. Achado real de testador:
    // a ordem entre elas é arbitrária, mas antes disso `checkReorder`
    // exigia a ordem exata (ver `.claude/memory/decisions.md`).
    groupOf: const [0, 0, 1],
  ),
  CodePuzzleLevel.reorder(
    id: 'world7_level3',
    number: 3,
    title: 'Uma decisão simples',
    correctOrder: const [
      CodeLine('if (idade >= 18) {'),
      CodeLine("  print('Maior de idade');"),
      CodeLine('}'),
    ],
  ),
  CodePuzzleLevel.reorder(
    id: 'world7_level4',
    number: 4,
    title: 'Se, senão',
    correctOrder: const [
      CodeLine('if (nota >= 6) {'),
      CodeLine("  print('Aprovado');"),
      CodeLine('} else {'),
      CodeLine("  print('Reprovado');"),
      CodeLine('}'),
    ],
  ),
  CodePuzzleLevel.reorder(
    id: 'world7_level5',
    number: 5,
    title: 'Repita 3 vezes',
    correctOrder: const [
      CodeLine('for (int i = 0; i < 3; i++) {'),
      CodeLine('  print(i);'),
      CodeLine('}'),
    ],
  ),
  CodePuzzleLevel.reorder(
    id: 'world7_level6',
    number: 6,
    title: 'Sua primeira função',
    correctOrder: const [
      CodeLine('int dobro(int n) {'),
      CodeLine('  return n * 2;'),
      CodeLine('}'),
    ],
  ),
  CodePuzzleLevel.findBug(
    id: 'world7_level7',
    number: 7,
    title: 'Ache o bug: soma',
    codeWithBug: const [
      CodeLine('int soma(int a, int b) {'),
      CodeLine('  return a - b;'),
      CodeLine('}'),
    ],
    buggyLineIndex: 1,
    bugExplanation: 'Uma função de soma deveria somar (a + b), não subtrair.',
  ),
  CodePuzzleLevel.reorder(
    id: 'world7_level8',
    number: 8,
    title: 'Some uma lista de números',
    correctOrder: const [
      CodeLine('int total = 0;'),
      CodeLine('for (int i = 1; i <= 5; i++) {'),
      CodeLine('  total = total + i;'),
      CodeLine('}'),
      CodeLine('print(total);'),
    ],
  ),
  CodePuzzleLevel.findBug(
    id: 'world7_level9',
    number: 9,
    title: 'Ache o bug: laço sem fim',
    codeWithBug: const [
      CodeLine('int contador = 0;'),
      CodeLine('while (contador < 5) {'),
      CodeLine('  print(contador);'),
      CodeLine('  contador = contador - 1;'),
      CodeLine('}'),
    ],
    buggyLineIndex: 3,
    bugExplanation: 'O contador nunca aumenta (usa -1 em vez de +1) — o laço nunca termina.',
  ),
  CodePuzzleLevel.findBug(
    id: 'world7_level10',
    number: 10,
    title: 'Ache o bug: par ou ímpar',
    codeWithBug: const [
      CodeLine('bool ehPar(int numero) {'),
      CodeLine('  if (numero % 2 == 0) {'),
      CodeLine('    return true;'),
      CodeLine('  } else {'),
      CodeLine('    return true;'),
      CodeLine('  }'),
      CodeLine('}'),
    ],
    buggyLineIndex: 4,
    bugExplanation: "No 'else' deveria retornar false — números ímpares não são pares.",
  ),
  CodePuzzleLevel.reorder(
    id: 'world7_level11',
    number: 11,
    title: 'Percorra uma lista',
    correctOrder: const [
      CodeLine('List<int> numeros = [1, 2, 3];'),
      CodeLine('int soma = 0;'),
      CodeLine('for (int n in numeros) {'),
      CodeLine('  soma = soma + n;'),
      CodeLine('}'),
      CodeLine('print(soma);'),
    ],
    // Declarar a lista e zerar "soma" são independentes entre si — só
    // precisam vir antes do laço que usa as duas. O resto do bloco (corpo
    // do laço, fechamento, print) continua em ordem rígida.
    groupOf: const [0, 0, 1, 2, 3, 4],
  ),
  CodePuzzleLevel.findBug(
    id: 'world7_level12',
    number: 12,
    title: 'Ache o bug: fatorial',
    codeWithBug: const [
      CodeLine('int fatorial(int n) {'),
      CodeLine('  int resultado = 1;'),
      CodeLine('  for (int i = 1; i <= n; i++) {'),
      CodeLine('    resultado = resultado + i;'),
      CodeLine('  }'),
      CodeLine('  return resultado;'),
      CodeLine('}'),
    ],
    buggyLineIndex: 3,
    bugExplanation: 'O fatorial multiplica os números (resultado * i), não soma.',
  ),
];
