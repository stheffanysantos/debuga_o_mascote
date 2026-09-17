// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gameplay_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$gameplayViewModelHash() => r'1027fb6bf704a996fb49f458abe0855f91c65ecc';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

abstract class _$GameplayViewModel
    extends BuildlessAutoDisposeNotifier<GameplayState> {
  late final String levelId;

  GameplayState build(String levelId);
}

/// ViewModel da Gameplay do Mundo 1 — família por `levelId` (não pelo objeto
/// `Level`, que não tem `==`/`hashCode` de valor). Orquestra a Execução
/// (`ProgramExecutor`) passo a passo, incluindo o timing da animação (mesmo
/// lugar de antes, dentro de `_run()`/`_goToResultScreen` do antigo
/// `GameplayScreen`) — a View só renderiza `state` e reage a
/// `state.pendingEffect` via `ref.listen`.
///
/// Copied from [GameplayViewModel].
@ProviderFor(GameplayViewModel)
const gameplayViewModelProvider = GameplayViewModelFamily();

/// ViewModel da Gameplay do Mundo 1 — família por `levelId` (não pelo objeto
/// `Level`, que não tem `==`/`hashCode` de valor). Orquestra a Execução
/// (`ProgramExecutor`) passo a passo, incluindo o timing da animação (mesmo
/// lugar de antes, dentro de `_run()`/`_goToResultScreen` do antigo
/// `GameplayScreen`) — a View só renderiza `state` e reage a
/// `state.pendingEffect` via `ref.listen`.
///
/// Copied from [GameplayViewModel].
class GameplayViewModelFamily extends Family<GameplayState> {
  /// ViewModel da Gameplay do Mundo 1 — família por `levelId` (não pelo objeto
  /// `Level`, que não tem `==`/`hashCode` de valor). Orquestra a Execução
  /// (`ProgramExecutor`) passo a passo, incluindo o timing da animação (mesmo
  /// lugar de antes, dentro de `_run()`/`_goToResultScreen` do antigo
  /// `GameplayScreen`) — a View só renderiza `state` e reage a
  /// `state.pendingEffect` via `ref.listen`.
  ///
  /// Copied from [GameplayViewModel].
  const GameplayViewModelFamily();

  /// ViewModel da Gameplay do Mundo 1 — família por `levelId` (não pelo objeto
  /// `Level`, que não tem `==`/`hashCode` de valor). Orquestra a Execução
  /// (`ProgramExecutor`) passo a passo, incluindo o timing da animação (mesmo
  /// lugar de antes, dentro de `_run()`/`_goToResultScreen` do antigo
  /// `GameplayScreen`) — a View só renderiza `state` e reage a
  /// `state.pendingEffect` via `ref.listen`.
  ///
  /// Copied from [GameplayViewModel].
  GameplayViewModelProvider call(String levelId) {
    return GameplayViewModelProvider(levelId);
  }

  @override
  GameplayViewModelProvider getProviderOverride(
    covariant GameplayViewModelProvider provider,
  ) {
    return call(provider.levelId);
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'gameplayViewModelProvider';
}

/// ViewModel da Gameplay do Mundo 1 — família por `levelId` (não pelo objeto
/// `Level`, que não tem `==`/`hashCode` de valor). Orquestra a Execução
/// (`ProgramExecutor`) passo a passo, incluindo o timing da animação (mesmo
/// lugar de antes, dentro de `_run()`/`_goToResultScreen` do antigo
/// `GameplayScreen`) — a View só renderiza `state` e reage a
/// `state.pendingEffect` via `ref.listen`.
///
/// Copied from [GameplayViewModel].
class GameplayViewModelProvider
    extends AutoDisposeNotifierProviderImpl<GameplayViewModel, GameplayState> {
  /// ViewModel da Gameplay do Mundo 1 — família por `levelId` (não pelo objeto
  /// `Level`, que não tem `==`/`hashCode` de valor). Orquestra a Execução
  /// (`ProgramExecutor`) passo a passo, incluindo o timing da animação (mesmo
  /// lugar de antes, dentro de `_run()`/`_goToResultScreen` do antigo
  /// `GameplayScreen`) — a View só renderiza `state` e reage a
  /// `state.pendingEffect` via `ref.listen`.
  ///
  /// Copied from [GameplayViewModel].
  GameplayViewModelProvider(String levelId)
    : this._internal(
        () => GameplayViewModel()..levelId = levelId,
        from: gameplayViewModelProvider,
        name: r'gameplayViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$gameplayViewModelHash,
        dependencies: GameplayViewModelFamily._dependencies,
        allTransitiveDependencies:
            GameplayViewModelFamily._allTransitiveDependencies,
        levelId: levelId,
      );

  GameplayViewModelProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.levelId,
  }) : super.internal();

  final String levelId;

  @override
  GameplayState runNotifierBuild(covariant GameplayViewModel notifier) {
    return notifier.build(levelId);
  }

  @override
  Override overrideWith(GameplayViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: GameplayViewModelProvider._internal(
        () => create()..levelId = levelId,
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        levelId: levelId,
      ),
    );
  }

  @override
  AutoDisposeNotifierProviderElement<GameplayViewModel, GameplayState>
  createElement() {
    return _GameplayViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is GameplayViewModelProvider && other.levelId == levelId;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, levelId.hashCode);

    return _SystemHash.finish(hash);
  }
}

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
mixin GameplayViewModelRef on AutoDisposeNotifierProviderRef<GameplayState> {
  /// The parameter `levelId` of this provider.
  String get levelId;
}

class _GameplayViewModelProviderElement
    extends AutoDisposeNotifierProviderElement<GameplayViewModel, GameplayState>
    with GameplayViewModelRef {
  _GameplayViewModelProviderElement(super.provider);

  @override
  String get levelId => (origin as GameplayViewModelProvider).levelId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
