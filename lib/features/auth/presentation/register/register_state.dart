import 'package:freezed_annotation/freezed_annotation.dart';

part 'register_state.freezed.dart';

enum AuthMode { register, login }

/// Estado do formulário de Cadastro/Login — modo (cadastro vs. login), envio
/// em andamento e erro inline. Não guarda nome/email/senha: os
/// `TextEditingController`s continuam na `RegisterView` (não são amigáveis a
/// um estado imutável, e o Flutter já os gerencia bem ali).
@freezed
class RegisterState with _$RegisterState {
  const factory RegisterState({
    @Default(AuthMode.register) AuthMode mode,
    @Default(false) bool submitting,
    String? error,
  }) = _RegisterState;

  const RegisterState._();

  bool get isRegister => mode == AuthMode.register;
}
