import 'package:flutter/material.dart';

import '../game/block_program_executor.dart';
import '../models/block_program_block.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';

/// Rótulo, cores e ícone de um Bloco de "Programação em Blocos" (só o Mundo
/// 4, "Decisões em Bloco", desde que "Oficina de Blocos" saiu do jogo — ver
/// `.claude/memory/decisions.md`) no "Seu Programa"/paleta de comandos/Dica
/// — mesma ideia de `BlockChipStyle`/`styleForBlock` (Mundo 1), única fonte
/// dessa correspondência para
/// `BlockProgramBlockType`.
///
/// Sem ícone SVG dedicado em `AppIcons` para "somar"/"contar" — reaproveita
/// ícones do Material (`Icons.functions`, o Σ, para blocos que somam ao
/// Total; `Icons.exposure_plus_1` para blocos que contam) em vez de criar um
/// SVG novo, mesmo critério já usado em outras telas do jogo para símbolos
/// pontuais sem correspondência no Design System (ex.: `Icons.close`/
/// `Icons.logout` em diálogos — ver `.claude/memory/decisions.md`). "Para
/// cada número" (`forEachNumber`) reaproveita `AppIcons.repeat` — mesmo
/// papel de modificador de `Repetir`/`Enquanto` nos outros mundos.
///
/// Os 2 blocos condicionais do Mundo 4 (`addToTotalIfEven`/
/// `countPlusOneIfOdd`) reaproveitam o MESMO ícone de ação do bloco
/// incondicional correspondente (`addToTotal`/`countPlusOne`) — a condição
/// em si ("par"/"ímpar") não tem um glifo óbvio. Para não ficarem ambíguos
/// com o par incondicional (mesmo achado de UX já registrado para
/// "Se"/"Enquanto" no Mundo 2, ver `belt_block_chip_style.dart`), cada um
/// ganha **2** diferenciadores: um contorno (`border`, mesma técnica de
/// `whileIcon`/`CommandButton.border`) **e** um `badgeText` ('PAR'/'ÍMPAR').
/// Dupla diferenciação (não só contorno, como "Enquanto") porque aqui a
/// ambiguidade é maior — mesmo ícone de ação, não só mesma cor de fundo.
class BlockProgramChipStyle {
  final String label;
  final Color background;
  final Color foreground;
  final Color shadowColor;
  final String? badgeText;
  final Widget Function(double size) icon;
  final Border? border;

  const BlockProgramChipStyle({
    required this.label,
    required this.background,
    required this.foreground,
    required this.shadowColor,
    this.badgeText,
    required this.icon,
    this.border,
  });
}

/// Blocos disponíveis — só o Mundo 4 ("Decisões em Bloco") usa este motor
/// agora (o mundo irmão original, "Oficina de Blocos", saiu do jogo — ver
/// `.claude/memory/decisions.md`), então sempre retorna o conjunto
/// completo dos 5 blocos. Parâmetro `worldNumber` mantido só por
/// compatibilidade com o call site existente (`BlockProgramGameplayView`).
List<BlockProgramBlockType> availableBlockTypesForWorld(int worldNumber) {
  return const [
    BlockProgramBlockType.forEachNumber,
    BlockProgramBlockType.addToTotal,
    BlockProgramBlockType.countPlusOne,
    BlockProgramBlockType.addToTotalIfEven,
    BlockProgramBlockType.countPlusOneIfOdd,
  ];
}

BlockProgramChipStyle styleForBlockProgramBlock(BlockProgramBlockType type) {
  switch (type) {
    case BlockProgramBlockType.forEachNumber:
      return BlockProgramChipStyle(
        label: 'Para cada número',
        background: AppColors.lilac,
        foreground: AppColors.purpleDark,
        shadowColor: AppColors.lilacShadow,
        icon: (size) =>
            AppIcons.repeat(size: size, color: AppColors.purpleDark),
      );
    case BlockProgramBlockType.addToTotal:
      return BlockProgramChipStyle(
        label: 'Some ao Total',
        background: AppColors.yellowNeon,
        foreground: AppColors.purpleDark,
        shadowColor: AppColors.yellowShadow,
        icon: (size) =>
            Icon(Icons.functions, size: size, color: AppColors.purpleDark),
      );
    case BlockProgramBlockType.countPlusOne:
      return BlockProgramChipStyle(
        label: 'Conte +1',
        background: AppColors.purple,
        foreground: AppColors.white,
        shadowColor: AppColors.purpleShadow,
        icon: (size) =>
            Icon(Icons.exposure_plus_1, size: size, color: AppColors.white),
      );
    case BlockProgramBlockType.addToTotalIfEven:
      return BlockProgramChipStyle(
        label: 'Some os pares',
        background: AppColors.yellowNeon,
        foreground: AppColors.purpleDark,
        shadowColor: AppColors.yellowShadow,
        badgeText: 'PAR',
        icon: (size) =>
            Icon(Icons.functions, size: size, color: AppColors.purpleDark),
        border: Border.all(color: AppColors.purpleDark, width: 3),
      );
    case BlockProgramBlockType.countPlusOneIfOdd:
      return BlockProgramChipStyle(
        label: 'Conte os ímpares',
        background: AppColors.purple,
        foreground: AppColors.white,
        shadowColor: AppColors.purpleShadow,
        badgeText: 'ÍMPAR',
        icon: (size) =>
            Icon(Icons.exposure_plus_1, size: size, color: AppColors.white),
        border: Border.all(color: AppColors.white, width: 3),
      );
  }
}

/// Traduz um Programa inteiro de "Programação em Blocos" (Mundo 4,
/// "Decisões em Bloco") para linhas de código Dart real equivalentes.
/// Usada linha a linha por `BlockProgramGameplayView._blockChip` (cada
/// chip de "Seu Programa" mostra sua própria linha via `codeLineFor`, não
/// mais um painel "Tradutor de Blocos" separado — ver
/// `.claude/memory/decisions.md`, entrada de 2026-09-18); esta função
/// (`codeLinesFor`, o Programa inteiro de uma vez) fica disponível para
/// quem precisar do código completo como lista de linhas. Tradução
/// deliberadamente pedagógica, não um transpilador de verdade — não
/// precisa compilar.
///
/// `forEachNumber` abre um laço `for` sobre a lista de números
/// (`numeros[i]`), fechado por `}` depois da linha do bloco que ele
/// modifica. O pareamento "`forEachNumber` só se aplica ao bloco
/// imediatamente seguinte, sem stacking" vem de `resolveBlockProgramEntries`
/// (`lib/game/block_program_executor.dart`) — a mesma função que
/// `BlockProgramExecutor.expand` usa pra gerar Passos, pra este painel
/// nunca divergir da Execução real se a regra de modificador mudar (achado
/// do Code Reviewer: antes eram 2 cópias independentes da mesma regra).
List<String> codeLinesFor(List<BlockProgramBlock> program) {
  final lines = <String>[];
  for (final entry in resolveBlockProgramEntries(program)) {
    if (entry.insideForEach) {
      lines.add('for (int i = 0; i < numeros.length; i++) {');
      lines.add('  ${codeLineFor(entry.targetType, insideLoop: true)}');
      lines.add('}');
    } else {
      lines.add(codeLineFor(entry.targetType, insideLoop: false));
    }
  }
  return lines;
}

/// Uma linha de código Dart equivalente a um único bloco-alvo (não
/// `forEachNumber`, que só existe como o laço que `codeLinesFor` monta ao
/// redor de outra linha). `insideLoop` decide a variável usada: dentro de
/// um laço "Para cada número" o número atual é `numeros[i]`; um bloco-alvo
/// usado sem "Para cada número" antes (solto no Programa, processa só o
/// próximo número — ver `BlockProgramExecutor.applyStep`) usa a variável
/// descritiva `proximoNumero` em vez de um índice de laço que não existe.
String codeLineFor(BlockProgramBlockType type, {required bool insideLoop}) {
  final number = insideLoop ? 'numeros[i]' : 'proximoNumero';
  switch (type) {
    case BlockProgramBlockType.forEachNumber:
      // Não deveria ocorrer isolado — `codeLinesFor` sempre consome
      // `forEachNumber` junto do bloco seguinte antes de chamar esta
      // função para ele. Mantido só por exaustividade do switch.
      return 'for (int i = 0; i < numeros.length; i++) {';
    case BlockProgramBlockType.addToTotal:
      return 'total += $number;';
    case BlockProgramBlockType.countPlusOne:
      return 'contador++;';
    case BlockProgramBlockType.addToTotalIfEven:
      return 'if ($number % 2 == 0) total += $number;';
    case BlockProgramBlockType.countPlusOneIfOdd:
      return 'if ($number % 2 != 0) contador++;';
  }
}
