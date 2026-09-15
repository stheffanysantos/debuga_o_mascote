/// Abstração sobre "quem é este aparelho" perante o Placar do Dia — um UID
/// estável por instalação/navegador, sem tela de login (ver
/// `.claude/memory/decisions.md`). `null` significa "identidade
/// indisponível agora" (Firebase não inicializado, sem internet) — quem
/// consome trata isso como "Placar indisponível", nunca crasha.
abstract class DeviceIdentity {
  Future<String?> currentUserId();
}
