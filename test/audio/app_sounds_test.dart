import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/audio/app_sounds.dart';

import '../helpers/fake_sound_player.dart';

void main() {
  late FakeSoundPlayer fakePlayer;

  setUp(() {
    fakePlayer = FakeSoundPlayer();
    AppSounds.instance.player = fakePlayer;
  });

  tearDown(() => AppSounds.instance.resetForTest());

  test('começa sem mutar', () {
    expect(AppSounds.instance.muted, isFalse);
  });

  test('toggleMute alterna o estado', () {
    AppSounds.instance.toggleMute();
    expect(AppSounds.instance.muted, isTrue);
    AppSounds.instance.toggleMute();
    expect(AppSounds.instance.muted, isFalse);
  });

  test('walk/turn/run tocam o asset certo', () async {
    await AppSounds.instance.walk();
    await AppSounds.instance.turn();
    await AppSounds.instance.run();
    expect(fakePlayer.playedAssets, ['walk.wav', 'turn.wav', 'play.wav']);
  });

  test('victory toca o chime; failure toca o buzz', () async {
    await AppSounds.instance.victory();
    await AppSounds.instance.failure();
    expect(fakePlayer.playedAssets, ['victory.wav', 'failure.wav']);
  });

  test('mutado não toca nenhum som', () async {
    AppSounds.instance.muted = true;
    await AppSounds.instance.walk();
    await AppSounds.instance.victory();
    expect(fakePlayer.playedAssets, isEmpty);
  });
}
