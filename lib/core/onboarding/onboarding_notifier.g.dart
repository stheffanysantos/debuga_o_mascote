// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$onboardingNotifierHash() =>
    r'f20015fa3f216adb5c7ce4cd98cd02a9f352ebee';

/// `SplashView` consulta `seenWelcome` antes de navegar ao tocar "JOGAR"; se
/// `false`, empurra `WelcomeView` (3 slides + escolha de conta) em vez de ir
/// direto pra Seleção de Mundo. `WorldSelectView` consulta `hasSeen(world.number)`
/// antes de navegar; se `false`, empurra a `TutorialView` do mundo em vez de
/// navegar direto, e `markSeen` é chamado quando o jogador termina o
/// tutorial. `keepAlive: true` — pelo mesmo motivo de `ProgressNotifier`.
///
/// Persistido via `OnboardingRepository` (device-local, `shared_preferences`)
/// — antes ficava só em memória e resetava a cada reload da página/restart
/// do app, mostrando a apresentação da Libug/Lili de novo a cada visita
/// (achado real do usuário). `build()` devolve o estado vazio
/// **sincronamente** e hidrata como `Future` fire-and-forget, mesmo padrão
/// de `ProgressNotifier` — o jogo não espera a leitura do storage pra
/// renderizar a Splash.
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
