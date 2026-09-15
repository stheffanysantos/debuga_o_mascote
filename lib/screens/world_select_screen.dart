import 'package:flutter/material.dart';

import '../models/game_track.dart';
import '../models/level.dart';
import '../models/onboarding.dart';
import '../models/progress.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text.dart';
import '../widgets/dotted_background_widget.dart';
import '../widgets/hard_shadow_box_widget.dart';
import '../widgets/icon_action_button_widget.dart';
import '../widgets/settings_dialog_widget.dart';
import '../widgets/tutorial_content.dart';
import '../widgets/zigzag_map_widget.dart';
import 'code_puzzle_stage_select_screen.dart';
import 'conveyor_stage_select_screen.dart';
import 'leaderboard_screen.dart';
import 'level_select_screen.dart';
import 'tutorial_screen.dart';

/// Enquanto `true`, ignora a trava sequencial de desbloqueio entre mundos
/// (ver `_isWorldUnlocked`) — só para facilitar teste manual/demonstração no
/// estande antes de todas as 12 fases do Mundo 1 existirem "de verdade"
/// jogadas. TODO: mudar para `false` antes da feira — ver
/// `.claude/memory/decisions.md`.
const _debugUnlockAllWorlds = true;

/// Tela 1.5 — Seleção de Mundo, primeira tela depois da Splash. Lista, uma
/// abaixo da outra, um card por `GameTrack` (`tracks`, `lib/models/game_track.dart`)
/// — hoje a Trilha 1 ("TRILHA 1 - FUNDAMENTOS"), com o mapa em zigue-zague
/// (`ZigzagMap`) dos seus mundos logo abaixo, e a Trilha 2, só o card "EM
/// BREVE" (sem mundos ainda). Pedido explícito do usuário: as trilhas não
/// são uma tela própria — aparecem como seção dentro desta mesma tela. Ver
/// `.claude/memory/decisions.md`.
///
/// Na 1ª vez que o jogador toca um mundo jogável, empurra a `TutorialScreen`
/// — incluindo os slides gerais de "o que é programar" se ele ainda não os
/// viu em nenhum mundo (`Onboarding.hasSeenIntro`) — antes de navegar; nas
/// próximas vezes navega direto. Ver `.claude/docs/NAVIGATION_FLOW.md`.
class WorldSelectScreen extends StatelessWidget {
  const WorldSelectScreen({super.key});

  /// Um mundo N>1 desbloqueia quando todas as fases do mundo anterior (na
  /// mesma trilha) estão concluídas. O 1º mundo de uma trilha está sempre
  /// desbloqueado.
  ///
  /// Cuidado: se o mundo anterior tiver `levels: const []` (hoje é o caso de
  /// qualquer mundo `comingSoon`), `.every(...)` sobre uma lista vazia é
  /// `true` por vacuidade — o que pareceria "desbloqueado" mesmo sem fases
  /// completadas. Isso nunca chega a importar na prática: o mundo anterior a
  /// um mundo N>1 nunca é `comingSoon` (só o motor daquele mundo N precisa
  /// existir para N ser jogável) — mas fica documentado aqui para quando um
  /// mundo novo entrar no meio da lista sem fases ainda.
  bool _isWorldUnlocked(GameTrack track, GameWorld world) {
    final index = track.worlds.indexWhere((w) => w.number == world.number);
    if (index <= 0) return true;
    final previousWorld = track.worlds[index - 1];
    return _debugUnlockAllWorlds || Progress.instance.isWorldCompleted(previousWorld.levels.map((l) => l.id));
  }

  /// Cada `WorldGameType` tem sua própria tela de Seleção de Fases (motor
  /// diferente, ver `.claude/plans/Mundos.md`) — decide qual empilhar.
  void _openWorld(BuildContext context, GameWorld world) {
    switch (world.gameType) {
      case WorldGameType.maze:
        Navigator.of(context).push(MaterialPageRoute(
          settings: const RouteSettings(name: levelSelectRouteName),
          builder: (_) => LevelSelectScreen(world: world),
        ));
        break;
      case WorldGameType.conveyor:
        Navigator.of(context).push(MaterialPageRoute(
          settings: const RouteSettings(name: conveyorLevelSelectRouteName),
          builder: (_) => ConveyorStageSelectScreen(world: world),
        ));
        break;
      case WorldGameType.codePuzzle:
        Navigator.of(context).push(MaterialPageRoute(
          settings: const RouteSettings(name: codePuzzleStageSelectRouteName),
          builder: (_) => CodePuzzleStageSelectScreen(world: world),
        ));
        break;
    }
  }

  /// Toque num mundo jogável: mostra a `TutorialScreen` na 1ª vez
  /// (`Onboarding.instance.hasSeen`) — incluindo os slides gerais de "o que
  /// é programar" se esse jogador ainda não os viu em nenhum Mundo (ver
  /// `Onboarding.hasSeenIntro`) — e navega direto nas próximas.
  void _enterWorld(BuildContext context, GameWorld world) {
    if (Onboarding.instance.hasSeen(world.number)) {
      _openWorld(context, world);
      return;
    }
    if (worldTutorials[world.number] == null) {
      // Não deveria acontecer (os 3 mundos jogáveis têm tutorial definido em
      // `tutorial_content.dart`) — mas não bloqueia o jogador se acontecer.
      Onboarding.instance.markSeen(world.number);
      _openWorld(context, world);
      return;
    }
    final includeIntro = !Onboarding.instance.hasSeenIntro;
    final content = tutorialSlidesFor(world.number, includeIntro: includeIntro);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TutorialScreen(
        slides: content.slides,
        narrationAssets: content.narrationAssets,
        onFinish: () {
          if (includeIntro) Onboarding.instance.markIntroSeen();
          Onboarding.instance.markSeen(world.number);
          Navigator.of(context).pop();
          _openWorld(context, world);
        },
      ),
    ));
  }

  /// Toque num card não jogável nunca cai no vazio (sem InkWell/feedback) —
  /// mostra uma explicação curta em vez de simplesmente não reagir (achado
  /// do UX Reviewer, ver `.claude/memory/decisions.md`).
  void _handleWorldTap(BuildContext context, GameWorld world, bool tappable) {
    if (tappable) {
      _enterWorld(context, world);
      return;
    }
    final message = world.comingSoon
        ? 'Em breve! Esse mundo ainda está em construção.'
        : 'Complete o Mundo ${world.number - 1} primeiro para desbloquear.';
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppColors.purpleDark,
      content: Text(message, style: AppText.style(size: 14, weight: FontWeight.w800, color: AppColors.white)),
    ));
  }

  void _handleComingSoonTrackTap(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      backgroundColor: AppColors.purpleDark,
      content: Text('Em breve! Essa trilha ainda está em construção.', style: AppText.style(size: 14, weight: FontWeight.w800, color: AppColors.white)),
    ));
  }

  ZigzagMapNode _buildNode(BuildContext context, GameTrack track, GameWorld world) {
    final unlocked = _isWorldUnlocked(track, world);
    final tappable = !world.comingSoon && unlocked;
    return ZigzagMapNode(
      label: 'MUNDO ${world.number} / ${world.name.toUpperCase()}',
      iconAsset: _worldIconAsset(world.number),
      locked: !world.comingSoon && !unlocked,
      comingSoon: world.comingSoon,
      tappable: tappable,
      onTap: () => _handleWorldTap(context, world, tappable),
    );
  }

  /// Card de cabeçalho de uma Trilha ("TRILHA N - NOME") — trilhas
  /// `comingSoon` mostram só o card (com o badge "EM BREVE" e um toque
  /// avisando que ainda não existe); trilhas jogáveis mostram o card e, logo
  /// abaixo, o `ZigzagMap` dos seus mundos.
  ///
  /// `HardShadowBox` (mesma base de quase todo card/botão do jogo — antes
  /// este card era só um `Container` com borda simples, inconsistente com o
  /// resto do Design System) + um selo numerado + o `GameTrack.subtitle`
  /// (existia no modelo, mas não era mostrado em lugar nenhum) dão ao card
  /// peso de "seção", não só um rótulo. Achado do UX Reviewer: a versão
  /// jogável não usa `yellowNeon` (nem no selo, nem na borda) — essa cor
  /// significa "isto é tocável" na mesma tela (nós do `ZigzagMap` logo
  /// abaixo), e o card em si não tem nenhuma ação própria (quem é tocável
  /// são os nós do mapa). Usa `purple`/`white` — o mesmo par já usado nos
  /// botões de Troféu/Configurações do cabeçalho — pra ficar com cor de
  /// marca sem sugerir toque.
  Widget _buildTrackSection(BuildContext context, GameTrack track) {
    final badgeColor = track.comingSoon ? AppColors.grayLocked : AppColors.purple;
    final badgeForeground = track.comingSoon ? AppColors.grayLockIcon : AppColors.white;

    final card = HardShadowBox(
      color: AppColors.panel,
      shadows: AppShadows.hard(AppColors.black, dy: 6),
      borderRadius: BorderRadius.circular(20),
      border: Border.all(color: track.comingSoon ? AppColors.grayButton : AppColors.purple, width: 2),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: badgeColor, shape: BoxShape.circle),
            alignment: Alignment.center,
            child: Text('${track.number}', style: AppText.style(size: 18, weight: FontWeight.w900, color: badgeForeground)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'TRILHA ${track.number} - ${track.name.toUpperCase()}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.style(size: 16, weight: FontWeight.w900, color: AppColors.white),
                ),
                const SizedBox(height: 4),
                Text(
                  track.subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.style(size: 13, weight: FontWeight.w800, color: AppColors.white.withValues(alpha: 0.65)),
                ),
              ],
            ),
          ),
          if (track.comingSoon) ...[
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(color: AppColors.grayLocked, borderRadius: BorderRadius.circular(999)),
              child: Text('EM BREVE', style: AppText.style(size: 11, weight: FontWeight.w900, color: AppColors.grayLockIcon, letterSpacing: 1)),
            ),
          ],
        ],
      ),
    );

    if (track.comingSoon) {
      return GestureDetector(onTap: () => _handleComingSoonTrackTap(context), child: card);
    }

    final nodes = [for (final world in track.worlds) _buildNode(context, track, world)];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [card, ZigzagMap(nodes: nodes)],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const DottedBackground(),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Voltar continua neutro/discreto (cinza chato, sem
                      // sombra) — mesmo tratamento usado em toda tela do
                      // jogo para "sair". O grupo à direita (Placar +
                      // Configurações) ganhou cor/sombra de destaque (mesma
                      // combinação já usada para o botão "?" de tutorial em
                      // outras telas) só para não ficar visualmente idêntico
                      // ao botão de navegação — achado de UX já registrado
                      // antes para o par voltar/"?", aplicado aqui também.
                      IconActionButton(
                        background: AppColors.grayButton,
                        shadowColor: Colors.transparent,
                        icon: AppIcons.chevronLeft(size: 22, color: AppColors.white),
                        onTap: () => Navigator.of(context).pop(),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Placar do Dia — pedido explícito do usuário, ver
                          // `.claude/memory/decisions.md`.
                          IconActionButton(
                            background: AppColors.purple,
                            shadowColor: AppColors.purpleShadow,
                            icon: AppIcons.trophy(size: 20, color: AppColors.yellowNeon),
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LeaderboardScreen())),
                          ),
                          const SizedBox(width: 12),
                          // Configurações (com o volume dentro) mora só aqui —
                          // tirado da Splash a pedido do usuário, ver
                          // `.claude/memory/decisions.md`.
                          IconActionButton(
                            background: AppColors.purple,
                            shadowColor: AppColors.purpleShadow,
                            icon: AppIcons.settings(size: 20, color: AppColors.white),
                            onTap: () => showDialog(context: context, builder: (_) => const SettingsDialog()),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 22),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Selo decorativo (não interativo — por isso
                      // `HardShadowBox` direto, não `IconActionButton`, para
                      // não competir com os 3 botões de ação do cabeçalho
                      // acima) dando um ponto de cor/ícone de apoio ao
                      // eyebrow+título, que antes eram só texto empilhado.
                      // `purple`/`purpleShadow` (não `yellowNeon`) — achado
                      // do UX Reviewer: `yellowNeon` significa "isto é
                      // tocável" nesta tela (nós do `ZigzagMap` abaixo), e
                      // esse selo não tem ação nenhuma.
                      HardShadowBox(
                        color: AppColors.purple,
                        shadows: AppShadows.hard(AppColors.purpleShadow, dy: 6),
                        borderRadius: BorderRadius.circular(999),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Center(child: AppIcons.star(size: 24, color: AppColors.white)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DEBUGA O MASCOTE', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.eyebrow(size: 13)),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text('Escolha o mundo', style: AppText.style(size: 34, weight: FontWeight.w900, color: AppColors.white, height: 1.05)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Expanded(
                    child: SingleChildScrollView(
                      child: Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 480),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              for (final track in tracks) ...[
                                _buildTrackSection(context, track),
                                const SizedBox(height: 24),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Caminho do ícone ilustrado de cada Mundo (gerado por IA a partir de
/// prompt do usuário) — `assets/images/world{N}_icon.png`. Ver
/// `.claude/memory/decisions.md`.
String _worldIconAsset(int worldNumber) => 'assets/images/world${worldNumber}_icon.png';
