import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/auth/auth_providers.dart';
import '../../../core/progress/progress_notifier.dart';
import '../../../models/leaderboard_entry.dart';
import '../../../theme/app_colors.dart';
import '../../../theme/app_icons.dart';
import '../../../theme/app_shadows.dart';
import '../../../theme/app_text.dart';
import '../../../widgets/bobbing_widget.dart';
import '../../../widgets/character_avatar_widget.dart';
import '../../../widgets/dotted_background_widget.dart';
import '../../../widgets/hard_shadow_box_widget.dart';
import '../../../widgets/icon_action_button_widget.dart';
import '../../../widgets/primary_pill_button_widget.dart';
import '../../auth/presentation/register/register_view.dart';
import '../../survey/presentation/survey_view.dart';
import 'leaderboard_view_model.dart';

/// Placar Geral — ranking sem recorte de dia (Nome + Pontos, sem
/// idade/resposta da pesquisa, ver `.claude/memory/decisions.md`). Aberta
/// pelo ícone de troféu na Seleção de Mundo. Ver quem já jogou é sempre
/// público; aparecer nele exige conta (`authServiceProvider` — o nome vem
/// da conta, não é mais digitado) e a `SurveyView` (idade/já programou),
/// `Progress.sessionScore > 0` e ainda não enviado. Depois de zerar o jogo
/// (100% das 2 Trilhas), o jogador sai desta lista e passa a aparecer só na
/// aba "Zeraram o Jogo" — pontuação não é mais atualizável manualmente
/// depois disso, `LeaderboardSyncService` reflete o estado atual sozinho a
/// cada vitória.
///
/// `ConsumerStatefulWidget` só pelo `_selectedTab` local (qual das 2 listas
/// está sendo mostrada) — estado puramente de apresentação, não precisa de
/// ViewModel (ver `.claude/rules/architecture.md`, "Quando dar ViewModel a
/// uma tela").
class LeaderboardView extends ConsumerStatefulWidget {
  const LeaderboardView({super.key});

  @override
  ConsumerState<LeaderboardView> createState() => _LeaderboardViewState();
}

class _LeaderboardViewState extends ConsumerState<LeaderboardView> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressNotifierProvider);
    final showJoinCard = progress.sessionScore > 0 && !progress.hasSubmittedToLeaderboard;
    final dataAsync = ref.watch(leaderboardViewModelProvider);

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
                      // já aplicado em `WorldSelectView` (troféu combina
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
                              child: Text('Placar Geral', style: AppText.style(size: 32, weight: FontWeight.w900, color: AppColors.white, height: 1.05)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _TabButton(label: 'Geral', selected: _selectedTab == 0, onTap: () => setState(() => _selectedTab = 0))),
                      const SizedBox(width: 10),
                      Expanded(child: _TabButton(label: 'Zeraram o Jogo', selected: _selectedTab == 1, onTap: () => setState(() => _selectedTab = 1))),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (showJoinCard) ...[
                    _JoinCard(score: progress.sessionScore),
                    const SizedBox(height: 16),
                  ],
                  Expanded(
                    child: dataAsync.when(
                      loading: () => const Center(child: CircularProgressIndicator(color: AppColors.yellowNeon)),
                      // `LeaderboardRepository` já engole erro internamente
                      // (ver `.claude/memory/decisions.md`) — chegar aqui é
                      // inesperado, mas o estado vazio é a resposta certa em
                      // vez de quebrar a tela.
                      error: (error, stackTrace) => _EmptyLeaderboard(completedTab: _selectedTab == 1),
                      data: (data) {
                        final entries = _selectedTab == 0 ? data.overall : data.completedGame;
                        if (entries.isEmpty) {
                          return _EmptyLeaderboard(completedTab: _selectedTab == 1);
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

/// Alterna entre as abas "Geral"/"Zeraram o Jogo" — mesmo padrão visual de
/// `_YesNoOption` (`survey_view.dart`): preenchido em `yellowNeon` quando
/// selecionado, contorno neutro quando não.
class _TabButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _TabButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.yellowNeon : AppColors.panel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: selected ? AppColors.yellowNeon : AppColors.grayButton, width: 2),
        ),
        child: Text(
          label,
          style: AppText.style(size: 14, weight: FontWeight.w900, color: selected ? AppColors.purpleDark : AppColors.white),
        ),
      ),
    );
  }
}

/// Estado vazio — a abelha chibi (`assets/images/leaderboard_bee.png`,
/// mesmo espírito de arte do Mascote e dos ícones de Mundo) flutuando
/// (`Bobbing`, já usado no Mascote da Splash/Vitória) torna o momento mais
/// vazio da tela mais convidativo, em vez de só texto centralizado.
/// Reservada só para este estado — ver `.claude/memory/decisions.md`.
class _EmptyLeaderboard extends StatelessWidget {
  final bool completedTab;

  const _EmptyLeaderboard({required this.completedTab});

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
              completedTab ? 'Ninguém zerou o jogo ainda.\nSeja o primeiro!' : 'Ninguém no Placar ainda.\nSeja o primeiro!',
              textAlign: TextAlign.center,
              style: AppText.style(size: 16, weight: FontWeight.w800, color: AppColors.white.withValues(alpha: 0.75), height: 1.4),
            ),
          ],
        ),
      ),
    );
  }
}

class _JoinCard extends ConsumerWidget {
  final int score;

  const _JoinCard({required this.score});

  /// Aparecer no Placar exige conta — o nome vem dela, não é mais digitado
  /// (pedido explícito do usuário, ver `.claude/memory/decisions.md`). Sem
  /// conta, pede login antes (voluntário, `RegisterView(mandatory: false)`)
  /// e só então abre a Pesquisa.
  void _open(BuildContext context, WidgetRef ref) {
    if (ref.read(authServiceProvider).hasAccount) {
      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SurveyView()));
      return;
    }
    Navigator.of(context).push(MaterialPageRoute(
      builder: (_) => RegisterView(
        mandatory: false,
        onDone: () {
          Navigator.of(context).pop();
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => const SurveyView()));
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasAccount = ref.watch(authServiceProvider).hasAccount;
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
            onTap: () => _open(context, ref),
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
          const SizedBox(width: 10),
          CharacterAvatarCircle(avatarId: entry.avatarId, size: 34, ringColor: AppColors.grayButton, ringWidth: 2),
          const SizedBox(width: 10),
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
