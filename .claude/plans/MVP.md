# MVP — Debuga o Mascote

## Objetivo do MVP
Um mini-jogo educativo funcional e polido o suficiente para rodar sem supervisão constante num estande de feira, ensinando lógica de programação básica (sequência, direção, repetição) através do Mascote.

## Escopo do MVP (entra)
1. **Splash/Menu** com logo, mascote animado e botão Jogar.
2. **Seleção de Fases** com pelo menos 1 mundo (12 fases), estrelas e bloqueio de fases não alcançadas.
3. **Gameplay**: tabuleiro 6×6, os 4 comandos (Andar, Virar Esquerda, Virar Direita, Repetir 3×), máx. 8 blocos, execução passo a passo animada.
4. **Vitória**: confete, estrelas, pontuação, botões Repetir/Próxima fase.
5. **Tentativa Falha**: motivo da falha, card de Dica, botões Menu/Tentar de novo.
6. Motor de jogo (`lib/game/`) testado (unit tests) para as regras de colisão/vitória/estrelas.

## Fora do escopo do MVP (registrar se entrar depois)
- Layout dedicado para tablet (tabuleiro à esquerda, blocos à direita) — ver `Roadmap.md`.
- Sons e haptics.
- Mundos além do primeiro / comandos novos além dos 4 atuais.
- Persistência de progresso além de rodar a sessão do estande (decisão de storage ainda pendente — ver `.claude/memory/decisions.md`).

## Critério de "MVP pronto"
Um visitante do estande consegue, sem instrução prévia além do que está na tela: abrir o app, escolher uma fase, montar um programa de blocos, executar, ver o resultado (vitória com celebração ou falha com dica clara) e avançar para a próxima fase — tudo em poucos toques, com o motor de jogo coberto por testes.
