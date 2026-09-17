/// Abstração sobre cadastro/login real (nome/email/senha + Google) — mesmo
/// espírito de `LeaderboardRepository`/`SoundPlayer`: permite um fake nos
/// testes, sem precisar mockar o Firebase Auth de verdade. Ver
/// `.claude/memory/decisions.md`.
abstract class AuthService {
  /// `true` quando o usuário atual tem conta de verdade (não é anônimo).
  bool get hasAccount;

  /// Nome/e-mail do usuário logado, ou `null` sem conta.
  String? get displayName;

  /// Cria uma conta nova (ligada ao aparelho atual, preservando progresso
  /// já salvo sob o UID anônimo, ver `FirebaseAuthService`). Devolve uma
  /// mensagem de erro em pt-BR, ou `null` em caso de sucesso.
  Future<String?> registerWithEmail({required String name, required String email, required String password});

  /// Login numa conta já existente (ex.: criada noutro aparelho/sessão).
  Future<String?> signInWithEmail({required String email, required String password});

  /// Login/cadastro com Google — mesmo contrato de erro/sucesso acima.
  Future<String?> signInWithGoogle();

  /// Sai da conta atual — volta pro estado "sem conta" (o próximo acesso ao
  /// Firebase cria uma sessão anônima nova). Pensado pro estande, quando um
  /// jogador termina e outro vai jogar no mesmo aparelho ("Sou um novo
  /// jogador"). Nunca lança — mesmo contrato de resiliência dos outros
  /// métodos.
  Future<void> signOut();
}
