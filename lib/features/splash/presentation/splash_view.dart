import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/onboarding/onboarding_notifier.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/blinking_dot_widget.dart';
import '../../../widgets/bobbing_widget.dart';
import '../../../widgets/dotted_background_widget.dart';
import '../../../widgets/mascot_image_widget.dart';
import '../../../widgets/primary_pill_button_widget.dart';
import '../../../widgets/pulse_tap_widget.dart';
import '../../welcome/presentation/welcome_view.dart';
import '../../world_select/presentation/world_select_view.dart';

/// Tela 1 — Splash/Menu. Ver `.claude/docs/NAVIGATION_FLOW.md`.
///
/// `StatefulWidget` (estado puramente de apresentação/animação, ver
/// `.claude/rules/architecture.md`):
/// - `_entrance` (`AnimationController`, único disparo): fade + leve
///   deslocamento em cascata dos blocos da tela ao abrir.
/// - `_glow` (`AnimationController`, loop): pulsação suave (opacidade +
///   escala) do brilho decorativo do canto — antes estático.
/// - `_stageIndex` + `_stageTimer` (`Timer.periodic`): o "palco" central
///   revezia entre o Mascote e os 5 ícones ilustrados de Mundo
///   (`assets/images/world{N}_icon.png`), um de cada vez — o atual
///   desaparece e o próximo aparece (`AnimatedSwitcher` com fade), de tempos
///   em tempos. O ícone do Mundo 5 (fixo, não revezando) também aparece bem
///   esmaecido dentro do brilho decorativo do canto (`_stageContent`,
///   reaproveitado nos 2 lugares) — pedido explícito do usuário.
///
/// O título "DEBUGA O MASCOTE" não faz parte do palco (fazia parte numa
/// rodada anterior) — pedido explícito do usuário: é um elemento fixo,
/// centralizado no topo, com o mesmo pulso (`PulseTap`) do botão "JOGAR" —
/// ver `.claude/memory/decisions.md`.
class SplashView extends ConsumerStatefulWidget {
  const SplashView({super.key});

  @override
  ConsumerState<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends ConsumerState<SplashView> with TickerProviderStateMixin {
  late final AnimationController _entrance;
  late final AnimationController _glow;
  Timer? _stageTimer;
  int _stageIndex = 0;

  static final _worldIconAssets = List.generate(5, (i) => 'assets/images/world${i + 1}_icon.png');

  // Mascote (1) + 5 ícones de Mundo — cada um ocupa o palco por vez, em loop.
  static final _stageCount = 1 + _worldIconAssets.length;
  static const _stageDuration = Duration(seconds: 3);

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))..forward();
    _glow = AnimationController(vsync: this, duration: const Duration(milliseconds: 3200))..repeat(reverse: true);
    _stageTimer = Timer.periodic(_stageDuration, (_) {
      if (!mounted) return;
      setState(() => _stageIndex = (_stageIndex + 1) % _stageCount);
    });
  }

  @override
  void dispose() {
    _entrance.dispose();
    _glow.dispose();
    _stageTimer?.cancel();
    super.dispose();
  }

  /// Fade + deslocamento vertical/escala, numa janela (`start`-`end`) da
  /// animação de entrada — dá o efeito de "chegada em cascata" sem precisar
  /// de um `AnimationController` por elemento.
  Widget _entranceReveal({
    required Widget child,
    required double start,
    required double end,
    double slideFrom = 18,
    double scaleFrom = 1,
  }) {
    final curved = CurvedAnimation(parent: _entrance, curve: Interval(start, end, curve: Curves.easeOut));
    return AnimatedBuilder(
      animation: curved,
      builder: (context, child) {
        return Opacity(
          opacity: curved.value.clamp(0.0, 1.0),
          child: Transform.translate(
            offset: Offset(0, slideFrom * (1 - curved.value)),
            child: Transform.scale(
              scale: scaleFrom + (1 - scaleFrom) * curved.value,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          const DottedBackground(),
          const _ScatteredBees(),
          Builder(
            builder: (context) {
              final glowSize = (MediaQuery.sizeOf(context).width * 0.72).clamp(200.0, 320.0);
              return Positioned(
                top: -glowSize * 0.28,
                right: -glowSize * 0.28,
                child: AnimatedBuilder(
                  animation: _glow,
                  builder: (context, child) {
                    final t = Curves.easeInOut.transform(_glow.value);
                    return Opacity(
                      opacity: 0.24 + 0.18 * t,
                      child: Transform.scale(scale: 0.94 + 0.1 * t, child: child),
                    );
                  },
                  child: Container(
                    width: glowSize,
                    height: glowSize,
                    decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.purple),
                    // Ícone do Mundo 5 fixo (não revezando com o palco
                    // central) — pedido explícito do usuário. `Opacity`
                    // bem baixa (não o `_glow` de fora, que já pulsa o
                    // círculo inteiro) pra ficar só uma sugestão visual, sem
                    // competir com o palco de verdade.
                    child: ClipOval(
                      child: Opacity(
                        opacity: 0.3,
                        child: _stageContent(5, glowSize),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _entranceReveal(
                    start: 0,
                    end: 0.45,
                    child: Row(
                      children: [
                        const BlinkingDot(),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'LICODE',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.eyebrow(size: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),
                  _entranceReveal(
                    start: 0.1,
                    end: 0.55,
                    child: Text('JOGO DE LÓGICA', style: AppText.style(size: 16, weight: FontWeight.w900, color: AppColors.yellowNeon, letterSpacing: 1.3)),
                  ),
                  const SizedBox(height: 12),
                  _entranceReveal(
                    start: 0.15,
                    end: 0.6,
                    // Alinhado à esquerda — pedido explícito do usuário:
                    // igual à frase "JOGO DE LÓGICA" logo acima, que também
                    // segue o `crossAxisAlignment: start` da `Column` pai.
                    //
                    // Mesmo pulso do botão "JOGAR" (`PulseTap`) — pedido
                    // explícito do usuário: "vai pular na tela tipo a
                    // animação que o botão de jogar está fazendo".
                    child: PulseTap(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: RichText(
                          // 2 linhas ("DEBUGA O" / "MASCOTE"), não 3 —
                          // achado real do UX Reviewer numa rodada
                          // anterior: forçar "O" sozinho numa linha
                          // inteira criava uma órfã tipográfica.
                          text: TextSpan(
                            style: AppText.style(size: 46, weight: FontWeight.w900, color: AppColors.white, height: 1.0, letterSpacing: -1),
                            children: [
                              const TextSpan(text: 'DEBUGA O\n'),
                              TextSpan(text: 'MASCOTE', style: AppText.style(size: 46, weight: FontWeight.w900, color: AppColors.lilac, height: 1.0, letterSpacing: -1)),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final boxSize = constraints.biggest.shortestSide.clamp(0.0, 340.0);
                        return Center(
                          child: _entranceReveal(
                            start: 0.15,
                            end: 0.75,
                            slideFrom: 12,
                            scaleFrom: 0.9,
                            child: SizedBox(
                              width: boxSize,
                              height: boxSize,
                              child: AnimatedSwitcher(
                                duration: const Duration(milliseconds: 550),
                                transitionBuilder: (child, animation) => FadeTransition(opacity: animation, child: child),
                                child: KeyedSubtree(
                                  key: ValueKey(_stageIndex),
                                  child: _buildStageSlide(_stageIndex, boxSize),
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  _entranceReveal(
                    start: 0.5,
                    end: 1,
                    child: PrimaryPillButton(
                      label: 'JOGAR',
                      height: 76,
                      fontSize: 30,
                      pulsing: true,
                      icon: AppIcons.play(size: 30, color: AppColors.purpleDark),
                      onTap: () {
                        final seenWelcome = ref.read(onboardingNotifierProvider).seenWelcome;
                        Navigator.of(context).push(MaterialPageRoute(
                          builder: (_) => seenWelcome ? const WorldSelectView() : const WelcomeView(),
                        ));
                      },
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

  /// Um "slide" do palco central — índice `0` é o Mascote, `1..5` são os 5
  /// ícones de Mundo (`_worldIconAssets`). Cada um recebe `boxSize` (o
  /// quadrado reservado pelo `Expanded`) pra se dimensionar. Sem moldura
  /// circular por baixo (tinha antes — pedido explícito do usuário pra
  /// testar sem ela) — só a imagem, do mesmo tamanho que a moldura ocupava.
  Widget _buildStageSlide(int index, double boxSize) {
    final size = boxSize * 0.62;
    return SizedBox(
      width: size,
      height: size,
      child: Center(child: _stageContent(index, index == 0 ? size * 0.92 : size)),
    );
  }

  /// O conteúdo de um slide (Mascote ou ícone de Mundo) — reaproveitado
  /// tanto no palco central (`_buildStageSlide`) quanto no eco esmaecido
  /// dentro da bolinha roxa do canto. Ícones sem `ClipOval` (tinha antes,
  /// fazia sentido quando havia uma moldura circular por trás pra recortar
  /// contra) — `BoxFit.contain` mostra a arte de cada ícone por inteiro.
  Widget _stageContent(int index, double size) {
    if (index == 0) return Bobbing(child: MascotImage(size: size));
    final asset = _worldIconAssets[index - 1];
    return Image.asset(asset, width: size, height: size, fit: BoxFit.contain);
  }
}

/// Abelhinhas decorativas espalhadas pelo fundo — mesmo asset do estado
/// vazio do Placar Geral (`assets/images/leaderboard_bee.png`), várias, de
/// tamanhos/posições/opacidades diferentes. Pedido explícito do usuário.
/// Puramente decorativas: opacidade baixa, sem nenhuma animação própria —
/// achado real do UX Reviewer numa rodada anterior desta mesma tela (excesso
/// de movimento simultâneo compete com o botão "JOGAR"), então isto fica
/// como textura parada de fundo, não mais um elemento "vivo".
class _ScatteredBees extends StatelessWidget {
  const _ScatteredBees();

  // Posição (fração da tela), tamanho e opacidade de cada abelhinha — valores
  // variados à mão para parecerem espalhadas, não numa grade.
  // As 2 abelhinhas que ficavam atrás do título (topo/esquerda) e atrás do
  // brilho decorativo do canto (topo/direita) foram removidas — pedido
  // explícito do usuário.
  static const _bees = [
    (top: 0.34, left: 0.02, size: 90.0, opacity: 0.26, angle: 0.2),
    (top: 0.46, left: 0.84, size: 62.0, opacity: 0.32, angle: -0.25),
    (top: 0.66, left: 0.10, size: 44.0, opacity: 0.34, angle: 0.4),
    (top: 0.78, left: 0.68, size: 80.0, opacity: 0.28, angle: -0.15),
    (top: 0.90, left: 0.26, size: 54.0, opacity: 0.30, angle: 0.25),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    return Stack(
      children: [
        for (final bee in _bees)
          Positioned(
            top: size.height * bee.top,
            left: size.width * bee.left,
            child: Opacity(
              opacity: bee.opacity,
              child: Transform.rotate(
                angle: bee.angle,
                child: Image.asset('assets/images/leaderboard_bee.png', width: bee.size, height: bee.size, fit: BoxFit.contain),
              ),
            ),
          ),
      ],
    );
  }
}
