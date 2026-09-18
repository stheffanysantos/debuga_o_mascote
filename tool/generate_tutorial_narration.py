#!/usr/bin/env python3
"""Gera a narração (MP3) de cada slide do tutorial (`TutorialScreen`,
`lib/screens/tutorial_screen.dart`) usando `edge-tts` (voz neural
"pt-BR-FranciscaNeural", o mesmo motor de TTS neural do Microsoft Edge/
Windows 11) — bem mais natural que a voz "Microsoft Maria Desktop" (SAPI)
usada antes, e mais confiável que a via OneCore/WinRT (essa foi tentada
primeiro nesta sessão, ver `.claude/memory/decisions.md`: a ativação COM da
voz OneCore se mostrou instável — funcionava isolada mas falhava de forma
intermitente dentro do laço completo — então caiu para este script Python,
mesmo espírito de `tool/generate_sfx.py`).

Saída em `.mp3` (não `.wav` como antes) — é o formato nativo do serviço, e
`audioplayers`/`AppSounds.playNarration` tocam `.mp3` normalmente, sem
nenhuma mudança de player. Precisa de internet só na hora de gerar os
arquivos (não em runtime do app — os `.mp3` continuam sendo assets
estáticos versionados, como os `.wav` eram antes).

IMPORTANTE: o texto de cada slide aqui precisa bater exatamente com
`lib/widgets/tutorial_content.dart` — se o texto de um slide mudar lá,
regerar a narração dele aqui (rodar o script de novo é sempre seguro,
sobrescreve os arquivos existentes).

Uso: python tool/generate_tutorial_narration.py
"""

import asyncio
import os

import edge_tts

VOICE = "pt-BR-FranciscaNeural"
OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "audio", "tutorial")

# Chave => texto falado (mesma ordem/índice dos slides em tutorial_content.dart).
SLIDES = {
    "intro_0": "O que é programar? Programar é dar instruções, uma de cada vez, pra alguém seguir certinho.",
    "intro_1": "Cada instrução é um Bloco, tipo uma peça de encaixe.",
    "intro_2": "Você junta os Blocos em ordem pra montar um Programa.",
    "intro_3": "Quem executa o Programa só faz exatamente o que você mandou. A ordem importa!",
    "intro_4": "Errou? Sem problema. Ajuste o Programa e tente de novo.",
    "world1_0": "Como jogar: Labirinto. Vamos aprender rapidinho:",
    "world1_1": "Monte um Programa tocando os blocos: Andar, Virar esquerda ou direita, Repetir 3 vezes.",
    "world1_2": "Aperte Play para ver o Mascote seguir seus comandos, passo a passo.",
    "world1_3": "Chegue exatamente no alvo para vencer a fase.",
    "world2_0": "Como jogar: Esteira de Bugs. Vamos aprender rapidinho:",
    "world2_1": "Os itens chegam um de cada vez. Monte blocos Se cor, vai pra Caixa, para classificar certo.",
    "world2_2": "Repetir 3 vezes repete um número fixo de vezes; Enquanto cor repete até a cor mudar.",
    "world2_3": "Classifique toda a fila certinho para vencer. Errar a cor é falha.",
    "world3_0": "Como jogar: Oficina de Blocos. Vamos aprender rapidinho:",
    "world3_1": "Cada fase dá uma lista de números e um probleminha, como somar todos os números.",
    "world3_2": "Monte blocos Some ao Total ou Conte mais 1. Para cada número aplica o bloco seguinte pra lista inteira de uma vez.",
    "world3_3": "Aperte Play e veja se o Total ou Contador final bate com o que a fase pede.",
    "world4_0": "Como jogar: Decisões em Bloco. Vamos aprender rapidinho:",
    "world4_1": "Agora os blocos têm condição: Se for par, some ao Total, e Se for ímpar, conte mais 1.",
    "world4_2": "Um número que não bate com a condição só é ignorado. Nunca é uma falha.",
    "world4_3": "Combine com Para cada número pra resolver a lista inteira em poucos blocos.",
    "world5_0": "Como jogar: Preveja a Saída. Vamos aprender rapidinho:",
    "world5_1": "Você vai ler um trecho de código de verdade, já pronto, sem montar nada.",
    "world5_2": "Depois de ler, escolha entre as opções qual é o resultado.",
    "world5_3": "Confirme sua resposta. Aqui não existe quase certo, só certo ou errado.",
    "world6_0": "Como jogar: Complete o Código. Vamos aprender rapidinho:",
    "world6_1": "O código tem um espaço em branco no lugar de uma linha.",
    "world6_2": "Toque na linha, entre as opções, que completa certo o espaço em branco.",
    "world6_3": "Confirme sua resposta. Aqui não existe quase certo, só certo ou errado.",
    "world7_0": "Como jogar: Modo Debug. Vamos aprender rapidinho:",
    "world7_1": "Em Reordenar, toque nas linhas de código na ordem certa.",
    "world7_2": "Em Achar o Bug, toque na linha que tem o erro.",
    "world7_3": "Confirme sua resposta. Aqui não existe quase certo, só certo ou errado.",
    "recap1_0": "Mundo 1 completo! Você aprendeu Sequência, Repetir e Virar. Agora vem a Decisão: no próximo mundo, o Mascote aprende a escolher!",
    "recap2_0": "Trilha 1 completa! Você aprendeu Se e Enquanto, decisão e repetição condicional. Agora vem a Trilha Construtores de Lógica: montar programas de blocos que resolvem contas de verdade!",
    "recap3_0": "Mundo 3 completo! Você já monta programas de blocos que somam e contam listas de números. Agora os blocos ganham condição: só valem quando o número bate com uma regra!",
    "recap4_0": "Trilha 2 completa! Você já pensa em blocos com condição. Agora vem a Trilha Modo Programador: lá você vai ler, completar e depurar código de verdade!",
    "recap5_0": "Mundo 5 completo! Você já lê código de verdade e prevê o resultado. Agora vem completar um espaço em branco num código real!",
    "recap6_0": "Mundo 6 completo! Você já sabe completar código de verdade. Agora vem o Modo Debug: juntar tudo, reordenar e achar bugs em código real!",
    "recap7_0": "Você terminou os sete mundos! Sequência, decisão, repetição, programação em blocos, leitura, escrita e depuração de código. Você já pensa como um programador!",
}


async def _generate_all():
    os.makedirs(OUT_DIR, exist_ok=True)
    for key, text in SLIDES.items():
        path = os.path.join(OUT_DIR, f"{key}.mp3")
        communicate = edge_tts.Communicate(text, VOICE)
        await communicate.save(path)
        print(f"Gerado: {path}")
    print(f"Pronto — {len(SLIDES)} arquivos de narração em {OUT_DIR}")


if __name__ == "__main__":
    asyncio.run(_generate_all())
