// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'complete_code_gameplay_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$completeCodeGameplayViewModelHash() =>
    r'a9cefa2db8e998f804cab3f1df35c728ea08e598';

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

abstract class _$CompleteCodeGameplayViewModel
    extends BuildlessAutoDisposeNotifier<CompleteCodeGameplayState> {
  late final String levelId;

  CompleteCodeGameplayState build(String levelId);
}

/// ViewModel da Gameplay do Mundo 6 ("Complete o Código") — mesma forma de
/// `PredictOutputGameplayViewModel` (Mundo 5): sem passo a passo, cada
/// `confirm()` é um veredito único. Família por `levelId`.
///
/// Copied from [CompleteCodeGameplayViewModel].
@ProviderFor(CompleteCodeGameplayViewModel)
const completeCodeGameplayViewModelProvider =
    CompleteCodeGameplayViewModelFamily();

/// ViewModel da Gameplay do Mundo 6 ("Complete o Código") — mesma forma de
/// `PredictOutputGameplayViewModel` (Mundo 5): sem passo a passo, cada
/// `confirm()` é um veredito único. Família por `levelId`.
///
/// Copied from [CompleteCodeGameplayViewModel].
class CompleteCodeGameplayViewModelFamily
    extends Family<CompleteCodeGameplayState> {
  /// ViewModel da Gameplay do Mundo 6 ("Complete o Código") — mesma forma de
  /// `PredictOutputGameplayViewModel` (Mundo 5): sem passo a passo, cada
  /// `confirm()` é um veredito único. Família por `levelId`.
  ///
  /// Copied from [CompleteCodeGameplayViewModel].
  const CompleteCodeGameplayViewModelFamily();

  /// ViewModel da Gameplay do Mundo 6 ("Complete o Código") — mesma forma de
  /// `PredictOutputGameplayViewModel` (Mundo 5): sem passo a passo, cada
  /// `confirm()` é um veredito único. Família por `levelId`.
  ///
  /// Copied from [CompleteCodeGameplayViewModel].
  CompleteCodeGameplayViewModelProvider call(String levelId) {
    return CompleteCodeGameplayViewModelProvider(levelId);
  }

  @override
  CompleteCodeGameplayViewModelProvider getProviderOverride(
    covariant CompleteCodeGameplayViewModelProvider provider,
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
  String? get name => r'completeCodeGameplayViewModelProvider';
}

/// ViewModel da Gameplay do Mundo 6 ("Complete o Código") — mesma forma de
/// `PredictOutputGameplayViewModel` (Mundo 5): sem passo a passo, cada
/// `confirm()` é um veredito único. Família por `levelId`.
///
/// Copied from [CompleteCodeGameplayViewModel].
class CompleteCodeGameplayViewModelProvider
    extends
        AutoDisposeNotifierProviderImpl<
          CompleteCodeGameplayViewModel,
          CompleteCodeGameplayState
        > {
  /// ViewModel da Gameplay do Mundo 6 ("Complete o Código") — mesma forma de
  /// `PredictOutputGameplayViewModel` (Mundo 5): sem passo a passo, cada
  /// `confirm()` é um veredito único. Família por `levelId`.
  ///
  /// Copied from [CompleteCodeGameplayViewModel].
  CompleteCodeGameplayViewModelProvider(String levelId)
    : this._internal(
        () => CompleteCodeGameplayViewModel()..levelId = levelId,
        from: completeCodeGameplayViewModelProvider,
        name: r'completeCodeGameplayViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$completeCodeGameplayViewModelHash,
        dependencies: CompleteCodeGameplayViewModelFamily._dependencies,
        allTransitiveDependencies:
            CompleteCodeGameplayViewModelFamily._allTransitiveDependencies,
        levelId: levelId,
      );

  CompleteCodeGameplayViewModelProvider._internal(
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
  CompleteCodeGameplayState runNotifierBuild(
    covariant CompleteCodeGameplayViewModel notifier,
  ) {
    return notifier.build(levelId);
  }

  @override
  Override overrideWith(CompleteCodeGameplayViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: CompleteCodeGameplayViewModelProvider._internal(
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
    CompleteCodeGameplayViewModel,
    CompleteCodeGameplayState
  >
  createElement() {
    return _CompleteCodeGameplayViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CompleteCodeGameplayViewModelProvider &&
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
mixin CompleteCodeGameplayViewModelRef
    on AutoDisposeNotifierProviderRef<CompleteCodeGameplayState> {
  /// The parameter `levelId` of this provider.
  String get levelId;
}

class _CompleteCodeGameplayViewModelProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          CompleteCodeGameplayViewModel,
          CompleteCodeGameplayState
        >
    with CompleteCodeGameplayViewModelRef {
  _CompleteCodeGameplayViewModelProviderElement(super.provider);

  @override
  String get levelId =>
      (origin as CompleteCodeGameplayViewModelProvider).levelId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
