import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'data/progress_sync.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    // Fire-and-forget de propósito — não trava o primeiro frame esperando a
    // rede. `Progress.instance` começa zerado e é restaurado assim que
    // `hydrate()` terminar (ver lib/data/progress_sync.dart).
    unawaited(ProgressSync.instance.hydrate());
  } catch (_) {
    // Sem projeto configurado corretamente para esta plataforma, ou sem
    // internet no estande — o jogo continua 100% jogável, só o Placar do
    // Dia e a sincronização de progresso via Firebase ficam indisponíveis
    // (Leaderboard cai para o armazenamento local, ver lib/data/leaderboard.dart).
  }
  runApp(const DebugaOMascoteApp());
}

class DebugaOMascoteApp extends StatelessWidget {
  const DebugaOMascoteApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Debuga o Mascote',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      home: const SplashScreen(),
    );
  }
}
