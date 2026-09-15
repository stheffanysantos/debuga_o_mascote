import 'package:flutter/material.dart';

import '../data/app_auth.dart';
import '../data/progress_sync.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text.dart';
import '../widgets/dotted_background_widget.dart';
import '../widgets/hard_shadow_box_widget.dart';
import '../widgets/icon_action_button_widget.dart';
import '../widgets/labeled_text_field_widget.dart';
import '../widgets/primary_pill_button_widget.dart';

enum _AuthMode { register, login }

/// Cadastro real (nome/email/senha + Google), via `AppAuth.instance` — ver
/// `.claude/memory/decisions.md`.
///
/// `mandatory: true` (gatilho de fim de Trilha 1): sem botão de fechar,
/// `PopScope(canPop: false)` — mas sempre com um link discreto "Continuar
/// sem conta por enquanto" no rodapé, pra nunca travar o app se o Firebase
/// estiver indisponível (nota de resiliência, ver decisions.md).
/// `mandatory: false` (aberto pelas Configurações): botão de fechar normal.
class RegisterScreen extends StatefulWidget {
  final bool mandatory;
  final VoidCallback onDone;

  const RegisterScreen({super.key, required this.mandatory, required this.onDone});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  _AuthMode _mode = _AuthMode.register;
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _isRegister => _mode == _AuthMode.register;

  bool get _canSubmitEmail {
    if (_submitting) return false;
    final emailOk = _emailController.text.trim().contains('@');
    final passwordOk = _passwordController.text.length >= 6;
    if (_isRegister) {
      return _nameController.text.trim().isNotEmpty && emailOk && passwordOk;
    }
    return emailOk && passwordOk;
  }

  Future<void> _runAuthAction(Future<String?> Function() action) async {
    setState(() {
      _submitting = true;
      _error = null;
    });
    final error = await action();
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _submitting = false;
        _error = error;
      });
      return;
    }
    // Recarrega o progresso do UID resultante — na maioria dos casos é o
    // mesmo UID anônimo de antes (linkado, progresso já é o mesmo), mas se
    // a conta já existia noutro aparelho/sessão, isso puxa o progresso de
    // verdade daquela conta (ver `.claude/memory/decisions.md`).
    await ProgressSync.instance.hydrate();
    if (!mounted) return;
    widget.onDone();
  }

  Future<void> _submitEmail() {
    return _runAuthAction(() => _isRegister
        ? AppAuth.instance.registerWithEmail(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            password: _passwordController.text,
          )
        : AppAuth.instance.signInWithEmail(email: _emailController.text.trim(), password: _passwordController.text));
  }

  Future<void> _submitGoogle() => _runAuthAction(() => AppAuth.instance.signInWithGoogle());

  void _toggleMode() {
    setState(() {
      _mode = _isRegister ? _AuthMode.login : _AuthMode.register;
      _error = null;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                      _isRegister ? 'Crie sua conta' : 'Entrar',
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
                            if (_isRegister) ...[
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
                            if (_error != null) ...[
                              const SizedBox(height: 16),
                              Text(_error!, style: AppText.style(size: 13, weight: FontWeight.w800, color: AppColors.yellowNeon, height: 1.3)),
                            ],
                            const SizedBox(height: 16),
                            Center(
                              child: GestureDetector(
                                onTap: _submitting ? null : _toggleMode,
                                child: Text(
                                  _isRegister ? 'Já tem conta? Entrar' : 'Não tem conta? Criar',
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
                              onTap: _submitting ? null : _submitGoogle,
                              padding: const EdgeInsets.symmetric(vertical: 18),
                              child: Center(
                                child: Text('Continuar com Google', style: AppText.style(size: 16, weight: FontWeight.w900, color: AppColors.white)),
                              ),
                            ),
                            if (widget.mandatory) ...[
                              const SizedBox(height: 24),
                              Center(
                                child: GestureDetector(
                                  onTap: _submitting ? null : widget.onDone,
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
                      label: _isRegister ? 'Criar conta' : 'Entrar',
                      height: 64,
                      fontSize: 20,
                      enabled: _canSubmitEmail,
                      onTap: _submitEmail,
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
