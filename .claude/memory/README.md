# Memória Persistente — como funciona

O Claude Code não tem um banco de memória de longo prazo nativo entre sessões. O que simula "memória persistente" neste projeto é:

1. **`CLAUDE.md` (raiz) é carregado automaticamente em toda sessão** iniciada neste repositório.
2. **Imports com `@caminho/arquivo`** dentro de `CLAUDE.md` são resolvidos e injetados automaticamente no início da sessão — ver a seção final de `CLAUDE.md`.
3. Os demais arquivos desta pasta **não** são importados automaticamente: continuam existindo como memória "sob demanda" — qualquer agente deve lê-los quando a tarefa exigir (ex.: o UI Engineer sempre lê `design-system.md` antes de criar um componente).

## Arquivos desta pasta

| Arquivo | Carregado automaticamente? | Conteúdo |
|---|---|---|
| `decisions.md` | Sim (import automático) | Log de decisões (ADR curto) — cresce ao longo do projeto |
| `domain-glossary.md` | Sim (import automático) | Glossário do jogo (Bloco, Fase, Mundo, Estrelas...) |
| `design-system.md` | Não — sob demanda | Paleta, tipografia, inventário de componentes |
| `tech-stack.md` | Não — sob demanda | Stack fixada e por que cada peça foi escolhida |

## Regra de manutenção

- **`decisions.md`**: toda decisão relevante (trocar uma lib, mudar um padrão) é registrada aqui **antes** de implementar.
- **`domain-glossary.md`**: todo termo de jogo novo é adicionado no momento em que a mecânica é criada.
- **`design-system.md`**: atualizado sempre que um componente novo entra no inventário compartilhado (`lib/widgets/`).
