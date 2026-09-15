import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/game/leaderboard_scoring.dart';

void main() {
  test('mundo mais difícil rende mais pontos base', () {
    final world1 = computeSessionPoints(worldNumber: 1, elapsedSeconds: 500);
    final world2 = computeSessionPoints(worldNumber: 2, elapsedSeconds: 500);
    final world3 = computeSessionPoints(worldNumber: 3, elapsedSeconds: 500);
    expect(world1, lessThan(world2));
    expect(world2, lessThan(world3));
  });

  test('resolver rápido rende bônus de até 200 pontos', () {
    final instant = computeSessionPoints(worldNumber: 1, elapsedSeconds: 0);
    final slow = computeSessionPoints(worldNumber: 1, elapsedSeconds: 500);
    expect(instant - slow, 200);
  });

  test('bônus nunca fica negativo mesmo demorando muito', () {
    final points = computeSessionPoints(worldNumber: 1, elapsedSeconds: 100000);
    expect(points, 300); // só o base do Mundo 1, sem bônus
  });

  test('mundo desconhecido cai no base do Mundo 1, por segurança', () {
    final points = computeSessionPoints(worldNumber: 99, elapsedSeconds: 100000);
    expect(points, 300);
  });
}
