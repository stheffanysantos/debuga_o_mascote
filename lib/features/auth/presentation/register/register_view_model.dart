import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/auth/auth_providers.dart';
import '../../../../core/progress/progress_notifier.dart';
import 'register_state.dart';

part 'register_view_model.g.dart';

/// Formulário de cadastro/login — estado real (modo, envio em andamento,
/// erro inline) vale um ViewModel de verdade (ver plano de migração, §4).
@riverpod
class RegisterViewModel extends _$RegisterViewModel {
  // Mesmo padrão de `ProgressNotifier`/`GameplayViewModel` — `Ref.mounted`
  // não existe nesta versão do riverpod.
  bool _disposed = false;

  @override
  RegisterState build() {
    ref.onDispose(() => _disposed = true);
    return const RegisterState();
  }

  void toggleMode() => state = state.copyWith(mode: state.isRegister ? AuthMode.login : AuthMode.register, error: null);

  /// Define o modo inicial explicitamente — usado por `RegisterView.initialMode`
  /// (ex.: `WelcomeView` abre já em modo `login` quando o jogador escolhe
  /// "Já tenho conta").
  void setMode(AuthMode mode) => state = state.copyWith(mode: mode, error: null);

  Future<bool> submitEmail({required String name, required String email, required String password}) {
    final authService = ref.read(authServiceProvider);
    return _runAuthAction(() => state.isRegister
        ? authService.registerWithEmail(name: name, email: email, password: password)
        : authService.signInWithEmail(email: email, password: password));
  }

  Future<bool> submitGoogle() => _runAuthAction(() => ref.read(authServiceProvider).signInWithGoogle());

  /// Devolve `true` em sucesso — a View decide o que fazer (`onDone()`).
  Future<bool> _runAuthAction(Future<String?> Function() action) async {
    state = state.copyWith(submitting: true, error: null);
    final error = await action();
    if (_disposed) return false;
    if (error != null) {
      state = state.copyWith(submitting: false, error: error);
      return false;
    }
    // Recarrega o progresso do UID resultante — na maioria dos casos é o
    // mesmo UID anônimo de antes (linkado, progresso já é o mesmo), mas se
    // a conta já existia noutro aparelho/sessão, isso puxa o progresso de
    // verdade daquela conta (ver `.claude/memory/decisions.md`).
    await ref.read(progressNotifierProvider.notifier).rehydrate();
    if (_disposed) return false;
    state = state.copyWith(submitting: false);
    return true;
  }
}
