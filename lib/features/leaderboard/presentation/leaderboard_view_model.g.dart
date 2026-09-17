// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leaderboard_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$leaderboardViewModelHash() =>
    r'4547aaa5d0d65d03ba965c2009a5975f9ef58641';

/// Carrega o Placar Geral — estado async real (ver plano de migração, §4:
/// "leaderboard ganha ViewModel de verdade"). Sem `LeaderboardState`
/// próprio: `AsyncValue<LeaderboardData>` já modela loading/data/erro
/// sozinho, embrulhar isso numa classe `@freezed` só duplicaria o que o
/// riverpod_generator já gera de graça para um `build()` que devolve
/// `Future<T>`. `autoDispose` (padrão) é o comportamento certo — o ranking é
/// só desta tela, não precisa sobreviver depois que ela fecha.
///
/// Copied from [LeaderboardViewModel].
@ProviderFor(LeaderboardViewModel)
final leaderboardViewModelProvider =
    AutoDisposeAsyncNotifierProvider<
      LeaderboardViewModel,
      LeaderboardData
    >.internal(
      LeaderboardViewModel.new,
      name: r'leaderboardViewModelProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$leaderboardViewModelHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$LeaderboardViewModel = AutoDisposeAsyncNotifier<LeaderboardData>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
