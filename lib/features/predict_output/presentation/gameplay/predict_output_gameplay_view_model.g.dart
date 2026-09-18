// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'predict_output_gameplay_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$predictOutputGameplayViewModelHash() =>
    r'7529c71c77c44d6e516c2e84a99773e3117237c9';

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

abstract class _$PredictOutputGameplayViewModel
    extends BuildlessAutoDisposeNotifier<PredictOutputGameplayState> {
  late final String levelId;

  PredictOutputGameplayState build(String levelId);
}

/// ViewModel da Gameplay do Mundo 5 ("Preveja a Saída") — sem passo a passo
/// (diferente de `GameplayViewModel`/`ConveyorGameplayViewModel`): cada
/// `confirm()` é um veredito único, calculado na hora a partir da opção
/// escolhida. Família por `levelId`.
///
/// Copied from [PredictOutputGameplayViewModel].
@ProviderFor(PredictOutputGameplayViewModel)
const predictOutputGameplayViewModelProvider =
    PredictOutputGameplayViewModelFamily();

/// ViewModel da Gameplay do Mundo 5 ("Preveja a Saída") — sem passo a passo
/// (diferente de `GameplayViewModel`/`ConveyorGameplayViewModel`): cada
/// `confirm()` é um veredito único, calculado na hora a partir da opção
/// escolhida. Família por `levelId`.
///
/// Copied from [PredictOutputGameplayViewModel].
class PredictOutputGameplayViewModelFamily
    extends Family<PredictOutputGameplayState> {
  /// ViewModel da Gameplay do Mundo 5 ("Preveja a Saída") — sem passo a passo
  /// (diferente de `GameplayViewModel`/`ConveyorGameplayViewModel`): cada
  /// `confirm()` é um veredito único, calculado na hora a partir da opção
  /// escolhida. Família por `levelId`.
  ///
  /// Copied from [PredictOutputGameplayViewModel].
  const PredictOutputGameplayViewModelFamily();

  /// ViewModel da Gameplay do Mundo 5 ("Preveja a Saída") — sem passo a passo
  /// (diferente de `GameplayViewModel`/`ConveyorGameplayViewModel`): cada
  /// `confirm()` é um veredito único, calculado na hora a partir da opção
  /// escolhida. Família por `levelId`.
  ///
  /// Copied from [PredictOutputGameplayViewModel].
  PredictOutputGameplayViewModelProvider call(String levelId) {
    return PredictOutputGameplayViewModelProvider(levelId);
  }

  @override
  PredictOutputGameplayViewModelProvider getProviderOverride(
    covariant PredictOutputGameplayViewModelProvider provider,
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
  String? get name => r'predictOutputGameplayViewModelProvider';
}

/// ViewModel da Gameplay do Mundo 5 ("Preveja a Saída") — sem passo a passo
/// (diferente de `GameplayViewModel`/`ConveyorGameplayViewModel`): cada
/// `confirm()` é um veredito único, calculado na hora a partir da opção
/// escolhida. Família por `levelId`.
///
/// Copied from [PredictOutputGameplayViewModel].
class PredictOutputGameplayViewModelProvider
    extends
        AutoDisposeNotifierProviderImpl<
          PredictOutputGameplayViewModel,
          PredictOutputGameplayState
        > {
  /// ViewModel da Gameplay do Mundo 5 ("Preveja a Saída") — sem passo a passo
  /// (diferente de `GameplayViewModel`/`ConveyorGameplayViewModel`): cada
  /// `confirm()` é um veredito único, calculado na hora a partir da opção
  /// escolhida. Família por `levelId`.
  ///
  /// Copied from [PredictOutputGameplayViewModel].
  PredictOutputGameplayViewModelProvider(String levelId)
    : this._internal(
        () => PredictOutputGameplayViewModel()..levelId = levelId,
        from: predictOutputGameplayViewModelProvider,
        name: r'predictOutputGameplayViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$predictOutputGameplayViewModelHash,
        dependencies: PredictOutputGameplayViewModelFamily._dependencies,
        allTransitiveDependencies:
            PredictOutputGameplayViewModelFamily._allTransitiveDependencies,
        levelId: levelId,
      );

  PredictOutputGameplayViewModelProvider._internal(
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
  PredictOutputGameplayState runNotifierBuild(
    covariant PredictOutputGameplayViewModel notifier,
  ) {
    return notifier.build(levelId);
  }

  @override
  Override overrideWith(PredictOutputGameplayViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: PredictOutputGameplayViewModelProvider._internal(
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
    PredictOutputGameplayViewModel,
    PredictOutputGameplayState
  >
  createElement() {
    return _PredictOutputGameplayViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is PredictOutputGameplayViewModelProvider &&
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
mixin PredictOutputGameplayViewModelRef
    on AutoDisposeNotifierProviderRef<PredictOutputGameplayState> {
  /// The parameter `levelId` of this provider.
  String get levelId;
}

class _PredictOutputGameplayViewModelProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          PredictOutputGameplayViewModel,
          PredictOutputGameplayState
        >
    with PredictOutputGameplayViewModelRef {
  _PredictOutputGameplayViewModelProviderElement(super.provider);

  @override
  String get levelId =>
      (origin as PredictOutputGameplayViewModelProvider).levelId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
