// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'conveyor_gameplay_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$conveyorGameplayViewModelHash() =>
    r'8254b42dd4e05bf6544415babecc0d40648efc0b';

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

abstract class _$ConveyorGameplayViewModel
    extends BuildlessAutoDisposeNotifier<ConveyorGameplayState> {
  late final String levelId;

  ConveyorGameplayState build(String levelId);
}

/// ViewModel da Gameplay do Mundo 2 (Esteira) — mesma forma de
/// `GameplayViewModel` (Mundo 1): família por `levelId`, orquestra a
/// Execução (`BeltExecutor`) passo a passo, incluindo o timing da animação.
/// A View só renderiza `state` e reage a `state.pendingEffect`.
///
/// Copied from [ConveyorGameplayViewModel].
@ProviderFor(ConveyorGameplayViewModel)
const conveyorGameplayViewModelProvider = ConveyorGameplayViewModelFamily();

/// ViewModel da Gameplay do Mundo 2 (Esteira) — mesma forma de
/// `GameplayViewModel` (Mundo 1): família por `levelId`, orquestra a
/// Execução (`BeltExecutor`) passo a passo, incluindo o timing da animação.
/// A View só renderiza `state` e reage a `state.pendingEffect`.
///
/// Copied from [ConveyorGameplayViewModel].
class ConveyorGameplayViewModelFamily extends Family<ConveyorGameplayState> {
  /// ViewModel da Gameplay do Mundo 2 (Esteira) — mesma forma de
  /// `GameplayViewModel` (Mundo 1): família por `levelId`, orquestra a
  /// Execução (`BeltExecutor`) passo a passo, incluindo o timing da animação.
  /// A View só renderiza `state` e reage a `state.pendingEffect`.
  ///
  /// Copied from [ConveyorGameplayViewModel].
  const ConveyorGameplayViewModelFamily();

  /// ViewModel da Gameplay do Mundo 2 (Esteira) — mesma forma de
  /// `GameplayViewModel` (Mundo 1): família por `levelId`, orquestra a
  /// Execução (`BeltExecutor`) passo a passo, incluindo o timing da animação.
  /// A View só renderiza `state` e reage a `state.pendingEffect`.
  ///
  /// Copied from [ConveyorGameplayViewModel].
  ConveyorGameplayViewModelProvider call(String levelId) {
    return ConveyorGameplayViewModelProvider(levelId);
  }

  @override
  ConveyorGameplayViewModelProvider getProviderOverride(
    covariant ConveyorGameplayViewModelProvider provider,
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
  String? get name => r'conveyorGameplayViewModelProvider';
}

/// ViewModel da Gameplay do Mundo 2 (Esteira) — mesma forma de
/// `GameplayViewModel` (Mundo 1): família por `levelId`, orquestra a
/// Execução (`BeltExecutor`) passo a passo, incluindo o timing da animação.
/// A View só renderiza `state` e reage a `state.pendingEffect`.
///
/// Copied from [ConveyorGameplayViewModel].
class ConveyorGameplayViewModelProvider
    extends
        AutoDisposeNotifierProviderImpl<
          ConveyorGameplayViewModel,
          ConveyorGameplayState
        > {
  /// ViewModel da Gameplay do Mundo 2 (Esteira) — mesma forma de
  /// `GameplayViewModel` (Mundo 1): família por `levelId`, orquestra a
  /// Execução (`BeltExecutor`) passo a passo, incluindo o timing da animação.
  /// A View só renderiza `state` e reage a `state.pendingEffect`.
  ///
  /// Copied from [ConveyorGameplayViewModel].
  ConveyorGameplayViewModelProvider(String levelId)
    : this._internal(
        () => ConveyorGameplayViewModel()..levelId = levelId,
        from: conveyorGameplayViewModelProvider,
        name: r'conveyorGameplayViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$conveyorGameplayViewModelHash,
        dependencies: ConveyorGameplayViewModelFamily._dependencies,
        allTransitiveDependencies:
            ConveyorGameplayViewModelFamily._allTransitiveDependencies,
        levelId: levelId,
      );

  ConveyorGameplayViewModelProvider._internal(
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
  ConveyorGameplayState runNotifierBuild(
    covariant ConveyorGameplayViewModel notifier,
  ) {
    return notifier.build(levelId);
  }

  @override
  Override overrideWith(ConveyorGameplayViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: ConveyorGameplayViewModelProvider._internal(
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
  AutoDisposeNotifierProviderElement<
    ConveyorGameplayViewModel,
    ConveyorGameplayState
  >
  createElement() {
    return _ConveyorGameplayViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is ConveyorGameplayViewModelProvider &&
        other.levelId == levelId;
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
mixin ConveyorGameplayViewModelRef
    on AutoDisposeNotifierProviderRef<ConveyorGameplayState> {
  /// The parameter `levelId` of this provider.
  String get levelId;
}

class _ConveyorGameplayViewModelProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          ConveyorGameplayViewModel,
          ConveyorGameplayState
        >
    with ConveyorGameplayViewModelRef {
  _ConveyorGameplayViewModelProviderElement(super.provider);

  @override
  String get levelId => (origin as ConveyorGameplayViewModelProvider).levelId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
