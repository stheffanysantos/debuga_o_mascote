import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme/app_colors.dart';
import '../../../../theme/app_icons.dart';
import '../../../../theme/app_shadows.dart';
import '../../../../theme/app_text.dart';
import '../../../../widgets/dotted_background_widget.dart';
import '../../../../widgets/hard_shadow_box_widget.dart';
import '../../../../widgets/icon_action_button_widget.dart';
import '../../../../widgets/labeled_text_field_widget.dart';
import '../../../../widgets/primary_pill_button_widget.dart';
import 'register_state.dart';
import 'register_view_model.dart';

/// Cadastro real (nome/email/senha + Google), via `RegisterViewModel` — ver
/// `.claude/memory/decisions.md`.
///
/// `mandatory: true` (gatilho de fim de Trilha 1): sem botão de fechar,
/// `PopScope(canPop: false)` — mas sempre com um link discreto "Continuar
/// sem conta por enquanto" no rodapé, pra nunca travar o app se o Firebase
/// estiver indisponível (nota de resiliência, ver decisions.md).
/// `mandatory: false` (aberto pelas Configurações): botão de fechar normal.
class RegisterView extends ConsumerStatefulWidget {
  final bool mandatory;
  final VoidCallback onDone;

  /// Modo inicial do formulário — `register` (padrão) ou `login`. Usado por
  /// `WelcomeView` pra abrir já em "Entrar" quando o jogador escolhe "Já
  /// tenho conta" (em vez de exigir um toque extra em "Já tem conta? Entrar").
  final AuthMode initialMode;

  const RegisterView({super.key, required this.mandatory, required this.onDone, this.initialMode = AuthMode.register});

  @override
  ConsumerState<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends ConsumerState<RegisterView> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.initialMode == AuthMode.login) {
      // Adiado pro fim do frame — chamar `setMode` (que muda `state`) direto
      // em `initState` acontece durante o build da árvore, e o Riverpod
      // proíbe modificar um provider nesse momento (erro real encontrado ao
      // testar: "Tried to modify a provider while the widget tree was
      // building").
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ref.read(registerViewModelProvider.notifier).setMode(widget.initialMode);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _canSubmitEmail(RegisterState state) {
    if (state.submitting) return false;
    final emailOk = _emailController.text.trim().contains('@');
    final passwordOk = _passwordController.text.length >= 6;
    if (state.isRegister) {
      return _nameController.text.trim().isNotEmpty && emailOk && passwordOk;
    }
    return emailOk && passwordOk;
  }

  Future<void> _submitEmail(RegisterState state) async {
    final ok = await ref.read(registerViewModelProvider.notifier).submitEmail(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
    if (ok && mounted) widget.onDone();
  }

  Future<void> _submitGoogle() async {
    final ok = await ref.read(registerViewModelProvider.notifier).submitGoogle();
    if (ok && mounted) widget.onDone();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(registerViewModelProvider);
    final isRegister = state.isRegister;

    return PopScope(
      canPop: !widget.mandatory,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Stack(
          children: [
            const DottedBackground(),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 14, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!widget.mandatory)
                      IconActionButton(
                        background: AppColors.grayButton,
                        shadowColor: Colors.transparent,
                        icon: AppIcons.chevronLeft(size: 22, color: AppColors.white),
                        onTap: () => Navigator.of(context).pop(),
                      ),
                    SizedBox(height: widget.mandatory ? 8 : 22),
                    Text('DEBUGA O MASCOTE', style: AppText.eyebrow(size: 13)),
                    Text(
                      isRegister ? 'Crie sua conta' : 'Entrar',
                      style: AppText.style(size: 28, weight: FontWeight.w900, color: AppColors.white, height: 1.05),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.mandatory
                          ? 'Você terminou a Trilha 1! Crie uma conta pra continuar salvando seu progresso.'
                          : 'Salve seu progresso pra continuar de onde parou.',
                      style: AppText.style(size: 14, weight: FontWeight.w800, color: AppColors.white.withValues(alpha: 0.7), height: 1.3),
                    ),
                    const SizedBox(height: 24),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (isRegister) ...[
                              LabeledTextField(
                                label: 'Seu nome',
                                controller: _nameController,
                                hint: 'Como podemos te chamar?',
                                onChanged: (_) => setState(() {}),
                              ),
                              const SizedBox(height: 20),
                            ],
                            LabeledTextField(
                              label: 'E-mail',
                              controller: _emailController,
                              hint: 'seu@email.com',
                              keyboardType: TextInputType.emailAddress,
                              onChanged: (_) => setState(() {}),
                            ),
                            const SizedBox(height: 20),
                            LabeledTextField(
                              label: 'Senha',
                              controller: _passwordController,
                              hint: 'Pelo menos 6 caracteres',
                              obscureText: true,
                              onChanged: (_) => setState(() {}),
                            ),
                            if (state.error != null) ...[
                              const SizedBox(height: 16),
                              Text(state.error!, style: AppText.style(size: 13, weight: FontWeight.w800, color: AppColors.yellowNeon, height: 1.3)),
                            ],
                            const SizedBox(height: 16),
                            Center(
                              child: GestureDetector(
                                onTap: state.submitting ? null : ref.read(registerViewModelProvider.notifier).toggleMode,
                                child: Text(
                                  isRegister ? 'Já tem conta? Entrar' : 'Não tem conta? Criar',
                                  style: AppText.style(size: 14, weight: FontWeight.w800, color: AppColors.lilac),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(child: Divider(color: AppColors.grayButton, thickness: 1)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('ou', style: AppText.style(size: 12, weight: FontWeight.w800, color: AppColors.white.withValues(alpha: 0.5))),
                                ),
                                Expanded(child: Divider(color: AppColors.grayButton, thickness: 1)),
                              ],
                            ),
                            const SizedBox(height: 20),
                            HardShadowBox(
                              color: AppColors.panel,
                              shadows: AppShadows.hard(AppColors.grayButton),
                              border: Border.all(color: AppColors.grayButton, width: 2),
                              onTap: state.submitting ? null : _submitGoogle,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              child: Center(
                                child: Text('Continuar com Google', style: AppText.style(size: 16, weight: FontWeight.w900, color: AppColors.white)),
                              ),
                            ),
                            if (widget.mandatory) ...[
                              const SizedBox(height: 24),
                              Center(
                                child: GestureDetector(
                                  onTap: state.submitting ? null : widget.onDone,
                                  child: Text(
                                    'Continuar sem conta por enquanto',
                                    style: AppText.style(size: 13, weight: FontWeight.w800, color: AppColors.white.withValues(alpha: 0.5)),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    PrimaryPillButton(
                      label: isRegister ? 'Criar conta' : 'Entrar',
                      height: 64,
                      fontSize: 20,
                      enabled: _canSubmitEmail(state),
                      onTap: () => _submitEmail(state),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
