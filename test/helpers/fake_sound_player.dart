import 'package:debuga_o_mascote/core/audio/sound_player.dart';

/// [SoundPlayer] de teste — só registra os assets tocados, sem passar pelo
/// `MethodChannel` real do `audioplayers` (que não tem mock configurado em
/// `test/`, ver `.claude/memory/decisions.md`).
class FakeSoundPlayer implements SoundPlayer {
  final List<String> playedAssets = [];

  bool stopped = false;

  @override
  Future<void> play(String assetPath) async {
    playedAssets.add(assetPath);
  }

  @override
  Future<void> stop() async {
    stopped = true;
  }
}
