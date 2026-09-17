// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$leaderboardRepositoryHash() =>
    r'1d0e60ac5306882f400511dceceb996ccf5c5364';

/// Firebase configurado e inicializado com sucesso (ver `main.dart`) →
/// Firestore, compartilhado entre aparelhos. Caso contrário (sem projeto
/// configurado para esta plataforma, sem internet no boot) → cai para o
/// armazenamento local do aparelho, sem quebrar o Placar.
///
/// Copied from [leaderboardRepository].
@ProviderFor(leaderboardRepository)
final leaderboardRepositoryProvider = Provider<LeaderboardRepository>.internal(
  leaderboardRepository,
  name: r'leaderboardRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$leaderboardRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LeaderboardRepositoryRef = ProviderRef<LeaderboardRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
