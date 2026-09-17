// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'audio_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$soundPlayerHash() => r'ee9a60c66ba310d440a80097fa4306cd33b7c17e';

/// See also [soundPlayer].
@ProviderFor(soundPlayer)
final soundPlayerProvider = Provider<SoundPlayer>.internal(
  soundPlayer,
  name: r'soundPlayerProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$soundPlayerHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SoundPlayerRef = ProviderRef<SoundPlayer>;
String _$appSoundsHash() => r'4540702fa13c8e60bbd84dc0a23ecf1c6098ea61';

/// See also [appSounds].
@ProviderFor(appSounds)
final appSoundsProvider = Provider<AppSoundsService>.internal(
  appSounds,
  name: r'appSoundsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$appSoundsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AppSoundsRef = ProviderRef<AppSoundsService>;
String _$mutedHash() => r'a24e9c6fdce0dd49e57e2728407876ac0bf03e20';

/// Estado de sessão só (mute não persiste entre aberturas do app — mesma
/// decisão em aberto de persistência, ver `.claude/memory/decisions.md`).
///
/// Copied from [Muted].
@ProviderFor(Muted)
final mutedProvider = NotifierProvider<Muted, bool>.internal(
  Muted.new,
  name: r'mutedProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$mutedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Muted = Notifier<bool>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
