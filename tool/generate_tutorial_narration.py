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
    "world3_0": "Como jogar: Modo Debug. Vamos aprender rapidinho:",
    "world3_1": "Em Reordenar, toque nas linhas de código na ordem certa.",
    "world3_2": "Em Achar o Bug, toque na linha que tem o erro.",
    "world3_3": "Confirme sua resposta. Aqui não existe quase certo, só certo ou errado.",
    "recap1_0": "Mundo 1 completo! Você aprendeu Sequência, Repetir e Virar. Agora vem a Decisão: no próximo mundo, o Mascote aprende a escolher!",
    "recap2_0": "Mundo 2 completo! Você aprendeu Se e Enquanto, decisão e repetição condicional. Agora vem o mais parecido com programar de verdade: ler e consertar código!",
    "recap3_0": "Você terminou os três mundos! Sequência, decisão, repetição e leitura de código. Você já pensa como um programador!",
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
