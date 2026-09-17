import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'firebase_device_identity.dart';

part 'device_identity.g.dart';

/// Abstração sobre "quem é este aparelho" perante o Placar do Dia — um UID
/// estável por instalação/navegador, sem tela de login (ver
/// `.claude/memory/decisions.md`). `null` significa "identidade
/// indisponível agora" (Firebase não inicializado, sem internet) — quem
/// consome trata isso como "Placar indisponível", nunca crasha.
abstract class DeviceIdentity {
  Future<String?> currentUserId();
}

// `keepAlive: true` — provider de infraestrutura de longa duração, não pode
// ser descartado/recriado só porque nenhum widget está observando no
// momento (perderia o UID cacheado em memória).
@Riverpod(keepAlive: true)
DeviceIdentity deviceIdentity(Ref ref) => FirebaseDeviceIdentity();
