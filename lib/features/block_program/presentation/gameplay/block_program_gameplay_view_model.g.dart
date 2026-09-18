// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'block_program_gameplay_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$blockProgramGameplayViewModelHash() =>
    r'ef808118e141ddd1da51e52e2c4de0f7aaf073fc';

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

abstract class _$BlockProgramGameplayViewModel
    extends BuildlessAutoDisposeNotifier<BlockProgramGameplayState> {
  late final String levelId;

  BlockProgramGameplayState build(String levelId);
}

/// ViewModel da Gameplay dos Mundos 3/4 ("Programação em Blocos") — mesma
/// forma de `ConveyorGameplayViewModel` (Mundo 2): família por `levelId`,
/// orquestra a Execução (`BlockProgramExecutor`) passo a passo, incluindo o
/// timing da animação. A View só renderiza `state` e reage a
/// `state.pendingEffect`. Um único ViewModel serve os 2 mundos — a fase
/// (`world3Levels`/`world4Levels`) já sabe seu próprio `world`, e a View
/// decide a paleta de comandos a partir dele (ver
/// `lib/widgets/block_program_chip_style.dart`).
///
/// Diferente de `BeltExecutor` (Mundo 2), `BlockProgramExecutor` não tem
/// nenhuma falha por Passo (ver `.claude/docs/GAME_DESIGN.md`) — nem
/// "classificou errado", nem "zero Passos produzidos" (um "Para cada
/// número" sem bloco-alvo válido simplesmente não gera nenhum Passo, sem
/// precisar de um flash visual dedicado, diferente do "Enquanto" do Mundo
/// 2). Por isso o loop de execução aqui é mais simples: sempre percorre o
/// Programa por bloco, pulando só os modificadores `forEachNumber` (nunca
/// destacados diretamente — mesmo tratamento que `repeat` já recebe no
/// Mundo 2), e o único veredito é o resultado final
/// (`BlockProgramOutcome`).
///
/// Copied from [BlockProgramGameplayViewModel].
@ProviderFor(BlockProgramGameplayViewModel)
const blockProgramGameplayViewModelProvider =
    BlockProgramGameplayViewModelFamily();

/// ViewModel da Gameplay dos Mundos 3/4 ("Programação em Blocos") — mesma
/// forma de `ConveyorGameplayViewModel` (Mundo 2): família por `levelId`,
/// orquestra a Execução (`BlockProgramExecutor`) passo a passo, incluindo o
/// timing da animação. A View só renderiza `state` e reage a
/// `state.pendingEffect`. Um único ViewModel serve os 2 mundos — a fase
/// (`world3Levels`/`world4Levels`) já sabe seu próprio `world`, e a View
/// decide a paleta de comandos a partir dele (ver
/// `lib/widgets/block_program_chip_style.dart`).
///
/// Diferente de `BeltExecutor` (Mundo 2), `BlockProgramExecutor` não tem
/// nenhuma falha por Passo (ver `.claude/docs/GAME_DESIGN.md`) — nem
/// "classificou errado", nem "zero Passos produzidos" (um "Para cada
/// número" sem bloco-alvo válido simplesmente não gera nenhum Passo, sem
/// precisar de um flash visual dedicado, diferente do "Enquanto" do Mundo
/// 2). Por isso o loop de execução aqui é mais simples: sempre percorre o
/// Programa por bloco, pulando só os modificadores `forEachNumber` (nunca
/// destacados diretamente — mesmo tratamento que `repeat` já recebe no
/// Mundo 2), e o único veredito é o resultado final
/// (`BlockProgramOutcome`).
///
/// Copied from [BlockProgramGameplayViewModel].
class BlockProgramGameplayViewModelFamily
    extends Family<BlockProgramGameplayState> {
  /// ViewModel da Gameplay dos Mundos 3/4 ("Programação em Blocos") — mesma
  /// forma de `ConveyorGameplayViewModel` (Mundo 2): família por `levelId`,
  /// orquestra a Execução (`BlockProgramExecutor`) passo a passo, incluindo o
  /// timing da animação. A View só renderiza `state` e reage a
  /// `state.pendingEffect`. Um único ViewModel serve os 2 mundos — a fase
  /// (`world3Levels`/`world4Levels`) já sabe seu próprio `world`, e a View
  /// decide a paleta de comandos a partir dele (ver
  /// `lib/widgets/block_program_chip_style.dart`).
  ///
  /// Diferente de `BeltExecutor` (Mundo 2), `BlockProgramExecutor` não tem
  /// nenhuma falha por Passo (ver `.claude/docs/GAME_DESIGN.md`) — nem
  /// "classificou errado", nem "zero Passos produzidos" (um "Para cada
  /// número" sem bloco-alvo válido simplesmente não gera nenhum Passo, sem
  /// precisar de um flash visual dedicado, diferente do "Enquanto" do Mundo
  /// 2). Por isso o loop de execução aqui é mais simples: sempre percorre o
  /// Programa por bloco, pulando só os modificadores `forEachNumber` (nunca
  /// destacados diretamente — mesmo tratamento que `repeat` já recebe no
  /// Mundo 2), e o único veredito é o resultado final
  /// (`BlockProgramOutcome`).
  ///
  /// Copied from [BlockProgramGameplayViewModel].
  const BlockProgramGameplayViewModelFamily();

  /// ViewModel da Gameplay dos Mundos 3/4 ("Programação em Blocos") — mesma
  /// forma de `ConveyorGameplayViewModel` (Mundo 2): família por `levelId`,
  /// orquestra a Execução (`BlockProgramExecutor`) passo a passo, incluindo o
  /// timing da animação. A View só renderiza `state` e reage a
  /// `state.pendingEffect`. Um único ViewModel serve os 2 mundos — a fase
  /// (`world3Levels`/`world4Levels`) já sabe seu próprio `world`, e a View
  /// decide a paleta de comandos a partir dele (ver
  /// `lib/widgets/block_program_chip_style.dart`).
  ///
  /// Diferente de `BeltExecutor` (Mundo 2), `BlockProgramExecutor` não tem
  /// nenhuma falha por Passo (ver `.claude/docs/GAME_DESIGN.md`) — nem
  /// "classificou errado", nem "zero Passos produzidos" (um "Para cada
  /// número" sem bloco-alvo válido simplesmente não gera nenhum Passo, sem
  /// precisar de um flash visual dedicado, diferente do "Enquanto" do Mundo
  /// 2). Por isso o loop de execução aqui é mais simples: sempre percorre o
  /// Programa por bloco, pulando só os modificadores `forEachNumber` (nunca
  /// destacados diretamente — mesmo tratamento que `repeat` já recebe no
  /// Mundo 2), e o único veredito é o resultado final
  /// (`BlockProgramOutcome`).
  ///
  /// Copied from [BlockProgramGameplayViewModel].
  BlockProgramGameplayViewModelProvider call(String levelId) {
    return BlockProgramGameplayViewModelProvider(levelId);
  }

  @override
  BlockProgramGameplayViewModelProvider getProviderOverride(
    covariant BlockProgramGameplayViewModelProvider provider,
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
  String? get name => r'blockProgramGameplayViewModelProvider';
}

/// ViewModel da Gameplay dos Mundos 3/4 ("Programação em Blocos") — mesma
/// forma de `ConveyorGameplayViewModel` (Mundo 2): família por `levelId`,
/// orquestra a Execução (`BlockProgramExecutor`) passo a passo, incluindo o
/// timing da animação. A View só renderiza `state` e reage a
/// `state.pendingEffect`. Um único ViewModel serve os 2 mundos — a fase
/// (`world3Levels`/`world4Levels`) já sabe seu próprio `world`, e a View
/// decide a paleta de comandos a partir dele (ver
/// `lib/widgets/block_program_chip_style.dart`).
///
/// Diferente de `BeltExecutor` (Mundo 2), `BlockProgramExecutor` não tem
/// nenhuma falha por Passo (ver `.claude/docs/GAME_DESIGN.md`) — nem
/// "classificou errado", nem "zero Passos produzidos" (um "Para cada
/// número" sem bloco-alvo válido simplesmente não gera nenhum Passo, sem
/// precisar de um flash visual dedicado, diferente do "Enquanto" do Mundo
/// 2). Por isso o loop de execução aqui é mais simples: sempre percorre o
/// Programa por bloco, pulando só os modificadores `forEachNumber` (nunca
/// destacados diretamente — mesmo tratamento que `repeat` já recebe no
/// Mundo 2), e o único veredito é o resultado final
/// (`BlockProgramOutcome`).
///
/// Copied from [BlockProgramGameplayViewModel].
class BlockProgramGameplayViewModelProvider
    extends
        AutoDisposeNotifierProviderImpl<
          BlockProgramGameplayViewModel,
          BlockProgramGameplayState
        > {
  /// ViewModel da Gameplay dos Mundos 3/4 ("Programação em Blocos") — mesma
  /// forma de `ConveyorGameplayViewModel` (Mundo 2): família por `levelId`,
  /// orquestra a Execução (`BlockProgramExecutor`) passo a passo, incluindo o
  /// timing da animação. A View só renderiza `state` e reage a
  /// `state.pendingEffect`. Um único ViewModel serve os 2 mundos — a fase
  /// (`world3Levels`/`world4Levels`) já sabe seu próprio `world`, e a View
  /// decide a paleta de comandos a partir dele (ver
  /// `lib/widgets/block_program_chip_style.dart`).
  ///
  /// Diferente de `BeltExecutor` (Mundo 2), `BlockProgramExecutor` não tem
  /// nenhuma falha por Passo (ver `.claude/docs/GAME_DESIGN.md`) — nem
  /// "classificou errado", nem "zero Passos produzidos" (um "Para cada
  /// número" sem bloco-alvo válido simplesmente não gera nenhum Passo, sem
  /// precisar de um flash visual dedicado, diferente do "Enquanto" do Mundo
  /// 2). Por isso o loop de execução aqui é mais simples: sempre percorre o
  /// Programa por bloco, pulando só os modificadores `forEachNumber` (nunca
  /// destacados diretamente — mesmo tratamento que `repeat` já recebe no
  /// Mundo 2), e o único veredito é o resultado final
  /// (`BlockProgramOutcome`).
  ///
  /// Copied from [BlockProgramGameplayViewModel].
  BlockProgramGameplayViewModelProvider(String levelId)
    : this._internal(
        () => BlockProgramGameplayViewModel()..levelId = levelId,
        from: blockProgramGameplayViewModelProvider,
        name: r'blockProgramGameplayViewModelProvider',
        debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
            ? null
            : _$blockProgramGameplayViewModelHash,
        dependencies: BlockProgramGameplayViewModelFamily._dependencies,
        allTransitiveDependencies:
            BlockProgramGameplayViewModelFamily._allTransitiveDependencies,
        levelId: levelId,
      );

  BlockProgramGameplayViewModelProvider._internal(
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
  BlockProgramGameplayState runNotifierBuild(
    covariant BlockProgramGameplayViewModel notifier,
  ) {
    return notifier.build(levelId);
  }

  @override
  Override overrideWith(BlockProgramGameplayViewModel Function() create) {
    return ProviderOverride(
      origin: this,
      override: BlockProgramGameplayViewModelProvider._internal(
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
    BlockProgramGameplayViewModel,
    BlockProgramGameplayState
  >
  createElement() {
    return _BlockProgramGameplayViewModelProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is BlockProgramGameplayViewModelProvider &&
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
mixin BlockProgramGameplayViewModelRef
    on AutoDisposeNotifierProviderRef<BlockProgramGameplayState> {
  /// The parameter `levelId` of this provider.
  String get levelId;
}

class _BlockProgramGameplayViewModelProviderElement
    extends
        AutoDisposeNotifierProviderElement<
          BlockProgramGameplayViewModel,
          BlockProgramGameplayState
        >
    with BlockProgramGameplayViewModelRef {
  _BlockProgramGameplayViewModelProviderElement(super.provider);

  @override
  String get levelId =>
      (origin as BlockProgramGameplayViewModelProvider).levelId;
}

// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
