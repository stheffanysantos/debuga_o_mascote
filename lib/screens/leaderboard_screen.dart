import 'package:flutter/material.dart';

import '../data/app_auth.dart';
import '../data/leaderboard.dart';
import '../models/leaderboard_entry.dart';
import '../models/progress.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../theme/app_shadows.dart';
import '../theme/app_text.dart';
import '../widgets/bobbing_widget.dart';
import '../widgets/dotted_background_widget.dart';
import '../widgets/hard_shadow_box_widget.dart';
import '../widgets/icon_action_button_widget.dart';
import '../widgets/primary_pill_button_widget.dart';
import 'register_screen.dart';
import 'survey_screen.dart';

/// Placar do Dia — ranking de hoje (Nome + Pontos, sem idade/resposta da
/// pesquisa, ver `.claude/memory/decisions.md`). Aberta pelo ícone de
/// troféu na Seleção de Mundo. Ver quem já jogou é sempre público; aparecer
/// nele exige conta (`AppAuth.instance.hasAccount` — o nome vem da conta,
/// não é mais digitado) e a `SurveyScreen` (idade/já programou),
/// `Progress.sessionScore > 0` e ainda não enviado nesta sessão.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  late final Future<List<LeaderboardEntry>> _entriesFuture = Leaderboard.instance.topToday();

  @override
  Widget build(BuildContext context) {
    final showJoinCard = Progress.instance.sessionScore > 0 && !Progress.instance.hasSubmittedToLeaderboard;

    return Scaffold(
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
                  IconActionButton(
                    background: AppColors.grayButton,
                    shadowColor: Colors.transparent,
                    icon: AppIcons.chevronLeft(size: 22, color: AppColors.white),
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(height: 22),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Selo decorativo (não interativo) dando um ponto de
                      // cor/ícone de apoio ao eyebrow+título — mesmo padrão
                      // já aplicado em `WorldSelectScreen` (troféu combina
                      // com o tema desta tela). `purple`/`purpleShadow`, não
                      // `yellowNeon` — reservado pra destaque de ação/1º
                      // lugar mais abaixo, ver `.claude/memory/decisions.md`.
                      HardShadowBox(
                        color: AppColors.purple,
                        shadows: AppShadows.hard(AppColors.purpleShadow, dy: 6),
                        borderRadius: BorderRadius.circular(999),
                        child: SizedBox(
                          width: 48,
                          height: 48,
                          child: Center(child: AppIcons.trophy(size: 22, color: AppColors.white)),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('DEBUGA O MASCOTE', maxLines: 1, overflow: TextOverflow.ellipsis, style: AppText.eyebrow(size: 13)),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              alignment: Alignment.centerLeft,
                              child: Text('Placar do Dia', style: AppText.style(size: 32, weight: FontWeight.w900, color: AppColors.white, height: 1.05)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  if (showJoinCard) ...[
                    _JoinCard(score: Progress.instance.sessionScore),
                    const SizedBox(height: 16),
                  ],
                  Expanded(
                    child: FutureBuilder<List<LeaderboardEntry>>(
                      future: _entriesFuture,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState != ConnectionState.done) {
                          return const Center(child: CircularProgressIndicator(color: AppColors.yellowNeon));
                        }
                        final entries = snapshot.data ?? const [];
                        if (entries.isEmpty) {
                          return const _EmptyLeaderboard();
                        }
                        return ListView.separated(
                          itemCount: entries.length,
                          separatorBuilder: (context, index) => const SizedBox(height: 10),
                          itemBuilder: (context, index) => _RankRow(rank: index + 1, entry: entries[index]),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Estado vazio ("ninguém jogou ainda hoje") — a abelha chibi
/// (`assets/images/leaderboard_bee.png`, mesmo espírito de arte do Mascote
/// e dos ícones de Mundo) flutuando (`Bobbing`, já usado no Mascote da
/// Splash/Vitória) torna o momento mais vazio da tela mais convidativo,
/// em vez de só texto centralizado. Reservada só para este estado — ver
/// `.claude/memory/decisions.md`.
class _EmptyLeaderboard extends StatelessWidget {
  const _EmptyLeaderboard();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Bobbing(
              duration: const Duration(milliseconds: 2600),
              amplitude: 8,
              child: Image.asset('assets/images/leaderboard_bee.png', width: 140, height: 140, fit: BoxFit.contain),
            ),
            const SizedBox(height: 16),
            Text(
              'Ninguém no Placar ainda hoje.\nSeja o primeiro!',
              textAlign: TextAlign.center,
              style: AppText.style(size: 16, weight: FontWeight.w800, color: AppColors.white.withValues(alpha: 0.75), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _JoinCard extends StatelessWidget {
  final int score;

  const _JoinCard({required this.score});

  /// Aparecer no Placar exige conta — o nome vem dela, não é mais digitado
  /// (pedido explícito do usuário, ver `.claude/memory/decisions.md`). Sem
  /// conta, pede login antes (voluntário, `RegisterScreen(mandatory: false)`)
  /// e só então abre a Pesquisa.
  void _open(BuildContext context) {
    if (AppAuth.instance.hasAccount) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SurveyScreen()));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RegisterScreen(
        mandatory: false,
        onDone: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SurveyScreen()));
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final hasAccount = AppAuth.instance.hasAccount;
    return HardShadowBox(
      color: AppColors.purpleDark,
      shadows: AppShadows.hard(AppColors.purpleShadow, dy: 6),
      borderRadius: BorderRadius.circular(20),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Selinho de estrela — ecoa a cor/uso de `yellowNeon` já dado
              // à pontuação logo ao lado (destaque real de resultado, não
              // decoração solta).
              Container(
                padding: const EdgeInsets.all(7),
                decoration: const BoxDecoration(color: AppColors.yellowNeon, shape: BoxShape.circle),
                child: AppIcons.star(size: 14, color: AppColors.purpleDark),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text('Você fez $score pontos!', style: AppText.style(size: 16, weight: FontWeight.w900, color: AppColors.yellowNeon)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            hasAccount ? 'Quer aparecer no Placar? Responda 2 perguntinhas.' : 'Entre com sua conta pra aparecer no Placar com seu nome.',
            style: AppText.style(size: 13, weight: FontWeight.w800, color: AppColors.white.withValues(alpha: 0.85)),
          ),
          const SizedBox(height: 12),
          PrimaryPillButton(
            label: hasAccount ? 'Aparecer no Placar' : 'Entrar e aparecer no Placar',
            height: 48,
            fontSize: 15,
            onTap: () => _open(context),
          ),
        ],
      ),
    );
  }
}

class _RankRow extends StatelessWidget {
  final int rank;
  final LeaderboardEntry entry;

  const _RankRow({required this.rank, required this.entry});

  /// Cor do selo numerado do topo 3 do ranking — paleta já existente, sem
  /// token novo. `yellowNeon` só no 1º lugar: é o único "resultado de
  /// destaque" real desta lista (mesmo espírito de já reservar `yellowNeon`
  /// pra pontuação/botão de ação nesta tela, em vez de usá-lo em elemento
  /// puramente decorativo — ver `.claude/memory/decisions.md`).
  Color get _badgeColor {
    switch (rank) {
      case 1:
        return AppColors.yellowNeon;
      case 2:
        return AppColors.lilac;
      case 3:
        return AppColors.purple;
      default:
        return AppColors.grayButton;
    }
  }

  Color get _badgeTextColor {
    switch (rank) {
      case 1:
      case 2:
        return AppColors.purpleDark;
      case 3:
        return AppColors.white;
      default:
        // Achado do UX Reviewer: `lilac` sobre `grayButton` dava ≈3.44:1,
        // abaixo do mínimo AA (4.5:1, `.claude/rules/design.md`). `white`
        // sobe pra ≈8.9:1.
        return AppColors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return HardShadowBox(
      color: AppColors.panel,
      shadows: AppShadows.hard(AppColors.black, dy: 4),
      borderRadius: BorderRadius.circular(14),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: _badgeColor, shape: BoxShape.circle),
            child: Text('$rank', style: AppText.style(size: 15, weight: FontWeight.w900, color: _badgeTextColor)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppText.style(size: 16, weight: FontWeight.w800, color: AppColors.white),
            ),
          ),
          Text('${entry.score}', style: AppText.style(size: 16, weight: FontWeight.w900, color: AppColors.yellowNeon)),
        ],
      ),
    );
  }
}
