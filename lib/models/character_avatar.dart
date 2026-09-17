/// Um personagem selecionável como foto de perfil — mostrado no círculo de
/// Configurações, no carrossel de `ProfileEditView` e ao lado do nome no
/// Placar Geral (`LeaderboardEntry.avatarId`). Dado puro, sem Flutter/Riverpod
/// (ver `.claude/rules/architecture.md`).
///
/// Só 2 opções hoje (Lili e Libug, as únicas artes de personagem prontas —
/// ver `.claude/memory/decisions.md`) — o usuário vai enviar mais imagens de
/// personagem depois; adicionar uma nova opção é só um item a mais em
/// [characterAvatars], sem mudar nenhuma tela.
class CharacterAvatar {
  final String id;
  final String assetPath;
  final String name;

  const CharacterAvatar({required this.id, required this.assetPath, required this.name});
}

const characterAvatars = <CharacterAvatar>[
  CharacterAvatar(id: 'lili', assetPath: 'assets/images/mascot.png', name: 'Lili'),
  CharacterAvatar(id: 'libug', assetPath: 'assets/images/leaderboard_bee.png', name: 'Libug'),
];

/// Usado quando o jogador ainda não escolheu nenhum avatar
/// (`ProgressState.avatarId == null`) e como último recurso se um `id`
/// salvo não bater com nenhuma opção conhecida (ex.: opção removida no
/// futuro).
const defaultAvatarId = 'lili';

CharacterAvatar avatarById(String? id) =>
    characterAvatars.firstWhere((a) => a.id == id, orElse: () => characterAvatars.first);
