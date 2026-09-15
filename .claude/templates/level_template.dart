// Esqueleto de uma fase (Level). Ver .claude/docs/GAME_DESIGN.md para as regras
// e .claude/reviews/checklist-level.md antes de considerar a fase pronta.

import 'package:debuga_o_mascote/models/level.dart';

// Exemplo: fase minúscula, sem paredes, 2 casas até o alvo.
final exampleLevel = Level(
  id: 'world1_level1',
  world: 1,
  // grid 6x6: true = parede, false = livre.
  grid: List.generate(6, (_) => List.filled(6, false)),
  start: LevelStart(x: 0, y: 0, direction: Direction.right),
  goal: LevelGoal(x: 2, y: 0),
  maxBlocks: 8,
  starThresholds: const StarThresholds(threeStars: 2, twoStars: 4),
);
