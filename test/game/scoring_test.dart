import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/game/scoring.dart';

void main() {
  test('usar o ótimo dá 3 estrelas e pontuação máxima', () {
    final result = computeScore(blocksUsed: 5, optimalBlocks: 5);
    expect(result.stars, 3);
    expect(result.points, 300);
  });

  test('1 bloco a mais que o ótimo ainda dá 3 estrelas', () {
    final result = computeScore(blocksUsed: 6, optimalBlocks: 5);
    expect(result.stars, 3);
  });

  test('3 blocos a mais dá 2 estrelas', () {
    final result = computeScore(blocksUsed: 8, optimalBlocks: 5);
    expect(result.stars, 2);
  });

  test('muitos blocos a mais dá 1 estrela e respeita o piso de pontos', () {
    final result = computeScore(blocksUsed: 20, optimalBlocks: 5);
    expect(result.stars, 1);
    expect(result.points, 50);
  });
}
