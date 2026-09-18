// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'code_puzzle_gameplay_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$codePuzzleGameplayViewModelHash() =>
    r'8897c3eba6b72f6bf978c72f7efa5ccfa42d5b44';

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

abstract class _$CodePuzzleGameplayViewModel
    extends BuildlessAutoDisposeNotifier<CodePuzzleGameplayState> {
  late final String levelId;

  CodePuzzleGameplayState build(String levelId);
}

/// ViewModel da Gameplay do Mundo 7 ("Modo Debug") — mesma forma de
/// `PredictOutputGameplayViewModel`/`CompleteCodeGameplayViewModel`: sem
/// passo a passo, cada `confirm()` é um veredito único. Família por
/// `levelId`.
///
/// Copied from [CodePuzzleGameplayViewModel].
@ProviderFor(CodePuzzleGameplayViewModel)
const codePuzzleGameplayViewModelProvider = CodePuzzleGameplayViewModelFamily();

/// ViewModel da Gameplay do Mundo 7 ("Modo Debug") — mesma forma de
/// `PredictOutputGameplayViewModel`/`CompleteCodeGameplayViewModel`: sem
/// passo a passo, cada `confirm()` é um veredito único. Família por
/// `levelId`.
///
/// Copied from [CodePuzzleGameplayViewModel].
class CodePuzzleGameplayViewModelFamily
    extends Family<CodePuzzleGameplayState> {
  /// ViewModel da Gameplay do Mundo 7 ("Modo Debug") — mesma forma de
  /// `PredictOutputGameplayViewModel`/`CompleteCodeGameplayViewModel`: sem
  /// passo a passo, cada `confirm()` é um veredito único. Família por
  /// `levelId`.
  ///
  /// Copied from [CodePuzzleGameplayViewModel].
  const CodePuzzleGameplayViewModelFamily();

  /// ViewModel da Gameplay do Mundo 7 ("Modo Debug") — mesma forma de
  /// `PredictOutputGameplayViewModel`/`CompleteCodeGameplayViewModel`: sem
  /// passo a passo, cada `confirm()` é um veredito único. Família por
  /// `levelId`.
  ///
  /// Copied from [CodePuzzleGameplayViewModel].
  CodePuzzleGameplayViewModelProvider call(String levelId) {
    return CodePuzzleGameplayViewModelProvider(levelId);
  }

  @override
  CodePuzzleGameplayViewModelProvider getProviderOverride(
    covariant CodePuzzleGameplayViewModelProvider provider,
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
  String? get name => r'codePuzzleGameplayViewModelProvider';
}

/// ViewModel da Gameplay do Mundo 7 ("Modo Debug") — mesma forma de
/// `PredictOutputGameplayViewModel`/`CompleteCodeGameplayViewModel`: sem
/// passo a passo, cada `confirm()` é um veredito único. Família por
/// `levelId`.
///
/// Copied from [CodePuzzleGameplayViewModel].
class CodePuzzleGameplayViewModelProvider
    extends
        AutoDisposeNotifierProviderImpl<
          CodePuzzleGameplayViewModel,
          CodePuzzleGameplayState
        > {
  /// ViewModel da Gameplay do Mundo 7 ("Modo Debug") — mesma forma de
  /// `PredictOutputGameplayViewModel`/`CompleteCodeGameplayViewModel`: sem
  /// passo a passo, cada `confirm()` é um veredito único. Família por
  /// `levelId`.
  ///
  /// Copied from [CodePuzzleGameplayViewModel].
  CodePuzzleGameplayViewModelProvider(String levelId)
    : this._internal(
        () => CodePuzzleGameplayViewModel()..levelId = levelId,
        from: codePuzzleGameplayViewModelProvider,
        name: r'codePuzzleGameplayViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$codePuzzleGameplayViewModelHash,
        dependencies: CodePuzzleGameplayViewModelFamily._dependencies,
        allTransitiveDependencies:
            CodePuzzleGameplayViewModelFamily._allTransitiveDependencies,
        levelId: levelId,
      );

  CodePuzzleGameplayViewModelProvider._internal(
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
  CodePuzzleGameplayState runNotifierBuild(
    covariant CodePuzzleGameplayViewModel notifier,
  ) {
    return notifier.build(levelId);
  }

  @override
  Override overrideWith(CodePuzzleGameplayViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: CodePuzzleGameplayViewModelProvider._internal(
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
    CodePuzzleGameplayViewModel,
    CodePuzzleGameplayState
  >
  createElement() {
    return _CodePuzzleGameplayViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is CodePuzzleGameplayViewModelProvider &&
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
mixin CodePuzzleGameplayViewModelRef
    on AutoDisposeNotifierProviderRef<CodePuzzleGameplayState> {
  /// The parameter `levelId` of this provider.
  String get levelId;
}

class _CodePuzzleGameplayViewModelProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          CodePuzzleGameplayViewModel,
          CodePuzzleGameplayState
        >
    with CodePuzzleGameplayViewModelRef {
  _CodePuzzleGameplayViewModelProviderElement(super.provider);

  @override
  String get levelId => (origin as CodePuzzleGameplayViewModelProvider).levelId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
