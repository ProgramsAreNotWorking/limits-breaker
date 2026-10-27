#!/usr/bin/env python3
"""Revisa formato, loudness básica y costuras de loops WAV del manifiesto."""

from __future__ import annotations

import json
import math
import struct
import sys
import wave
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
MANIFEST_PATH = ROOT / "assets" / "audio" / "audio_manifest.json"
MAX_PEAK = 31_000
MAX_LOOP_SEAM_DELTA = 700
MIN_RMS = 150


def main() -> int:
    manifest = json.loads(MANIFEST_PATH.read_text(encoding="utf-8"))
    sample_rate = int(manifest["sample_rate_hz"])
    channels = int(manifest["channels"])
    failures: list[str] = []
    checked = 0

    for group in ("music", "sfx"):
        for asset_id, entry in manifest[group].items():
            checked += 1
            path = ROOT / "assets" / "audio" / entry["file"]
            try:
                with wave.open(str(path), "rb") as source:
                    frames = source.getnframes()
                    rate = source.getframerate()
                    channel_count = source.getnchannels()
                    width = source.getsampwidth()
                    raw = source.readframes(frames)
            except (OSError, wave.Error) as error:
                failures.append(f"{asset_id}: no se pudo leer {path.name}: {error}")
                continue

            if rate != sample_rate or channel_count != channels or width != 2:
                failures.append(f"{asset_id}: formato inesperado ({rate} Hz, {channel_count} ch, {width * 8} bit)")
            expected_frames = int(entry.get("sample_count", round(float(entry["duration_seconds"]) * rate)))
            if frames != expected_frames:
                failures.append(f"{asset_id}: muestras no coinciden con el manifiesto ({frames} != {expected_frames})")
            duration_delta = abs(frames / max(1, rate) - float(entry["duration_seconds"]))
            if duration_delta > 0.0011:
                failures.append(f"{asset_id}: duración no coincide con el manifiesto ({duration_delta:.4f} s)")
            samples = [sample[0] for sample in struct.iter_unpack("<h", raw)]
            peak = max((abs(sample) for sample in samples), default=0)
            rms = math.sqrt(sum(sample * sample for sample in samples) / max(1, len(samples)))
            if peak >= MAX_PEAK:
                failures.append(f"{asset_id}: pico excesivo ({peak})")
            if rms < MIN_RMS:
                failures.append(f"{asset_id}: señal casi silenciosa (RMS {rms:.0f})")
            seam = abs(samples[0] - samples[-1]) if samples else 0
            if bool(entry.get("loop", False)) and seam > MAX_LOOP_SEAM_DELTA:
                failures.append(f"{asset_id}: costura de loop alta ({seam} muestras)")
            print(
                f"PASS {asset_id}: {frames / rate:.2f} s, peak={peak}/32767, "
                f"RMS={rms:.0f}, seam={seam}"
            )

    if failures:
        for failure in failures:
            print("FAIL " + failure, file=sys.stderr)
        return 1
    print(f"PASS: {checked} WAV; {sample_rate} Hz, {channels} canal(es), PCM 16-bit.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
