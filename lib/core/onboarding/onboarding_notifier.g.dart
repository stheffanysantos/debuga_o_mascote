// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$onboardingNotifierHash() =>
    r'9c031bad1217831536117f85eb628d89f305d535';

/// `SplashView` consulta `seenWelcome` antes de navegar ao tocar "JOGAR"; se
/// `false`, empurra `WelcomeView` (3 slides + escolha de conta) em vez de ir
/// direto pra Seleção de Mundo. `WorldSelectView` consulta `hasSeen(world.number)`
/// antes de navegar; se `false`, empurra a `TutorialView` do mundo em vez de
/// navegar direto, e `markSeen` é chamado quando o jogador termina o
/// tutorial. `keepAlive: true` — pelo mesmo motivo de `ProgressNotifier`.
///
/// Copied from [OnboardingNotifier].
@ProviderFor(OnboardingNotifier)
final onboardingNotifierProvider =
    NotifierProvider<OnboardingNotifier, OnboardingState>.internal(
      OnboardingNotifier.new,
      name: r'onboardingNotifierProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$onboardingNotifierHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$OnboardingNotifier = Notifier<OnboardingState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
