/// Tipos de comando que o jogador pode adicionar ao Programa de
/// "Programação em Blocos" (Mundos 3 e 4, `WorldGameType.blockProgram`). Ver
/// `.claude/docs/GAME_DESIGN.md`, seção "Programação em Blocos". O Mundo 3
/// ("Oficina de Blocos") só oferece os 3 primeiros tipos; o Mundo 4
/// ("Decisões em Bloco") acrescenta os 2 condicionais.
enum BlockProgramBlockType {
  /// "Para cada número" — modificador (só 1 nível, igual `Repetir`/
  /// `Enquanto` dos outros mundos, sem stacking) que aplica o bloco
  /// imediatamente seguinte uma vez para cada número da lista da fase, na
  /// ordem em que aparecem.
  forEachNumber,

  /// "Some ao Total" — soma o número atual ao Total acumulado.
  addToTotal,

  /// "Conte +1" — soma 1 ao Contador acumulado (ignora o valor do número
  /// atual, só conta quantas vezes rodou).
  countPlusOne,

  /// "Some os pares" — só Mundo 4: condição embutida no próprio bloco-alvo
  /// (não um modificador aninhado) — soma o número atual ao Total só quando
  /// ele for par; quando ímpar, não faz nada (não é uma falha, mesmo
  /// princípio de "Enquanto nunca falha" do Mundo 2). Rótulo encurtado
  /// (era "Se for par, some ao Total") — achado do UX Reviewer: rótulo
  /// longo demais pra ficar legível na grade de 5 comandos do Mundo 4.
  addToTotalIfEven,

  /// "Conte os ímpares" — só Mundo 4: soma 1 ao Contador só quando o número
  /// atual for ímpar; quando par, não faz nada. Rótulo encurtado (era "Se
  /// for ímpar, conte +1"), mesmo motivo de `addToTotalIfEven`.
  countPlusOneIfOdd,
}

/// Um bloco do Programa de "Programação em Blocos" montado pelo jogador.
/// `forEachNumber` se aplica ao bloco imediatamente seguinte no Programa
/// (ver `BlockProgramExecutor.expand`) — mesma forma de `lib/models/block.dart`
/// (Mundo 1) e `lib/models/belt_block.dart` (Mundo 2). Os outros 4 tipos são
/// autocontidos (não modificam o bloco seguinte).
class BlockProgramBlock {
  final BlockProgramBlockType type;

  const BlockProgramBlock(this.type);

  @override
  bool operator ==(Object other) => other is BlockProgramBlock && other.type == type;

  @override
  int get hashCode => type.hashCode;
}
