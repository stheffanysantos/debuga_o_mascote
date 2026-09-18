/// Um personagem selecionável como foto de perfil — mostrado no círculo de
/// Configurações, no carrossel de `ProfileEditView` e ao lado do nome no
/// Placar Geral (`LeaderboardEntry.avatarId`). Dado puro, sem Flutter/Riverpod
/// (ver `.claude/rules/architecture.md`).
///
/// 5 opções hoje (Lili, Libug + 3 personagens novos gerados por IA a partir
/// de prompt do usuário — ver `.claude/memory/decisions.md`) — adicionar uma
/// opção nova é só um item a mais em [characterAvatars], sem mudar nenhuma
/// tela.
///
/// Lili usa um closeup do rostinho (`avatar_lili.png`), não
/// `assets/images/mascot.png` (arte de corpo inteiro usada no resto do
/// app) — mais parecido em enquadramento com os outros avatares (todos
/// closeup de rosto), melhor pro círculo pequeno de perfil/Placar. Mesmo
/// `id` (`'lili'`) de antes — progresso salvo com esse `avatarId` continua
/// válido, só troca de imagem.
class CharacterAvatar {
  final String id;
  final String assetPath;
  final String name;

  const CharacterAvatar({required this.id, required this.assetPath, required this.name});
}

const characterAvatars = <CharacterAvatar>[
  CharacterAvatar(id: 'lili', assetPath: 'assets/images/avatar_lili.png', name: 'Lili'),
  CharacterAvatar(id: 'libug', assetPath: 'assets/images/leaderboard_bee.png', name: 'Libug'),
  CharacterAvatar(id: 'bit', assetPath: 'assets/images/avatar_bit.png', name: 'Bit'),
  CharacterAvatar(id: 'chip', assetPath: 'assets/images/avatar_chip.png', name: 'Chip'),
  CharacterAvatar(id: 'loopy', assetPath: 'assets/images/avatar_loopy.png', name: 'Loopy'),
];

/// Usado quando o jogador ainda não escolheu nenhum avatar
/// (`ProgressState.avatarId == null`) e como último recurso se um `id`
/// salvo não bater com nenhuma opção conhecida (ex.: opção removida no
/// futuro).
const defaultAvatarId = 'lili';

CharacterAvatar avatarById(String? id) =>
    characterAvatars.firstWhere((a) => a.id == id, orElse: () => characterAvatars.first);
