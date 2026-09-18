import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/game/code_puzzle_checker.dart';
import 'package:debuga_o_mascote/game/code_puzzle_scoring.dart';
import 'package:debuga_o_mascote/models/code_line.dart';

void main() {
  group('checkReorder', () {
    const correct = [
      CodeLine('int x = 5;'),
      CodeLine('print(x);'),
    ];

    test('true quando a sequência bate exatamente', () {
      final attempt = [
        const CodeLine('int x = 5;'),
        const CodeLine('print(x);'),
      ];
      expect(checkReorder(attempt, correct), isTrue);
    });

    test('false quando a ordem está trocada', () {
      final attempt = [
        const CodeLine('print(x);'),
        const CodeLine('int x = 5;'),
      ];
      expect(checkReorder(attempt, correct), isFalse);
    });

    test('false quando falta uma linha', () {
      final attempt = [const CodeLine('int x = 5;')];
      expect(checkReorder(attempt, correct), isFalse);
    });

    test('false quando sobra uma linha', () {
      final attempt = [
        const CodeLine('int x = 5;'),
        const CodeLine('print(x);'),
        const CodeLine('print(x);'),
      ];
      expect(checkReorder(attempt, correct), isFalse);
    });

    test('false quando o texto de uma linha não bate', () {
      final attempt = [
        const CodeLine('int x = 6;'),
        const CodeLine('print(x);'),
      ];
      expect(checkReorder(attempt, correct), isFalse);
    });

    // Regressão: Fase 2 do Mundo 7 (`world7_level2`) — "int a = 2;"/
    // "int b = 3;" são independentes entre si, ambas só precisam vir antes
    // de "print(a + b);". Ver `.claude/memory/decisions.md`.
    group('linhas intercambiáveis (groupOf)', () {
      const correctWithGroups = [
        CodeLine('int a = 2;'),
        CodeLine('int b = 3;'),
        CodeLine('print(a + b);'),
      ];
      const groupOf = [0, 0, 1];

      test('aceita a ordem original', () {
        final attempt = [
          const CodeLine('int a = 2;'),
          const CodeLine('int b = 3;'),
          const CodeLine('print(a + b);'),
        ];
        expect(checkReorder(attempt, correctWithGroups, groupOf: groupOf), isTrue);
      });

      test('aceita a ordem trocada dentro do mesmo grupo', () {
        final attempt = [
          const CodeLine('int b = 3;'),
          const CodeLine('int a = 2;'),
          const CodeLine('print(a + b);'),
        ];
        expect(checkReorder(attempt, correctWithGroups, groupOf: groupOf), isTrue);
      });

      test('rejeita quando uma linha de um grupo posterior vem antes', () {
        final attempt = [
          const CodeLine('print(a + b);'),
          const CodeLine('int a = 2;'),
          const CodeLine('int b = 3;'),
        ];
        expect(checkReorder(attempt, correctWithGroups, groupOf: groupOf), isFalse);
      });

      test('rejeita quando falta uma linha do grupo, mesmo com o mesmo tamanho', () {
        final attempt = [
          const CodeLine('int a = 2;'),
          const CodeLine('int a = 2;'),
          const CodeLine('print(a + b);'),
        ];
        expect(checkReorder(attempt, correctWithGroups, groupOf: groupOf), isFalse);
      });

      test('sem groupOf, mesma ordem trocada dentro do "grupo" antigo (por linha) é rejeitada', () {
        final attempt = [
          const CodeLine('int b = 3;'),
          const CodeLine('int a = 2;'),
          const CodeLine('print(a + b);'),
        ];
        // Sem `groupOf`, o comportamento antigo (ordem exata) é preservado.
        expect(checkReorder(attempt, correctWithGroups), isFalse);
      });
    });
  });

  group('checkFindBug', () {
    test('true quando a linha tocada é a linha errada', () {
      expect(checkFindBug(2, 2), isTrue);
    });

    test('false quando a linha tocada não é a linha errada', () {
      expect(checkFindBug(0, 2), isFalse);
    });
  });

  group('computeCodePuzzleScore', () {
    test('3 estrelas na 1ª tentativa', () {
      final result = computeCodePuzzleScore(attempts: 1);
      expect(result.stars, 3);
      expect(result.points, 300);
    });

    test('2 estrelas na 2ª tentativa', () {
      final result = computeCodePuzzleScore(attempts: 2);
      expect(result.stars, 2);
      expect(result.points, 200);
    });

    test('1 estrela na 3ª tentativa', () {
      final result = computeCodePuzzleScore(attempts: 3);
      expect(result.stars, 1);
      expect(result.points, 100);
    });

    test('1 estrela e pontos com piso de 50 em tentativas altas', () {
      final result = computeCodePuzzleScore(attempts: 10);
      expect(result.stars, 1);
      expect(result.points, 50);
    });
  });
}
