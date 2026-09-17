import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/onboarding/onboarding_notifier.dart';
import '../../../core/progress/progress_notifier.dart';
import '../../../game/scoring.dart';
import '../../../models/game_track.dart';
import '../../../models/level.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/dotted_background_widget.dart';
import '../../../widgets/hard_shadow_box_widget.dart';
import '../../../widgets/icon_action_button_widget.dart';
import '../../../widgets/tutorial_content.dart';
import '../../../widgets/zigzag_map_widget.dart';
import '../../code_puzzle/presentation/stage_select/stage_select_view.dart' show CodePuzzleStageSelectView, codePuzzleStageSelectRouteName;
import '../../complete_code/presentation/stage_select/stage_select_view.dart' show CompleteCodeStageSelectView, completeCodeStageSelectRouteName;
import '../../conveyor/presentation/stage_select/stage_select_view.dart' show ConveyorStageSelectView, conveyorLevelSelectRouteName;
import '../../leaderboard/presentation/leaderboard_view.dart';
import '../../maze/presentation/stage_select/stage_select_view.dart';
import '../../predict_output/presentation/stage_select/stage_select_view.dart' show PredictOutputStageSelectView, predictOutputStageSelectRouteName;
import '../../settings/presentation/settings_view.dart';
import '../../tutorial/presentation/tutorial_view.dart';

/// Enquanto `true`, ignora a trava sequencial de desbloqueio entre mundos
/// (ver `_isWorldUnlocked`) — só para facilitar teste manual/demonstração no
/// estande antes de todas as 12 fases do Mundo 1 existirem "de verdade"
/// jogadas. TODO: mudar para `false` antes da feira — ver
/// `.claude/memory/decisions.md`.
const _debugUnlockAllWorlds = true;

/// Tela 1.5 — Seleção de Mundo, primeira tela depois da Splash. Lista, uma
/// abaixo da outra, um card por `GameTrack` (`tracks`, `lib/models/game_track.dart`)
/// — Trilha 1 ("TRILHA 1 - FUNDAMENTOS", Mundos 1-3) e Trilha 2 ("TRILHA 2 -
/// AVANÇADO", Mundos 4-5) —, cada uma com o mapa em zigue-zague
/// (`ZigzagMap`) dos seus mundos logo abaixo do card. Pedido explícito do
/// usuário: as trilhas não são uma tela própria — aparecem como seção
/// dentro desta mesma tela. Ver `.claude/memory/decisions.md`.
///
/// Na 1ª vez que o jogador toca um mundo jogável, empurra a `TutorialView`
/// — incluindo os slides gerais de "o que é programar" se ele ainda não os
/// viu em nenhum mundo (`Onboarding.hasSeenIntro`) — antes de navegar; nas
/// próximas vezes navega direto. Ver `.claude/docs/NAVIGATION_FLOW.md`.
class WorldSelectView extends ConsumerWidget {
  const WorldSelectView({super.key});

  /// Um mundo N>1 desbloqueia quando o mundo anterior (na mesma trilha) já
  /// rendeu pontos suficientes — `_worldUnlockPointsThreshold`, 60% da
  /// pontuação máxima possível do mundo — **não** exige jogar/vencer as 12
  /// fases; fases não jogadas continuam acessíveis normalmente depois. O 1º
  /// mundo de uma trilha segue uma regra diferente, um nível acima:
  /// desbloqueia só quando a trilha anterior está 100% completa
  /// (`isTrackCompleted`) — o 1º mundo da 1ª trilha está sempre desbloqueado.
  /// Isso é o que faz a Trilha 2 (Mundos 4-5, mais difíceis — já manipulam
  /// código de verdade) esperar a Trilha 1 inteira, não só o mundo anterior
  /// por número — pedido explícito do usuário, ver `.claude/memory/decisions.md`.
  bool _isWorldUnlocked(WidgetRef ref, GameTrack track, GameWorld world) {
    final progress = ref.watch(progressNotifierProvider);
    final index = track.worlds.indexWhere((w) => w.number == world.number);
    if (index > 0) {
      final previousWorld = track.worlds[index - 1];
      final levelIds = previousWorld.levels.map((l) => l.id);
      return _debugUnlockAllWorlds || progress.totalPoints(levelIds) >= _worldUnlockPointsThreshold(previousWorld);
    }
    final trackIndex = tracks.indexOf(track);
    if (trackIndex <= 0) return true;
    return _debugUnlockAllWorlds || progress.isTrackCompleted(tracks[trackIndex - 1]);
  }

  /// 60% da pontuação máxima possível do mundo (`maxLevelPoints` por fase,
  /// `lib/game/scoring.dart`) — limiar escolhido explicitamente pelo usuário
  /// pra liberar o próximo Mundo sem precisar terminar as 12 fases (ver
  /// `.claude/memory/decisions.md`). Se um mundo tiver `levels: const []`
  /// (hoje só mundos `comingSoon`, que nunca são "o mundo anterior" de um
  /// mundo jogável), o limiar vira 0 — nunca bloqueia por engano.
  int _worldUnlockPointsThreshold(GameWorld world) => (world.levels.length * maxLevelPoints * 0.6).round();

  /// Cada `WorldGameType` tem sua própria tela de Seleção de Fases (motor
  /// diferente, ver `.claude/plans/Mundos.md`) — decide qual empilhar.
  void _openWorld(BuildContext context, GameWorld world) {
    switch (world.gameType) {
      case WorldGameType.maze:
        Navigator.of(context).push(MaterialPageRoute(
          settings: const RouteSettings(name: levelSelectRouteName),
          builder: (_) => StageSelectView(world: world),
        ));
        break;
      case WorldGameType.conveyor:
        Navigator.of(context).push(MaterialPageRoute(
          settings: const RouteSettings(name: conveyorLevelSelectRouteName),
          builder: (_) => ConveyorStageSelectView(world: world),
        ));
        break;
      case WorldGameType.predictOutput:
        Navigator.of(context).push(MaterialPageRoute(
          settings: const RouteSettings(name: predictOutputStageSelectRouteName),
          builder: (_) => PredictOutputStageSelectView(world: world),
        ));
        break;
      case WorldGameType.completeCode:
        Navigator.of(context).push(MaterialPageRoute(
          settings: const RouteSettings(name: completeCodeStageSelectRouteName),
          builder: (_) => CompleteCodeStageSelectView(world: world),
        ));
        break;
      case WorldGameType.codePuzzle:
        Navigator.of(context).push(MaterialPageRoute(
          settings: const RouteSettings(name: codePuzzleStageSelectRouteName),
          builder: (_) => CodePuzzleStageSelectView(world: world),
        ));
        break;
    }
  }

  /// Toque num mundo jogável: mostra a `TutorialView` na 1ª vez
  /// (`Onboarding.instance.hasSeen`) e navega direto nas próximas. O
  /// conceito geral de "o que é programar" não mora mais aqui — foi
  /// substituído pelo intro de boas-vindas da Splash (`WelcomeView`,
  /// mostrado antes desta tela), ver `.claude/memory/decisions.md`.
  void _enterWorld(BuildContext context, WidgetRef ref, GameWorld world) {
    final onboardingNotifier = ref.read(onboardingNotifierProvider.notifier);
    if (ref.read(onboardingNotifierProvider).hasSeen(world.number)) {
      _openWorld(context, world);
      return;
    }
    if (worldTutorials[world.number] == null) {
      // Não deveria acontecer (os 3 mundos jogáveis têm tutorial definido em
      // `tutorial_content.dart`) — mas não bloqueia o jogador se acontecer.
      onboardingNotifier.markSeen(world.number);
      _openWorld(context, world);
      return;
    }
    final content = tutorialSlidesFor(world.number);
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => TutorialView(
        slides: content.slides,
        narrationAssets: content.narrationAssets,
        onFinish: () {
          onboardingNotifier.markSeen(world.number);
          Navigator.of(context).pop();
          _openWorld(context, world);
        },
      ),
    ));
  }

  /// Toque num card não jogável nunca cai no vazio (sem InkWell/feedback) —
  /// mostra uma explicação curta em vez de simplesmente não reagir (achado
  /// do UX Reviewer, ver `.claude/memory/decisions.md`).
  void _handleWorldTap(BuildContext context, WidgetRef ref, GameTrack track, GameWorld world, bool tappable) {
    if (tappable) {
      _enterWorld(context, ref, world);
      return;
    }
    String message;
    if (world.comingSoon) {
      message = 'Em breve! Esse mundo ainda está em construção.';
    } else {
      final index = track.worlds.indexWhere((w) => w.number == world.number);
      if (index > 0) {
        final previousWorld = track.worlds[index - 1];
        message = 'Ganhe mais pontos no Mundo ${previousWorld.number} para desbloquear.';
      } else {
        final trackIndex = tracks.indexOf(track);
        message = 'Complete a Trilha ${tracks[trackIndex - 1].number} primeiro para desbloquear.';
      }
    }
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

  ZigzagMapNode _buildNode(BuildContext context, WidgetRef ref, GameTrack track, GameWorld world) {
    final unlocked = _isWorldUnlocked(ref, track, world);
    final tappable = !world.comingSoon && unlocked;
    return ZigzagMapNode(
      label: 'MUNDO ${world.number} / ${world.name.toUpperCase()}',
      iconAsset: _worldIconAsset(world.number),
      locked: !world.comingSoon && !unlocked,
      comingSoon: world.comingSoon,
      tappable: tappable,
      onTap: () => _handleWorldTap(context, ref, track, world, tappable),
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
  Widget _buildTrackSection(BuildContext context, WidgetRef ref, GameTrack track) {
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

    final nodes = [for (final world in track.worlds) _buildNode(context, ref, track, world)];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [card, ZigzagMap(nodes: nodes)],
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const LeaderboardView())),
                          ),
                          const SizedBox(width: 12),
                          // Configurações (com o volume dentro) mora só aqui —
                          // tirado da Splash a pedido do usuário, ver
                          // `.claude/memory/decisions.md`. Tela cheia
                          // (`SettingsView`), não mais um dialog — pedido
                          // explícito do usuário.
                          IconActionButton(
                            background: AppColors.purple,
                            shadowColor: AppColors.purpleShadow,
                            icon: AppIcons.settings(size: 20, color: AppColors.white),
                            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SettingsView())),
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
                                _buildTrackSection(context, ref, track),
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
