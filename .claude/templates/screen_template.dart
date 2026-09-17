// Esqueleto de View trivial (sem ViewModel — ver .claude/rules/architecture.md,
// "Quando dar ViewModel a uma tela"). Para uma tela com orquestração real,
// crie também <nome>_state.dart (@freezed) e <nome>_view_model.dart (@riverpod)
// e leia o estado aqui via ref.watch(exampleViewModelProvider).
// Ver .claude/rules/design.md (zero hardcode de cor/tipografia).

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExampleView extends ConsumerWidget {
  const ExampleView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Text(
            'Substituir pelo conteúdo real da tela',
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
      ),
    );
  }
}
