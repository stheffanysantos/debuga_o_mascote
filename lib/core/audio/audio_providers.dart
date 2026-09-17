import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'audioplayers_sound_player.dart';
import 'sound_player.dart';

part 'audio_providers.g.dart';

// `keepAlive: true` nos 3 providers abaixo — `soundPlayer` guarda um
// `AudioPlayer` de verdade (não pode ser recriado a cada tela), e
// `muted`/`appSounds` são estado/config de sessão inteira do app.
@Riverpod(keepAlive: true)
SoundPlayer soundPlayer(Ref ref) => AudioplayersSoundPlayer();

/// Estado de sessão só (mute não persiste entre aberturas do app — mesma
/// decisão em aberto de persistência, ver `.claude/memory/decisions.md`).
@Riverpod(keepAlive: true)
class Muted extends _$Muted {
  @override
  bool build() => false;

  void toggle() => state = !state;
}

@Riverpod(keepAlive: true)
AppSoundsService appSounds(Ref ref) => AppSoundsService(ref);

/// Sons e haptics do jogo. Cada método engole qualquer erro do player
/// silenciosamente — áudio é um reforço de UX, nunca pode derrubar uma
/// sessão no estande (ex.: um tablet sem áudio, ou o plugin falhando ao
/// carregar um asset).
class AppSoundsService {
  AppSoundsService(this._ref);

  final Ref _ref;

  bool get _muted => _ref.read(mutedProvider);
  SoundPlayer get _player => _ref.read(soundPlayerProvider);

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

  /// Narração de um slide da `TutorialView` — `assetPath` relativo a
  /// `assets/audio/` (ex.: `'tutorial/intro_0.mp3'`).
  Future<void> playNarration(String assetPath) => _play(assetPath);

  /// Interrompe a narração em andamento — chamado ao "Pular"/terminar o
  /// Tutorial, senão o áudio do slide atual continua tocando por cima da
  /// tela seguinte (achado real do usuário).
  Future<void> stopNarration() async {
    try {
      await _player.stop();
    } catch (_) {
      // Idem — áudio nunca pode derrubar o fluxo.
    }
  }

  Future<void> _play(String assetPath) async {
    if (_muted) return;
    try {
      await _player.play(assetPath);
    } catch (_) {
      // Áudio é só reforço de UX — uma falha aqui nunca deve propagar.
    }
  }

  Future<void> _vibrate(Future<void> Function() haptic) async {
    if (_muted) return;
    try {
      await haptic();
    } catch (_) {
      // Idem — dispositivo sem suporte a haptics não pode quebrar o fluxo.
    }
  }
}
