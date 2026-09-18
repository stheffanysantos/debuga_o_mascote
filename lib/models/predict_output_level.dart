import 'code_line.dart';
import 'game_level.dart';

/// Uma fase do Mundo 5 ("Preveja a Saída"): o jogador lê um trecho de código
/// real (curto, já na ordem certa — sem embaralhar/editar) e prevê o
/// resultado por múltipla escolha. Ver `.claude/docs/GAME_DESIGN.md`, seção
/// "Mundo 5 — Preveja a Saída". Mesma família de "veredito único" do Mundo 7
/// ("Modo Debug") — sem "quase certo" — mas mais simples: só leitura, sem
/// reordenar/editar nada.
class PredictOutputLevel implements GameLevel {
  @override
  final String id;
  final int world;

  /// Posição da fase dentro do mundo (1-12) — usada na Seleção de Fases e
  /// no cabeçalho da Gameplay ("FASE N").
  final int number;

  /// Instrução curta mostrada no cabeçalho da Gameplay (ex.: "Duas
  /// variáveis").
  final String title;

  /// O trecho de código, já na ordem certa — mostrado só para leitura
  /// (nunca embaralhado/editável, diferente do `reorder` do Mundo 7).
  final List<CodeLine> code;

  /// A pergunta mostrada abaixo do código (ex.: "O que aparece na tela?").
  final String question;

  /// 2-3 respostas possíveis, mostradas como opções tocáveis.
  final List<String> options;

  /// Índice 0-based da resposta certa em `options`.
  final int correctOptionIndex;

  /// Frase curta explicando o resultado — mostrada sempre (ganhou ou
  /// perdeu), mesmo papel de `CodePuzzleLevel.bugExplanation` no Mundo 7.
  final String explanation;

  const PredictOutputLevel({
    required this.id,
    required this.world,
    required this.number,
    required this.title,
    required this.code,
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });
}

/// As 12 fases do Mundo 5 ("Preveja a Saída"): começa com leitura direta de
/// variáveis/expressões, passa por `if`/`else`, chega em laços (`for`/
/// `while`) e fecha combinando laço + condicional. Progressão pensada como
/// primeiro passo da Trilha 3 ("Modo Programador") — depois da Trilha 2
/// ("Construtores de Lógica", programação em blocos sem sintaxe) — o
/// jogador já precisa "rodar o código na cabeça", mas nunca precisa editar
/// nada. Dados consistentes verificados em
/// `test/game/predict_output_catalog_test.dart`.
final world5Levels = <PredictOutputLevel>[
  PredictOutputLevel(
    id: 'world5_level1',
    world: 5,
    number: 1,
    title: 'Primeira leitura',
    code: const [
      CodeLine('int x = 4;'),
      CodeLine('print(x + 1);'),
    ],
    question: 'O que aparece na tela?',
    options: const ['5', '4', 'x + 1'],
    correctOptionIndex: 0,
    explanation: 'x vale 4; x + 1 é 5.',
  ),
  PredictOutputLevel(
    id: 'world5_level2',
    world: 5,
    number: 2,
    title: 'Duas variáveis',
    code: const [
      CodeLine('int a = 2;'),
      CodeLine('int b = 5;'),
      CodeLine('print(a + b);'),
    ],
    question: 'O que aparece na tela?',
    options: const ['25', '2b', '7'],
    correctOptionIndex: 2,
    explanation: 'a + b = 2 + 5 = 7.',
  ),
  PredictOutputLevel(
    id: 'world5_level3',
    world: 5,
    number: 3,
    title: 'Comparação simples',
    code: const [
      CodeLine('int idade = 15;'),
      CodeLine('print(idade >= 18);'),
    ],
    question: 'O que aparece na tela?',
    options: const ['true', 'false', '15'],
    correctOptionIndex: 1,
    explanation: '15 não é maior ou igual a 18 — a comparação é false.',
  ),
  PredictOutputLevel(
    id: 'world5_level4',
    world: 5,
    number: 4,
    title: 'Se, então',
    code: const [
      CodeLine('int nota = 8;'),
      CodeLine('if (nota >= 6) {'),
      CodeLine("  print('Aprovado');"),
      CodeLine('} else {'),
      CodeLine("  print('Reprovado');"),
      CodeLine('}'),
    ],
    question: 'O que é impresso?',
    options: const ['Aprovado', 'Reprovado', 'Nada'],
    correctOptionIndex: 0,
    explanation: 'nota (8) é maior ou igual a 6 — entra no if.',
  ),
  PredictOutputLevel(
    id: 'world5_level5',
    world: 5,
    number: 5,
    title: 'Um laço fixo',
    code: const [
      CodeLine('for (int i = 0; i < 3; i++) {'),
      CodeLine("  print('Oi');"),
      CodeLine('}'),
    ],
    question: 'Quantas vezes "Oi" aparece?',
    options: const ['2', '4', '3'],
    correctOptionIndex: 2,
    explanation: 'O laço roda com i = 0, 1, 2 (para quando i deixa de ser menor que 3) — 3 vezes.',
  ),
  PredictOutputLevel(
    id: 'world5_level6',
    world: 5,
    number: 6,
    title: 'Somando no laço',
    code: const [
      CodeLine('int total = 0;'),
      CodeLine('for (int i = 1; i <= 3; i++) {'),
      CodeLine('  total = total + i;'),
      CodeLine('}'),
      CodeLine('print(total);'),
    ],
    question: 'O que aparece na tela?',
    options: const ['3', '6', '1'],
    correctOptionIndex: 1,
    explanation: '1 + 2 + 3 = 6.',
  ),
  PredictOutputLevel(
    id: 'world5_level7',
    world: 5,
    number: 7,
    title: 'Enquanto (while)',
    code: const [
      CodeLine('int c = 0;'),
      CodeLine('while (c < 4) {'),
      CodeLine('  c = c + 1;'),
      CodeLine('}'),
      CodeLine('print(c);'),
    ],
    question: 'O que aparece na tela?',
    options: const ['4', '3', '0'],
    correctOptionIndex: 0,
    explanation: 'O laço soma 1 até c deixar de ser menor que 4 — para com c = 4.',
  ),
  PredictOutputLevel(
    id: 'world5_level8',
    world: 5,
    number: 8,
    title: 'Duas condições',
    code: const [
      CodeLine('int nota = 5;'),
      CodeLine('if (nota >= 7) {'),
      CodeLine("  print('Ótimo');"),
      CodeLine('} else if (nota >= 5) {'),
      CodeLine("  print('Bom');"),
      CodeLine('} else {'),
      CodeLine("  print('Ruim');"),
      CodeLine('}'),
    ],
    question: 'O que aparece na tela?',
    options: const ['Ótimo', 'Ruim', 'Bom'],
    correctOptionIndex: 2,
    explanation: 'nota (5) não é maior ou igual a 7, mas é maior ou igual a 5 — cai no "else if".',
  ),
  PredictOutputLevel(
    id: 'world5_level9',
    world: 5,
    number: 9,
    title: 'Contagem condicional',
    code: const [
      CodeLine('int total = 0;'),
      CodeLine('for (int i = 1; i <= 5; i++) {'),
      CodeLine('  if (i % 2 == 0) {'),
      CodeLine('    total = total + 1;'),
      CodeLine('  }'),
      CodeLine('}'),
      CodeLine('print(total);'),
    ],
    question: 'O que aparece na tela?',
    options: const ['3', '2', '5'],
    correctOptionIndex: 1,
    explanation: '2 e 4 são pares — total = 2.',
  ),
  PredictOutputLevel(
    id: 'world5_level10',
    world: 5,
    number: 10,
    title: 'Função com retorno',
    code: const [
      CodeLine('int dobro(int n) {'),
      CodeLine('  return n * 2;'),
      CodeLine('}'),
      CodeLine('print(dobro(4));'),
    ],
    question: 'O que aparece na tela?',
    options: const ['8', '4', '2'],
    correctOptionIndex: 0,
    explanation: 'dobro(4) devolve 4 * 2 = 8.',
  ),
  PredictOutputLevel(
    id: 'world5_level11',
    world: 5,
    number: 11,
    title: 'Lista e soma',
    code: const [
      CodeLine('List<int> numeros = [2, 4, 6];'),
      CodeLine('int soma = 0;'),
      CodeLine('for (int n in numeros) {'),
      CodeLine('  soma = soma + n;'),
      CodeLine('}'),
      CodeLine('print(soma);'),
    ],
    question: 'O que aparece na tela?',
    options: const ['8', '6', '12'],
    correctOptionIndex: 2,
    explanation: '2 + 4 + 6 = 12.',
  ),
  PredictOutputLevel(
    id: 'world5_level12',
    world: 5,
    number: 12,
    title: 'Tudo junto',
    code: const [
      CodeLine('int total = 0;'),
      CodeLine('for (int i = 1; i <= 4; i++) {'),
      CodeLine('  if (i != 2) {'),
      CodeLine('    total = total + i;'),
      CodeLine('  }'),
      CodeLine('}'),
      CodeLine('print(total);'),
    ],
    question: 'O que aparece na tela?',
    options: const ['10', '8', '7'],
    correctOptionIndex: 1,
    explanation: 'Soma 1, 3 e 4 (pula o 2 pelo "if") = 8.',
  ),
];
