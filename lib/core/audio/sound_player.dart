/// Abstração mínima sobre "tocar um arquivo de áudio", só para permitir um
/// fake nos testes sem precisar mockar o `MethodChannel` do `audioplayers`
/// (ver `audioplayers_sound_player.dart` para a implementação real).
abstract class SoundPlayer {
  /// `assetPath` é relativo a `assets/audio/` (ex.: `'walk.wav'`).
  Future<void> play(String assetPath);

  /// Interrompe o áudio em andamento, se houver — usado hoje só pela
  /// narração do Tutorial (`AppSoundsService.stopNarration`), que pode
  /// continuar tocando depois que o jogador já saiu da tela (ex.: "Pular").
  Future<void> stop();
}
