import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/audio/audio_providers.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/dotted_background_widget.dart';
import '../../../widgets/primary_pill_button_widget.dart';
import '../../../widgets/tutorial_content.dart';

/// Tela cheia de tutorial — troca do antigo `TutorialModal` (dialog com
/// tudo junto) por um fluxo paginado ("Próximo"/"Próximo"), com o texto de
/// cada slide surgindo letra a letra (efeito de máquina de escrever) e, se
/// o asset existir, narração em áudio (ver `AppSounds.playNarration`).
/// Pedido explícito do usuário — ver `.claude/memory/decisions.md`.
///
/// Não navega nem grava `Onboarding` sozinha — quem empurra esta tela
/// decide o que `onFinish` faz (marcar mundo/intro como visto, abrir a
/// Seleção de Fases, ou só fechar de volta se foi reaberta pelo "?"). Ver
/// `tutorialSlidesFor` (`tutorial_content.dart`) para como montar
/// `slides`/`narrationAssets`.
///
/// `ConsumerStatefulWidget` com estado local (não um `TutorialViewModel`):
/// o índice do slide atual e o progresso da máquina de escrever são estado
/// puramente de apresentação/animação (paginação de UI), não estado de
/// aplicação — não sobrevivem a um rebuild de outra tela nem precisam ser
/// lidos de fora, então um `Notifier` Riverpod não ganharia nada sobre
/// `setState` aqui (ver plano de migração, §6: "não force ViewModel numa
/// tela sem lógica de orquestração real").
class TutorialView extends ConsumerStatefulWidget {
  final List<TutorialSlide> slides;
  final List<String> narrationAssets;
  final VoidCallback onFinish;

  /// Rótulo do botão primário no último slide — "Jogar" (padrão, usado no
  /// tutorial de um Mundo) não faz sentido na recapitulação de fim de Mundo
  /// (não tem próxima fase pra jogar direto), que passa "Continuar".
  final String finalLabel;

  /// Quando presente, substitui o botão primário do último slide (uma vez
  /// com o texto todo revelado) por um conteúdo próprio — usado por
  /// `WelcomeView` pra mostrar as 3 escolhas de conta em vez de um botão
  /// só. Enquanto o texto ainda está "digitando", o toque na área do slide
  /// continua revelando tudo na hora; só depois de completo é que este
  /// conteúdo aparece (o toque na área do slide deixa de avançar sozinho
  /// nesse momento — as escolhas passam a ser a única forma de sair daqui).
  final WidgetBuilder? finalActionsBuilder;

  const TutorialView({
    super.key,
    required this.slides,
    required this.narrationAssets,
    required this.onFinish,
    this.finalLabel = 'Jogar',
    this.finalActionsBuilder,
  });

  @override
  ConsumerState<TutorialView> createState() => _TutorialViewState();
}

class _TutorialViewState extends ConsumerState<TutorialView> {
  int _index = 0;
  bool _typingDone = false;
  bool _skipTyping = false;

  // Guardado em `initState` (não lido de novo em `dispose`) — `ref` não
  // pode ser usado depois que o widget é descartado (`ConsumerStatefulElement`
  // lança `StateError` nesse caso), então a referência ao serviço precisa
  // ser capturada enquanto ainda é seguro.
  late final AppSoundsService _appSounds;

  @override
  void initState() {
    super.initState();
    _appSounds = ref.read(appSoundsProvider);
    _playNarrationForCurrentSlide();
  }

  @override
  void dispose() {
    // Rede de segurança além de `_finish` — garante que a narração nunca
    // sobrevive a esta tela, mesmo se ela sair de cena por um caminho que
    // não passa por "Pular"/terminar o último slide.
    _appSounds.stopNarration();
    super.dispose();
  }

  void _playNarrationForCurrentSlide() {
    if (_index < widget.narrationAssets.length) {
      _appSounds.playNarration(widget.narrationAssets[_index]);
    }
  }

  /// Primeiro toque (com o texto ainda "digitando") revela tudo na hora;
  /// só o toque seguinte avança pro próximo slide (ou termina, no último).
  void _handleAdvance() {
    if (!_typingDone) {
      setState(() => _skipTyping = true);
      return;
    }
    final isLast = _index == widget.slides.length - 1;
    if (isLast) {
      // Com `finalActionsBuilder`, o toque na área do slide já não avança
      // nada — as escolhas explícitas (ex.: criar conta/entrar/jogar sem
      // conta) são a única saída daqui.
      if (widget.finalActionsBuilder == null) _finish();
      return;
    }
    setState(() {
      _index++;
      _typingDone = false;
      _skipTyping = false;
    });
    _playNarrationForCurrentSlide();
  }

  /// Sai do Tutorial (via "Pular" ou terminando o último slide) sempre
  /// parando a narração em andamento primeiro — sem isso, o áudio do slide
  /// atual continuava tocando por cima da tela seguinte (achado real do
  /// usuário).
  void _finish() {
    _appSounds.stopNarration();
    widget.onFinish();
  }

  @override
  Widget build(BuildContext context) {
    final slide = widget.slides[_index];
    final isLast = _index == widget.slides.length - 1;

    return PopScope(
      // Mesmo espírito do `barrierDismissible: false` do antigo
      // `TutorialModal` — só sai pelo "Pular" ou terminando o fluxo.
      canPop: false,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            const DottedBackground(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 10, 24, 24),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: _finish,
                        child: Text(
                          'Pular',
                          style: AppText.style(size: 14, weight: FontWeight.w800, color: AppColors.white.withValues(alpha: 0.55)),
                        ),
                      ),
                    ),
                    Expanded(
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        onTap: _handleAdvance,
                        child: Center(
                          child: SingleChildScrollView(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Image.asset(slide.imageAsset, width: 180, height: 180, fit: BoxFit.contain),
                                const SizedBox(height: 24),
                                if (slide.title != null) ...[
                                  Text(
                                    slide.title!,
                                    textAlign: TextAlign.center,
                                    style: AppText.style(size: 26, weight: FontWeight.w900, color: AppColors.white),
                                  ),
                                  const SizedBox(height: 16),
                                ],
                                _TypewriterText(
                                  key: ValueKey(_index),
                                  text: slide.body,
                                  style: AppText.style(size: 18, weight: FontWeight.w800, color: AppColors.white.withValues(alpha: 0.9), height: 1.4),
                                  skip: _skipTyping,
                                  onComplete: () => setState(() => _typingDone = true),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                    _ProgressDots(count: widget.slides.length, current: _index),
                    const SizedBox(height: 16),
                    if (isLast && _typingDone && widget.finalActionsBuilder != null)
                      widget.finalActionsBuilder!(context)
                    else
                      PrimaryPillButton(
                        label: isLast ? widget.finalLabel : 'Próximo',
                        height: 64,
                        fontSize: 22,
                        onTap: _handleAdvance,
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Fileira de bolinhas indicando quantos slides faltam — atual maior e
/// amarela, já vistos amarelos menores, futuros cinza.
class _ProgressDots extends StatelessWidget {
  final int count;
  final int current;

  const _ProgressDots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 0; i < count; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: i == current ? 20 : 8,
            height: 8,
            decoration: BoxDecoration(
              color: i <= current ? AppColors.yellowNeon : AppColors.grayButton,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
      ],
    );
  }
}

/// Revela `text` letra a letra (efeito de máquina de escrever). Cada slide
/// usa uma instância nova (`ValueKey(index)` no chamador), então só precisa
/// lidar com `skip` mudando de `false` para `true` durante a vida da mesma
/// instância — nunca com o próprio `text` mudando.
class _TypewriterText extends StatefulWidget {
  final String text;
  final TextStyle style;
  final bool skip;
  final VoidCallback onComplete;

  const _TypewriterText({
    super.key,
    required this.text,
    required this.style,
    required this.skip,
    required this.onComplete,
  });

  @override
  State<_TypewriterText> createState() => _TypewriterTextState();
}

class _TypewriterTextState extends State<_TypewriterText> {
  static const _charInterval = Duration(milliseconds: 22);

  Timer? _timer;
  int _visibleChars = 0;
  bool _completed = false;

  @override
  void initState() {
    super.initState();
    if (widget.skip) {
      _complete();
    } else {
      _timer = Timer.periodic(_charInterval, (_) {
        if (_visibleChars >= widget.text.length) {
          _complete();
          return;
        }
        setState(() => _visibleChars++);
      });
    }
  }

  void _complete() {
    _timer?.cancel();
    if (_completed) return;
    _completed = true;
    setState(() => _visibleChars = widget.text.length);
    // `_complete` pode ser chamado a partir de `didUpdateWidget` (toque de
    // "pular digitação"), que roda durante o build do widget pai
    // (`_TutorialViewState`) — chamar `widget.onComplete` (que dá
    // `setState` no pai) nesse momento quebraria com "setState() called
    // during build". Adiar pro fim do frame resolve nos dois casos (aqui e
    // no caminho do `Timer`, onde adiar não muda nada visível).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onComplete();
    });
  }

  @override
  void didUpdateWidget(covariant _TypewriterText oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.skip && !oldWidget.skip) _complete();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(widget.text.substring(0, _visibleChars), textAlign: TextAlign.center, style: widget.style);
  }
}
