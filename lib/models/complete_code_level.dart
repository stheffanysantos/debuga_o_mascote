import 'code_line.dart';
import 'game_level.dart';

/// Uma fase do Mundo 4 ("Complete o Código"): o jogador vê um trecho de
/// código real com 1 linha em branco (`blankLineIndex`) e escolhe, por
/// múltipla escolha, qual das `options` completa certo. Ver
/// `.claude/docs/GAME_DESIGN.md`, seção "Mundo 4 — Complete o Código".
/// Mesma família de "veredito único" do Mundo 3 ("Preveja a Saída") e do
/// Mundo 5 ("Modo Debug") — mas aqui o jogador já escolhe uma linha de
/// código de verdade (não só uma resposta em texto livre), um degrau mais
/// perto de `reorder`/`findBug`.
class CompleteCodeLevel implements GameLevel {
  @override
  final String id;
  final int world;

  /// Posição da fase dentro do mundo (1-12) — usada na Seleção de Fases e
  /// no cabeçalho da Gameplay ("FASE N").
  final int number;

  /// Instrução curta mostrada no cabeçalho da Gameplay (ex.: "Complete a
  /// soma").
  final String title;

  /// Pergunta de contexto mostrada junto do trecho de código — mesmo papel
  /// de `PredictOutputLevel.question` (Mundo 3): sem ela, `title` sozinho
  /// não bastava para o jogador saber o que o código deveria fazer/exibir
  /// (achado real de testador), e a Fase 12 chegava a admitir mais de uma
  /// opção como "certa" sem um alvo explícito de saída. Sempre deixa
  /// explícito o comportamento/resultado esperado do código, de forma que
  /// só uma das `options` o satisfaça.
  final String question;

  /// O trecho de código completo e correto, incluindo a linha de
  /// `blankLineIndex` — a UI é responsável por não revelar essa linha antes
  /// de o jogador responder (mostra um espaço em branco no lugar dela).
  final List<CodeLine> code;

  /// Índice 0-based, em `code`, da linha que vira um espaço em branco na UI.
  final int blankLineIndex;

  /// 2-3 linhas candidatas para preencher o espaço em branco — uma delas
  /// (a de `correctOptionIndex`) precisa ter o mesmo texto de
  /// `code[blankLineIndex]`.
  final List<CodeLine> options;

  /// Índice 0-based da opção certa em `options`.
  final int correctOptionIndex;

  /// Frase curta explicando por que essa é a linha certa — mostrada sempre
  /// (ganhou ou perdeu), mesmo papel de `bugExplanation`/`explanation` dos
  /// Mundos 5/3.
  final String explanation;

  const CompleteCodeLevel({
    required this.id,
    required this.world,
    required this.number,
    required this.title,
    required this.question,
    required this.code,
    required this.blankLineIndex,
    required this.options,
    required this.correctOptionIndex,
    required this.explanation,
  });
}

/// As 12 fases do Mundo 4 ("Complete o Código"): reaproveita os mesmos
/// trechos/vocabulário do Mundo 5 ("Modo Debug" — `if`/`else`/`for`/
/// `while`/funções/listas), mas em vez de reordenar linhas embaralhadas ou
/// achar uma linha errada já colocada, o jogador escolhe qual linha
/// **preenche** um espaço em branco — ponte entre "ler código" (Mundo 3) e
/// "montar/consertar código" (Mundo 5, na Trilha 2). Dados consistentes
/// verificados em `test/game/complete_code_catalog_test.dart`.
final world4Levels = <CompleteCodeLevel>[
  CompleteCodeLevel(
    id: 'world4_level1',
    world: 4,
    number: 1,
    title: 'Complete a soma',
    question: 'Qual linha faz o código somar a e b, para que "soma" valha 7 e o print mostre 7?',
    code: const [
      CodeLine('int a = 3;'),
      CodeLine('int b = 4;'),
      CodeLine('int soma = a + b;'),
      CodeLine('print(soma);'),
    ],
    blankLineIndex: 2,
    options: const [
      CodeLine('int soma = a + b;'),
      CodeLine('int soma = a - b;'),
      CodeLine('int soma = a * b;'),
    ],
    correctOptionIndex: 0,
    explanation: 'Para somar dois números, usamos a + b.',
  ),
  CompleteCodeLevel(
    id: 'world4_level2',
    world: 4,
    number: 2,
    title: 'Complete a condição',
    question: 'Qual linha completa a condição para que o código imprima "Maior de idade" quando idade for 20?',
    code: const [
      CodeLine('int idade = 20;'),
      CodeLine('if (idade >= 18) {'),
      CodeLine("  print('Maior de idade');"),
      CodeLine('}'),
    ],
    blankLineIndex: 1,
    options: const [
      CodeLine('if (idade <= 18) {'),
      CodeLine('if (idade = 18) {'),
      CodeLine('if (idade >= 18) {'),
    ],
    correctOptionIndex: 2,
    explanation: 'Precisamos verificar se idade é maior ou igual a 18 — o sinal certo é >=.',
  ),
  CompleteCodeLevel(
    id: 'world4_level3',
    world: 4,
    number: 3,
    title: 'Complete o laço',
    question: 'Qual linha faz o laço imprimir 0, 1 e 2, nessa ordem?',
    code: const [
      CodeLine('for (int i = 0; i < 3; i++) {'),
      CodeLine('  print(i);'),
      CodeLine('}'),
    ],
    blankLineIndex: 0,
    options: const [
      CodeLine('for (int i = 0; i > 3; i++) {'),
      CodeLine('for (int i = 0; i < 3; i++) {'),
      CodeLine('for (int i = 3; i < 3; i++) {'),
    ],
    correctOptionIndex: 1,
    explanation: 'O laço precisa começar em 0 e continuar enquanto i for menor que 3.',
  ),
  CompleteCodeLevel(
    id: 'world4_level4',
    world: 4,
    number: 4,
    title: 'Complete o retorno',
    question: 'Qual linha faz a função devolver o dobro do número recebido?',
    code: const [
      CodeLine('int dobro(int n) {'),
      CodeLine('  return n * 2;'),
      CodeLine('}'),
    ],
    blankLineIndex: 1,
    options: const [
      CodeLine('  return n * 2;'),
      CodeLine('  return n + 2;'),
      CodeLine('  return n / 2;'),
    ],
    correctOptionIndex: 0,
    explanation: 'Dobro significa multiplicar por 2.',
  ),
  CompleteCodeLevel(
    id: 'world4_level5',
    world: 4,
    number: 5,
    title: 'Se, senão',
    question: 'Qual linha fecha o bloco do "se" e abre o do "senão", para que o código imprima "Reprovado" quando a nota for 4?',
    code: const [
      CodeLine('int nota = 4;'),
      CodeLine('if (nota >= 6) {'),
      CodeLine("  print('Aprovado');"),
      CodeLine('} else {'),
      CodeLine("  print('Reprovado');"),
      CodeLine('}'),
    ],
    blankLineIndex: 3,
    options: const [
      CodeLine('} else if {'),
      CodeLine('else {'),
      CodeLine('} else {'),
    ],
    correctOptionIndex: 2,
    explanation: '"} else {" fecha o bloco do if e abre o do senão, sem repetir a condição.',
  ),
  CompleteCodeLevel(
    id: 'world4_level6',
    world: 4,
    number: 6,
    title: 'Complete a soma no laço',
    question: 'Qual linha faz o laço somar todos os números de 1 a 5, para que o código imprima 15?',
    code: const [
      CodeLine('int total = 0;'),
      CodeLine('for (int i = 1; i <= 5; i++) {'),
      CodeLine('  total = total + i;'),
      CodeLine('}'),
      CodeLine('print(total);'),
    ],
    blankLineIndex: 2,
    options: const [
      CodeLine('  total = i;'),
      CodeLine('  total = total + i;'),
      CodeLine('  i = total + i;'),
    ],
    correctOptionIndex: 1,
    explanation: 'Para acumular a soma, cada volta soma i ao total já existente.',
  ),
  CompleteCodeLevel(
    id: 'world4_level7',
    world: 4,
    number: 7,
    title: 'Complete o enquanto',
    question: 'Qual linha faz o laço repetir enquanto o contador for menor que 5, parando exatamente quando chegar a 5?',
    code: const [
      CodeLine('int contador = 0;'),
      CodeLine('while (contador < 5) {'),
      CodeLine('  contador = contador + 1;'),
      CodeLine('}'),
    ],
    blankLineIndex: 1,
    options: const [
      CodeLine('while (contador < 5) {'),
      CodeLine('while (contador > 5) {'),
      CodeLine('if (contador < 5) {'),
    ],
    correctOptionIndex: 0,
    explanation: 'Queremos repetir enquanto contador for menor que 5 — "while", não "if" (que roda só uma vez).',
  ),
  CompleteCodeLevel(
    id: 'world4_level8',
    world: 4,
    number: 8,
    title: 'Complete a comparação',
    question: 'Qual linha faz a função devolver verdadeiro quando o número recebido for par?',
    code: const [
      CodeLine('bool ehPar(int numero) {'),
      CodeLine('  return numero % 2 == 0;'),
      CodeLine('}'),
    ],
    blankLineIndex: 1,
    options: const [
      CodeLine('  return numero % 2 == 1;'),
      CodeLine('  return numero / 2 == 0;'),
      CodeLine('  return numero % 2 == 0;'),
    ],
    correctOptionIndex: 2,
    explanation: 'Um número é par quando o resto da divisão por 2 é 0.',
  ),
  CompleteCodeLevel(
    id: 'world4_level9',
    world: 4,
    number: 9,
    title: 'Complete a lista',
    question: 'Qual linha declara corretamente a lista de números inteiros, para que o laço some 1 + 2 + 3 sem erro?',
    code: const [
      CodeLine('List<int> numeros = [1, 2, 3];'),
      CodeLine('int soma = 0;'),
      CodeLine('for (int n in numeros) {'),
      CodeLine('  soma = soma + n;'),
      CodeLine('}'),
    ],
    blankLineIndex: 0,
    options: const [
      CodeLine('int numeros = [1, 2, 3];'),
      CodeLine('List<int> numeros = [1, 2, 3];'),
      CodeLine('List numeros = 1, 2, 3;'),
    ],
    correctOptionIndex: 1,
    explanation: 'Uma lista de números inteiros se declara com "List<int>".',
  ),
  CompleteCodeLevel(
    id: 'world4_level10',
    world: 4,
    number: 10,
    title: 'Complete o "senão se"',
    question: 'Qual linha completa a segunda condição, para que o código imprima "Bom" quando a nota for 6?',
    code: const [
      CodeLine('int nota = 6;'),
      CodeLine('if (nota >= 7) {'),
      CodeLine("  print('Ótimo');"),
      CodeLine('} else if (nota >= 5) {'),
      CodeLine("  print('Bom');"),
      CodeLine('} else {'),
      CodeLine("  print('Ruim');"),
      CodeLine('}'),
    ],
    blankLineIndex: 3,
    options: const [
      CodeLine('} else if (nota >= 5) {'),
      CodeLine('} if (nota >= 5) {'),
      CodeLine('} else (nota >= 5) {'),
    ],
    correctOptionIndex: 0,
    explanation: '"else if" testa uma segunda condição só quando a primeira for falsa.',
  ),
  CompleteCodeLevel(
    id: 'world4_level11',
    world: 4,
    number: 11,
    title: 'Complete a função com parâmetros',
    question: 'Qual linha declara corretamente os parâmetros da função, para que soma(2, 3) funcione sem erro?',
    code: const [
      CodeLine('int soma(int a, int b) {'),
      CodeLine('  return a + b;'),
      CodeLine('}'),
    ],
    blankLineIndex: 0,
    options: const [
      CodeLine('int soma(a, b) {'),
      CodeLine('soma(int a, int b) {'),
      CodeLine('int soma(int a, int b) {'),
    ],
    correctOptionIndex: 2,
    explanation: 'Em Dart, toda função precisa declarar o tipo de cada parâmetro — "int a, int b".',
  ),
  CompleteCodeLevel(
    id: 'world4_level12',
    world: 4,
    number: 12,
    title: 'Complete o laço com condição',
    question: 'Qual linha faz o código somar os números de 1 a 3, pulando o 2, para que o print mostre exatamente 4?',
    code: const [
      CodeLine('int total = 0;'),
      CodeLine('for (int i = 1; i <= 3; i++) {'),
      CodeLine('  if (i != 2) {'),
      CodeLine('    total = total + i;'),
      CodeLine('  }'),
      CodeLine('}'),
      CodeLine('print(total);'),
    ],
    blankLineIndex: 2,
    options: const [
      CodeLine('  if (i == 2) {'),
      CodeLine('  if (i != 2) {'),
      CodeLine('  if (i = 2) {'),
    ],
    correctOptionIndex: 1,
    explanation: 'Queremos somar todos menos o 2 — por isso a condição usa "!=" (diferente de).',
  ),
];
