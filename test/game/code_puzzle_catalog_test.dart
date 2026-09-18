import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/game/code_puzzle_checker.dart';
import 'package:debuga_o_mascote/models/code_puzzle_level.dart';

/// Garante que toda fase de `world7Levels` (Mundo 7) tem dados consistentes — ver
/// `.claude/reviews/checklist-level.md`. Diferente de
/// `level_catalog_test.dart`/`conveyor_level_catalog_test.dart` (que rodam
/// um `hintProgram` contra um motor passo a passo), aqui a "solução" de
/// cada fase é o próprio `correctOrder`/`buggyLineIndex` guardado no
/// modelo — não existe um Programa separado a expandir/executar.
void main() {
  test('world7Levels tem 12 fases com ids únicos e estáveis', () {
    expect(world7Levels.length, 12);
    expect(world7Levels.map((l) => l.id).toSet().length, 12);
    expect(world7Levels.every((l) => l.world == 7), isTrue);
    for (var i = 0; i < world7Levels.length; i++) {
      expect(world7Levels[i].number, i + 1);
    }
  });

  for (final level in world7Levels) {
    test('${level.id} (Fase ${level.number}): dados consistentes com o tipo declarado', () {
      switch (level.type) {
        case CodePuzzleType.reorder:
          expect(level.correctOrder, isNotEmpty, reason: 'Fase ${level.number}: reorder precisa de correctOrder não vazio');
          expect(level.codeWithBug, isEmpty, reason: 'Fase ${level.number}: reorder não deveria ter codeWithBug');
          expect(level.buggyLineIndex, -1, reason: 'Fase ${level.number}: reorder não deveria ter buggyLineIndex');
          expect(level.bugExplanation, isEmpty, reason: 'Fase ${level.number}: reorder não deveria ter bugExplanation');
          expect(
            level.groupOf.length,
            level.correctOrder.length,
            reason: 'Fase ${level.number}: groupOf precisa ter o mesmo tamanho de correctOrder',
          );
          for (var i = 1; i < level.groupOf.length; i++) {
            expect(
              level.groupOf[i],
              greaterThanOrEqualTo(level.groupOf[i - 1]),
              reason: 'Fase ${level.number}: groupOf precisa ser não-decrescente',
            );
          }

          // A própria ordem correta, tocada na sequência certa, precisa ser
          // aceita pelo checker (garante que o dado da fase é solucionável).
          expect(checkReorder(level.correctOrder, level.correctOrder, groupOf: level.groupOf), isTrue);
          break;
        case CodePuzzleType.findBug:
          expect(level.codeWithBug, isNotEmpty, reason: 'Fase ${level.number}: findBug precisa de codeWithBug não vazio');
          expect(level.correctOrder, isEmpty, reason: 'Fase ${level.number}: findBug não deveria ter correctOrder');
          expect(
            level.buggyLineIndex,
            inInclusiveRange(0, level.codeWithBug.length - 1),
            reason: 'Fase ${level.number}: buggyLineIndex fora dos limites de codeWithBug',
          );
          expect(level.bugExplanation, isNotEmpty, reason: 'Fase ${level.number}: findBug precisa de bugExplanation não vazia');

          expect(checkFindBug(level.buggyLineIndex, level.buggyLineIndex), isTrue);
          break;
      }
    });
  }

  test('mistura reorder/findBug a partir da metade das fases', () {
    final firstHalf = world7Levels.take(6);
    expect(firstHalf.every((l) => l.type == CodePuzzleType.reorder), isTrue);

    final secondHalf = world7Levels.skip(6);
    expect(secondHalf.any((l) => l.type == CodePuzzleType.findBug), isTrue);
  });
}
