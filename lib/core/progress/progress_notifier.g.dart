// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'progress_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$progressNotifierHash() => r'330f5e444eaf93b03d743b45994a2f03f3352e75';

/// Progresso do jogador — vive em memória durante a sessão, mas é
/// sincronizado com o Firestore por `ProgressRepository`. `build()` devolve
/// um `ProgressState` vazio **sincronamente** e dispara a hidratação como
/// `Future` fire-and-forget (`_hydrate`) — o jogo é 100% jogável antes/sem
/// hidratação (resiliência de estande: sem internet no evento é um caso
/// real). Ver `.claude/memory/decisions.md`.
///
/// `keepAlive: true` — é o progresso do jogador inteiro, não pode ser
/// descartado/reiniciado só porque nenhuma tela está observando no
/// momento (o padrão de `@riverpod` sem essa flag é `autoDispose`).
///
/// Copied from [ProgressNotifier].
@ProviderFor(ProgressNotifier)
final progressNotifierProvider =
    NotifierProvider<ProgressNotifier, ProgressState>.internal(
      ProgressNotifier.new,
      name: r'progressNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$progressNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ProgressNotifier = Notifier<ProgressState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
