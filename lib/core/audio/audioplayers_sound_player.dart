import 'package:audioplayers/audioplayers.dart';

import 'sound_player.dart';

/// Implementação real de [SoundPlayer] usando `package:audioplayers`.
/// Um único [AudioPlayer] em modo de baixa latência é reaproveitado entre
/// chamadas — cada [play] interrompe o som anterior e toca o novo, o que é
/// aceitável aqui porque os efeitos são curtos e não se sobrepõem de forma
/// que importe (blip de passo, clique de virar, etc.).
class AudioplayersSoundPlayer implements SoundPlayer {
  final AudioPlayer _player = AudioPlayer()..setPlayerMode(PlayerMode.lowLatency);

  @override
  Future<void> play(String assetPath) => _player.play(AssetSource('audio/$assetPath'));

  @override
  Future<void> stop() => _player.stop();
}
