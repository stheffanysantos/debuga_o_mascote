import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/models/predict_output_level.dart';

/// Garante que toda fase de `world3Levels` (Mundo 3, "Preveja a Saída") tem
/// dados consistentes — ver `.claude/reviews/checklist-level.md`. Como não
/// existe um motor de execução aqui (a "resposta certa" é um dado fixo do
/// modelo, não algo derivado de rodar o código), a checagem é estrutural:
/// índice de opção certa dentro dos limites, sem opções vazias, e nenhum
/// texto duplicado dentro da mesma fase.
void main() {
  test('world3Levels tem 12 fases com ids únicos e estáveis', () {
    expect(world3Levels.length, 12);
    expect(world3Levels.map((l) => l.id).toSet().length, 12);
    expect(world3Levels.every((l) => l.world == 3), isTrue);
    for (var i = 0; i < world3Levels.length; i++) {
      expect(world3Levels[i].number, i + 1);
    }
  });

  for (final level in world3Levels) {
    test('${level.id} (Fase ${level.number}): dados consistentes', () {
      expect(level.code, isNotEmpty, reason: 'Fase ${level.number}: code não pode ser vazio');
      expect(level.question, isNotEmpty, reason: 'Fase ${level.number}: question não pode ser vazia');
      expect(level.options.length, inInclusiveRange(2, 3), reason: 'Fase ${level.number}: 2-3 opções');
      expect(level.options.toSet().length, level.options.length, reason: 'Fase ${level.number}: opções não podem se repetir');
      expect(
        level.correctOptionIndex,
        inInclusiveRange(0, level.options.length - 1),
        reason: 'Fase ${level.number}: correctOptionIndex fora dos limites de options',
      );
      expect(level.explanation, isNotEmpty, reason: 'Fase ${level.number}: explanation não pode ser vazia');
    });
  }

  test('correctOptionIndex varia entre fases (não é sempre a mesma posição)', () {
    final indices = world3Levels.map((l) => l.correctOptionIndex).toSet();
    expect(indices.length, greaterThan(1));
  });
}
