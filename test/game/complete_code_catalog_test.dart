import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/models/complete_code_level.dart';

/// Garante que toda fase de `world4Levels` (Mundo 4, "Complete o Código")
/// tem dados consistentes — ver `.claude/reviews/checklist-level.md`. Mesmo
/// espírito de `predict_output_catalog_test.dart`: checagem estrutural, sem
/// motor de execução.
void main() {
  test('world4Levels tem 12 fases com ids únicos e estáveis', () {
    expect(world4Levels.length, 12);
    expect(world4Levels.map((l) => l.id).toSet().length, 12);
    expect(world4Levels.every((l) => l.world == 4), isTrue);
    for (var i = 0; i < world4Levels.length; i++) {
      expect(world4Levels[i].number, i + 1);
    }
  });

  for (final level in world4Levels) {
    test('${level.id} (Fase ${level.number}): dados consistentes', () {
      expect(level.code, isNotEmpty, reason: 'Fase ${level.number}: code não pode ser vazio');
      expect(
        level.blankLineIndex,
        inInclusiveRange(0, level.code.length - 1),
        reason: 'Fase ${level.number}: blankLineIndex fora dos limites de code',
      );
      expect(level.options.length, inInclusiveRange(2, 3), reason: 'Fase ${level.number}: 2-3 opções');
      expect(
        level.options.map((o) => o.text).toSet().length,
        level.options.length,
        reason: 'Fase ${level.number}: opções não podem se repetir',
      );
      expect(
        level.correctOptionIndex,
        inInclusiveRange(0, level.options.length - 1),
        reason: 'Fase ${level.number}: correctOptionIndex fora dos limites de options',
      );
      // A opção certa precisa ter o mesmo texto da linha real que ela
      // preenche — garante que o "gabarito" bate com o código de verdade.
      expect(
        level.options[level.correctOptionIndex].text,
        level.code[level.blankLineIndex].text,
        reason: 'Fase ${level.number}: a opção certa precisa bater com a linha real do espaço em branco',
      );
      expect(level.explanation, isNotEmpty, reason: 'Fase ${level.number}: explanation não pode ser vazia');
    });
  }

  test('correctOptionIndex varia entre fases (não é sempre a mesma posição)', () {
    final indices = world4Levels.map((l) => l.correctOptionIndex).toSet();
    expect(indices.length, greaterThan(1));
  });
}
