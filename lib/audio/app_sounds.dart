import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'audioplayers_sound_player.dart';
import 'sound_player.dart';

/// Sons e haptics do jogo — instância única e compartilhada
/// (`AppSounds.instance`), mesmo padrão de `Progress.instance`
/// (`lib/models/progress.dart`): estado de sessão só (mute não persiste
/// entre aberturas do app — mesma decisão em aberto de persistência, ver
/// `.claude/memory/decisions.md`).
///
/// Cada método engole qualquer erro do [player] silenciosamente — áudio é
/// um reforço de UX, nunca pode derrubar uma sessão no estande (ex.: um
/// tablet sem áudio, ou o plugin falhando ao carregar um asset).
class AppSounds {
  AppSounds._();

  static final AppSounds instance = AppSounds._();

  bool muted = false;

  // `_player` só é criado de verdade (tocando plugin/platform channel) na
  // primeira chamada real — nunca na construção do singleton. Isso evita
  // que só acessar `AppSounds.instance` já exija um binding do Flutter
  // inicializado (importa para `test/audio/app_sounds_test.dart`, que troca
  // por um fake antes de qualquer som tocar).
  SoundPlayer? _player;

  @visibleForTesting
  set player(SoundPlayer value) => _player = value;

  SoundPlayer get _resolvedPlayer => _player ??= AudioplayersSoundPlayer();

  void toggleMute() => muted = !muted;

  /// Só para testes — restaura mute e o player entre casos de teste.
  @visibleForTesting
  void resetForTest() {
    muted = false;
    _player = null;
  }

  Future<void> walk() => _play('walk.wav');

  Future<void> turn() => _play('turn.wav');

  Future<void> run() => _play('play.wav');

  Future<void> victory() async {
    unawaited(_play('victory.wav'));
    unawaited(_vibrate(HapticFeedback.mediumImpact));
  }

  Future<void> failure() async {
    unawaited(_play('failure.wav'));
    // `lightImpact`, não `heavyImpact` — falha nunca é punitiva (ver
    // CLAUDE.md); o toque físico mais forte do app fica reservado para a
    // vitória (achado do UX Reviewer, ver .claude/memory/decisions.md).
    unawaited(_vibrate(HapticFeedback.lightImpact));
  }

  /// Narração de um slide da `TutorialScreen` (`lib/screens/tutorial_screen.dart`)
  /// — `assetPath` relativo a `assets/audio/` (ex.: `'tutorial/intro_0.mp3'`).
  /// Mesmo tratamento de erro/mute dos outros sons: falha ao carregar (asset
  /// de narração ainda não gerado para aquele slide, ver
  /// `.claude/memory/decisions.md`) nunca derruba o fluxo.
  Future<void> playNarration(String assetPath) => _play(assetPath);

  Future<void> _play(String assetPath) async {
    if (muted) return;
    try {
      await _resolvedPlayer.play(assetPath);
    } catch (_) {
      // Áudio é só reforço de UX — uma falha aqui nunca deve propagar.
    }
  }

  Future<void> _vibrate(Future<void> Function() haptic) async {
    if (muted) return;
    try {
      await haptic();
    } catch (_) {
      // Idem — dispositivo sem suporte a haptics não pode quebrar o fluxo.
    }
  }
}
