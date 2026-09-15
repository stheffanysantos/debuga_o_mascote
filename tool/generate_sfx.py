#!/usr/bin/env python3
"""Gera os efeitos sonoros placeholder do jogo por síntese (sem baixar nada
de terceiros — ver `.claude/memory/decisions.md`). Rodar de novo sempre que
quiser ajustar tom/duração; a saída vai para `assets/audio/`.

Uso: python tool/generate_sfx.py
"""

import math
import os
import struct
import wave

SAMPLE_RATE = 44100
OUT_DIR = os.path.join(os.path.dirname(__file__), "..", "assets", "audio")


def _note(freq, duration_s, volume=0.5, fade_in=0.08, fade_out=0.35):
    """Uma nota senoidal com envelope simples (ataque rápido, decaimento
    exponencial) — evita cliques no início/fim e soa "macio", não um bipe cru.
    """
    n = int(SAMPLE_RATE * duration_s)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        progress = i / n
        envelope = min(1.0, progress / fade_in) if fade_in > 0 else 1.0
        envelope *= math.exp(-fade_out * progress * 3)  # decaimento exponencial suave
        samples.append(math.sin(2 * math.pi * freq * t) * volume * envelope)
    return samples


def _sweep(freq_start, freq_end, duration_s, volume=0.45):
    """Nota com frequência variando linearmente — usada no som de Play."""
    n = int(SAMPLE_RATE * duration_s)
    samples = []
    phase = 0.0
    for i in range(n):
        progress = i / n
        freq = freq_start + (freq_end - freq_start) * progress
        phase += 2 * math.pi * freq / SAMPLE_RATE
        envelope = math.sin(math.pi * progress)  # sobe e desce suave
        samples.append(math.sin(phase) * volume * envelope)
    return samples


def _silence(duration_s):
    return [0.0] * int(SAMPLE_RATE * duration_s)


def _write_wav(name, samples):
    os.makedirs(OUT_DIR, exist_ok=True)
    path = os.path.join(OUT_DIR, name)
    with wave.open(path, "w") as f:
        f.setnchannels(1)
        f.setsampwidth(2)
        f.setframerate(SAMPLE_RATE)
        frames = b"".join(
            struct.pack("<h", max(-32767, min(32767, int(s * 32767))))
            for s in samples
        )
        f.writeframes(frames)
    print(f"gerado {path} ({len(samples) / SAMPLE_RATE:.3f}s)")


def main():
    # Andar — blip curto e suave.
    _write_wav("walk.wav", _note(220, 0.09, volume=0.4, fade_in=0.1, fade_out=0.6))

    # Virar — clique curto, mais agudo que o de andar.
    _write_wav("turn.wav", _note(440, 0.06, volume=0.35, fade_in=0.1, fade_out=0.8))

    # Play — pequeno sweep ascendente, sinaliza "começou a rodar".
    _write_wav("play.wav", _sweep(300, 640, 0.16, volume=0.45))

    # Vitória — arpejo ascendente (dó-mi-sol), celebração forte.
    victory = (
        _note(523.25, 0.16, volume=0.5, fade_in=0.05, fade_out=0.35)
        + _note(659.25, 0.16, volume=0.5, fade_in=0.05, fade_out=0.35)
        + _note(783.99, 0.32, volume=0.55, fade_in=0.05, fade_out=0.25)
    )
    _write_wav("victory.wav", victory)

    # Falha — descida curta e suave de 2 notas, deliberadamente não-punitiva
    # (sem buzzer agressivo — falha nunca é punitiva, ver CLAUDE.md).
    failure = (
        _note(440, 0.16, volume=0.35, fade_in=0.05, fade_out=0.35)
        + _note(349.23, 0.2, volume=0.32, fade_in=0.05, fade_out=0.3)
    )
    _write_wav("failure.wav", failure)


if __name__ == "__main__":
    main()
