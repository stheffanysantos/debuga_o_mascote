/// Um registro no Placar do Dia — criado quando o jogador preenche a
/// pesquisa opcional (nome, idade, "já programou antes?") pra aparecer no
/// ranking. `age`/`hasProgrammedBefore` não aparecem publicamente no
/// placar (ver `.claude/memory/decisions.md`) — ficam guardados só para
/// quem organiza o estande olhar depois.
class LeaderboardEntry {
  final String name;
  final int age;
  final bool hasProgrammedBefore;
  final int score;
  final DateTime submittedAt;

  const LeaderboardEntry({
    required this.name,
    required this.age,
    required this.hasProgrammedBefore,
    required this.score,
    required this.submittedAt,
  });

  bool isFromSameDayAs(DateTime other) {
    return submittedAt.year == other.year && submittedAt.month == other.month && submittedAt.day == other.day;
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'hasProgrammedBefore': hasProgrammedBefore,
        'score': score,
        'submittedAt': submittedAt.toIso8601String(),
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => LeaderboardEntry(
        name: json['name'] as String,
        age: json['age'] as int,
        hasProgrammedBefore: json['hasProgrammedBefore'] as bool,
        score: json['score'] as int,
        submittedAt: DateTime.parse(json['submittedAt'] as String),
      );
}
