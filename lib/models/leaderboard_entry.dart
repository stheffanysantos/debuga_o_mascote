import 'character_avatar.dart';

/// Um registro no Placar Geral — um por jogador (não um histórico por
/// envio), criado na 1ª vez que ele preenche a pesquisa opcional (nome,
/// idade, "já programou antes?") e atualizado sozinho a cada vitória nova
/// dali em diante (ver `LeaderboardSyncService`). `age`/`hasProgrammedBefore`
/// não aparecem publicamente no placar (ver `.claude/memory/decisions.md`)
/// — ficam guardados só para quem organiza o estande olhar depois.
///
/// Placar **sem recorte de dia** — pedido explícito do usuário: quem "zera o
/// jogo" (100% das fases dos 7 Mundos) sai do Placar Geral e passa a
/// aparecer só na lista separada de quem zerou (`gameCompleted: true`).
class LeaderboardEntry {
  final String name;
  final int age;
  final bool hasProgrammedBefore;
  final int score;
  final DateTime updatedAt;

  /// Id de `CharacterAvatar` (`lib/models/character_avatar.dart`) escolhido
  /// pelo jogador em `ProfileEditView` — mostrado ao lado do nome no
  /// ranking. Documentos salvos antes deste campo existir (`fromJson`) caem
  /// no avatar padrão do jogo (`defaultAvatarId`), nunca quebram.
  final String avatarId;

  /// `true` depois que o jogador completa 100% das fases dos 7 Mundos
  /// (`ProgressState.gameCompleted`) — nesse ponto ele sai do Placar Geral e
  /// passa a aparecer só na lista de quem zerou.
  final bool gameCompleted;

  /// Quando `gameCompleted` virou `true` pela 1ª vez — `null` enquanto não
  /// zerou. Usado pra ordenar a lista de quem zerou (quem terminou primeiro
  /// aparece primeiro).
  final DateTime? completedAt;

  const LeaderboardEntry({
    required this.name,
    required this.age,
    required this.hasProgrammedBefore,
    required this.score,
    required this.updatedAt,
    this.gameCompleted = false,
    this.completedAt,
    this.avatarId = defaultAvatarId,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'age': age,
        'hasProgrammedBefore': hasProgrammedBefore,
        'score': score,
        'updatedAt': updatedAt.toIso8601String(),
        'gameCompleted': gameCompleted,
        'completedAt': completedAt?.toIso8601String(),
        'avatarId': avatarId,
      };

  factory LeaderboardEntry.fromJson(Map<String, dynamic> json) => LeaderboardEntry(
        name: json['name'] as String,
        age: json['age'] as int,
        hasProgrammedBefore: json['hasProgrammedBefore'] as bool,
        score: json['score'] as int,
        updatedAt: DateTime.parse(json['updatedAt'] as String),
        gameCompleted: json['gameCompleted'] as bool? ?? false,
        completedAt: json['completedAt'] != null ? DateTime.parse(json['completedAt'] as String) : null,
        avatarId: json['avatarId'] as String? ?? defaultAvatarId,
      );
}
