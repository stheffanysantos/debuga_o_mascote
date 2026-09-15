/// Abstração mínima sobre "tocar um arquivo de áudio", só para permitir um
/// fake nos testes sem precisar mockar o `MethodChannel` do `audioplayers`
/// (ver `lib/audio/audioplayers_sound_player.dart` para a implementação
/// real). Vive em `lib/audio/` — camada de infraestrutura chamada por
/// `screens/`/`widgets/`, não por `models/`/`game/` (ver
/// `.claude/rules/architecture.md`).
abstract class SoundPlayer {
  /// `assetPath` é relativo a `assets/audio/` (ex.: `'walk.wav'`).
  Future<void> play(String assetPath);
}
