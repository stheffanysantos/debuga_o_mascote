import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/progress/progress_notifier.dart';
import 'features/splash/presentation/splash_view.dart';
import 'firebase_options.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {
    // Sem projeto configurado corretamente para esta plataforma, ou sem
    // internet no estande — o jogo continua 100% jogável, só o Placar do
    // Dia e a sincronização de progresso via Firebase ficam indisponíveis
    // (Leaderboard cai para o armazenamento local, ver lib/core/leaderboard/).
  }

  // Container criado explicitamente (em vez de deixar o 1º `ConsumerWidget`
  // criar um implícito) só pra poder ler `progressNotifierProvider` uma vez
  // aqui — isso já dispara a hidratação fire-and-forget do progresso
  // (`ProgressNotifier.build()`) o mais cedo possível, sem travar o
  // primeiro frame — mesmo comportamento de antes da migração pra
  // Riverpod (`unawaited(ProgressSync.instance.hydrate())`).
  final container = ProviderContainer();
  container.read(progressNotifierProvider);

  runApp(UncontrolledProviderScope(container: container, child: const DebugaOMascoteApp()));
}

class DebugaOMascoteApp extends StatelessWidget {
  const DebugaOMascoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Debuga o Mascote',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashView(),
    );
  }
}
