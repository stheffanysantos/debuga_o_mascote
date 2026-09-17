import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:debuga_o_mascote/core/audio/audio_providers.dart';

import '../helpers/fake_sound_player.dart';

void main() {
  late FakeSoundPlayer fakePlayer;
  late ProviderContainer container;

  setUp(() {
    fakePlayer = FakeSoundPlayer();
    container = ProviderContainer(overrides: [soundPlayerProvider.overrideWithValue(fakePlayer)]);
  });

  tearDown(() => container.dispose());

  test('começa sem mutar', () {
    expect(container.read(mutedProvider), isFalse);
  });

  test('toggle alterna o estado', () {
    container.read(mutedProvider.notifier).toggle();
    expect(container.read(mutedProvider), isTrue);
    container.read(mutedProvider.notifier).toggle();
    expect(container.read(mutedProvider), isFalse);
  });

  test('walk/turn/run tocam o asset certo', () async {
    final appSounds = container.read(appSoundsProvider);
    await appSounds.walk();
    await appSounds.turn();
    await appSounds.run();
    expect(fakePlayer.playedAssets, ['walk.wav', 'turn.wav', 'play.wav']);
  });

  test('victory toca o chime; failure toca o buzz', () async {
    final appSounds = container.read(appSoundsProvider);
    await appSounds.victory();
    await appSounds.failure();
    expect(fakePlayer.playedAssets, ['victory.wav', 'failure.wav']);
  });

  test('mutado não toca nenhum som', () async {
    container.read(mutedProvider.notifier).toggle();
    final appSounds = container.read(appSoundsProvider);
    await appSounds.walk();
    await appSounds.victory();
    expect(fakePlayer.playedAssets, isEmpty);
  });
}
