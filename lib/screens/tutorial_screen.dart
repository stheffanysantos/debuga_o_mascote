import 'dart:async';

import 'package:flutter/material.dart';

import '../audio/app_sounds.dart';
import '../theme/app_colors.dart';
import '../theme/app_text.dart';
import '../widgets/dotted_background_widget.dart';
import '../widgets/primary_pill_button_widget.dart';
import '../widgets/tutorial_content.dart';

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
class TutorialScreen extends StatefulWidget {
  final List<TutorialSlide> slides;
  final List<String> narrationAssets;
  final VoidCallback onFinish;

  /// Rótulo do botão primário no último slide — "Jogar" (padrão, usado no
  /// tutorial de um Mundo) não faz sentido na recapitulação de fim de Mundo
  /// (não tem próxima fase pra jogar direto), que passa "Continuar".
  final String finalLabel;

  const TutorialScreen({
    super.key,
    required this.slides,
    required this.narrationAssets,
    required this.onFinish,
    this.finalLabel = 'Jogar',
  });

  @override
  State<TutorialScreen> createState() => _TutorialScreenState();
}

class _TutorialScreenState extends State<TutorialScreen> {
  int _index = 0;
  bool _typingDone = false;
  bool _skipTyping = false;

  @override
  void initState() {
    super.initState();
    _playNarrationForCurrentSlide();
  }

  void _playNarrationForCurrentSlide() {
    if (_index < widget.narrationAssets.length) {
      AppSounds.instance.playNarration(widget.narrationAssets[_index]);
    }
  }

  /// Primeiro toque (com o texto ainda "digitando") revela tudo na hora;
  /// só o toque seguinte avança pro próximo slide (ou termina, no último).
  void _handleAdvance() {
    if (!_typingDone) {
      setState(() => _skipTyping = true);
      return;
    }
    if (_index == widget.slides.length - 1) {
      widget.onFinish();
      return;
    }
    setState(() {
      _index++;
      _typingDone = false;
      _skipTyping = false;
    });
    _playNarrationForCurrentSlide();
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
                        onPressed: widget.onFinish,
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
                                Image.asset('assets/images/mascot_tutorial.png', width: 180, height: 180, fit: BoxFit.contain),
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
    // (`_TutorialScreenState`) — chamar `widget.onComplete` (que dá
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
