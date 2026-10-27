class_name Synth
extends RefCounted
## Síntesis de audio determinista. Genera música loopable y SFX como
## AudioStreamWAV reales, sin archivos externos ni dependencias.

const RATE := 22050
const MELODY_ACCENTS := [1.0, 0.78, 0.9, 0.72]


static func _wav(samples: PackedFloat32Array) -> AudioStreamWAV:
	var n := samples.size()
	var data := PackedByteArray()
	data.resize(n * 2)
	for i in range(n):
		var v: float = clampf(samples[i], -1.0, 1.0)
		data.encode_s16(i * 2, int(v * 32000.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = RATE
	w.stereo = false
	w.data = data
	w.loop_mode = AudioStreamWAV.LOOP_DISABLED
	return w


static func midi(m: int) -> float:
	return 440.0 * pow(2.0, float(m - 69) / 12.0)


static func _mix(dst: PackedFloat32Array, src: PackedFloat32Array, offset: int, gain: float = 1.0) -> void:
	var n := dst.size()
	for i in range(src.size()):
		dst[(offset + i) % n] += src[i] * gain


static func _pluck(freq: float, dur: float, amp: float, decay: float = 0.997) -> PackedFloat32Array:
	var total := maxi(1, int(dur * RATE))
	var n := maxi(2, int(RATE / maxf(20.0, freq)))
	var out := PackedFloat32Array()
	out.resize(total)
	var buf := PackedFloat32Array()
	buf.resize(n)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(freq * 131.0) + 7
	for i in range(n):
		buf[i] = rng.randf_range(-1.0, 1.0)
	var idx := 0
	for i in range(total):
		var cur: float = buf[idx]
		var nxt: float = buf[(idx + 1) % n]
		buf[idx] = (cur * 0.5 + nxt * 0.5) * decay
		out[i] = cur * amp
		idx = (idx + 1) % n
	return out


static func _pad(freqs: Array, dur: float, amp: float, style: String = "warm") -> PackedFloat32Array:
	var total := maxi(1, int(dur * RATE))
	var out := PackedFloat32Array()
	out.resize(total)
	var attack := int(0.22 * total)
	var release := int(0.3 * total)
	for i in range(total):
		var env := 1.0
		if i < attack:
			env = float(i) / float(maxi(1, attack))
		elif i > total - release:
			env = float(total - i) / float(maxi(1, release))
		var t := float(i) / RATE
		var v := 0.0
		for f in freqs:
			var fundamental := float(f)
			match style:
				"choir":
					v += sin(TAU * fundamental * t) * 0.42
					v += sin(TAU * fundamental * 1.004 * t) * 0.28
				"strings":
					v += sin(TAU * fundamental * t) * 0.4
					v += sin(TAU * fundamental * 1.002 * t) * 0.24
				"dark":
					v += sin(TAU * fundamental * 0.5 * t) * 0.28
					v += sin(TAU * fundamental * t) * 0.36
					v += sin(TAU * fundamental * 2.0 * t) * 0.11
				_:
					v += sin(TAU * fundamental * t) * 0.5
					v += sin(TAU * fundamental * 0.5 * t) * 0.15
		out[i] = v * amp * env
	return out


static func _kick(dur: float = 0.18, amp: float = 0.7) -> PackedFloat32Array:
	var total := int(dur * RATE)
	var out := PackedFloat32Array()
	out.resize(total)
	for i in range(total):
		var t := float(i) / RATE
		var f := lerpf(120.0, 42.0, minf(1.0, t / dur))
		var env := exp(-t * 22.0)
		out[i] = sin(TAU * f * t) * env * amp
	return out


static func _snare(dur: float = 0.12, amp: float = 0.35) -> PackedFloat32Array:
	var total := int(dur * RATE)
	var out := PackedFloat32Array()
	out.resize(total)
	var rng := RandomNumberGenerator.new()
	rng.seed = 99
	for i in range(total):
		var t := float(i) / RATE
		var env := exp(-t * 38.0)
		out[i] = (rng.randf_range(-1.0, 1.0) * 0.8 + sin(TAU * 190.0 * t) * 0.2) * env * amp
	return out


static func _hat(dur: float = 0.05, amp: float = 0.12) -> PackedFloat32Array:
	var total := int(dur * RATE)
	var out := PackedFloat32Array()
	out.resize(total)
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	var prev := 0.0
	for i in range(total):
		var t := float(i) / RATE
		var n := rng.randf_range(-1.0, 1.0)
		var hp := n - prev
		prev = n
		out[i] = hp * exp(-t * 90.0) * amp
	return out


static func _chime(freq: float, dur: float, amp: float) -> PackedFloat32Array:
	var total := int(dur * RATE)
	var out := PackedFloat32Array()
	out.resize(total)
	for i in range(total):
		var t := float(i) / RATE
		var env := exp(-t * 4.5)
		var v := sin(TAU * freq * t) + 0.45 * sin(TAU * freq * 2.01 * t) + 0.25 * sin(TAU * freq * 3.02 * t)
		out[i] = v * env * amp * 0.5
	return out


static func _lead_voice(freq: float, dur: float, amp: float, style: String) -> PackedFloat32Array:
	if style == "bell":
		return _chime(freq, dur, amp)
	var partials: Array = []
	var attack := 0.04
	var release := 0.12
	var decay := 0.0
	var vibrato := 0.0
	match style:
		"harp":
			partials = [[1.0, 1.0], [2.0, 0.34], [3.0, 0.12], [4.0, 0.04]]
			attack = 0.003
			release = 0.08
			decay = 3.2
		"brass":
			partials = [[1.0, 0.72], [2.0, 0.42], [3.0, 0.22], [4.0, 0.1], [5.0, 0.04]]
			attack = 0.045
			release = 0.13
			decay = 0.18
			vibrato = 0.001
		"strings":
			partials = [[1.0, 0.72], [1.003, 0.28], [2.0, 0.22], [3.0, 0.08]]
			attack = 0.11
			release = 0.2
			decay = 0.06
			vibrato = 0.0022
		"choir":
			partials = [[1.0, 0.58], [1.005, 0.42], [2.0, 0.17], [3.0, 0.055]]
			attack = 0.18
			release = 0.24
			decay = 0.045
			vibrato = 0.0015
		"hammered":
			partials = [[1.0, 0.65], [2.76, 0.23], [4.12, 0.1], [5.43, 0.04]]
			attack = 0.002
			release = 0.14
			decay = 3.8
		_:
			return _chime(freq, dur, amp)
	var total := maxi(1, int(dur * RATE))
	var out := PackedFloat32Array()
	out.resize(total)
	var weight_total := 0.0
	for partial in partials:
		weight_total += float(partial[1])
	for i in range(total):
		var t := float(i) / RATE
		var envelope := 1.0
		if t < attack:
			envelope = t / maxf(0.001, attack)
		if decay > 0.0:
			envelope *= exp(-t * decay)
		if t > dur - release:
			envelope *= clampf((dur - t) / maxf(0.001, release), 0.0, 1.0)
		var sample := 0.0
		for partial in partials:
			var partial_freq := freq * float(partial[0])
			var phase := TAU * partial_freq * t
			if vibrato > 0.0:
				phase += sin(TAU * 5.2 * t) * vibrato * partial_freq / 5.2
			sample += sin(phase) * float(partial[1])
		out[i] = sample * amp * envelope / maxf(0.001, weight_total)
	return out


# --------------------------------------------------------------- música

static func music(kind: String) -> AudioStreamWAV:
	var plan := _music_plan(kind)
	return _track(float(plan["bpm"]), int(plan["bars"]), plan["chords"], plan["cfg"])


static func music_info(kind: String) -> Dictionary:
	var plan := _music_plan(kind)
	var cfg: Dictionary = plan["cfg"]
	return {
		"bpm": float(plan["bpm"]),
		"bars": int(plan["bars"]),
		"form": String(plan["form"]),
		"tonal_center": String(plan["tonal_center"]),
		"sections": cfg["section_bars"],
		"lead_style": String(cfg.get("lead_style", "bell")),
		"pad_style": String(cfg.get("pad_style", "warm")),
		"counterline": bool(cfg.get("counterline", false)),
		"bass_pattern": cfg.get("bass_pattern", [0, 2]),
		"lead_echo_delay": float(cfg.get("lead_echo_delay", 0.0)),
	}


static func _music_plan(kind: String) -> Dictionary:
	var sections := [8, 8, 8, 8]
	var form := "A-B-A'-retransition"
	var tonal_center := "Re menor"
	var bpm := 72.0
	var chords: Array = [
		[50, 53, 57, 60], [46, 50, 53, 57], [41, 45, 48, 52], [48, 52, 55, 58],
		[43, 46, 50, 53], [46, 50, 53, 57], [41, 45, 48, 52], [45, 49, 52, 55],
		[50, 53, 57, 60], [41, 45, 48, 52], [46, 50, 53, 57], [48, 52, 55, 58],
		[43, 46, 50, 53], [45, 50, 53, 57], [45, 49, 52, 55], [45, 49, 52, 55],
	]
	var cfg := {
		"arp": 0.19, "bass": 0.22, "pad": 0.12, "drums": 0.0,
		"melody": true, "melody_amp": 0.13, "melody_gate": 1.25, "arp_div": 2,
		"lead_style": "harp", "pad_style": "warm", "bass_pattern": [0, 2, 1, 2],
		"lead_echo_delay": 0.24, "lead_echo_gain": 0.18,
		"section_bars": sections, "section_gains": [0.72, 0.96, 0.83, 0.65],
		"melody_patterns": [
			[0, -1, 1, 2, 3, -1, 2, -1], [1, -1, 2, 3, 2, 1, 0, -1],
			[0, -1, 2, 1, 3, -1, 2, 0], [0, 2, -1, 1, 2, -1, 3, -1],
		],
		"melody_answers": [
			[0, 2, -1, 1, 2, 3, -1, 1], [1, 2, 3, -1, 2, 1, 3, -1],
			[0, 1, -1, 2, 3, 1, 2, -1], [0, 1, 2, -1, 3, 2, 1, -1],
		],
		"counterline": true,
		"counterline_gain": 0.3,
		"counterline_patterns": [
			[-1, -1, 1, -1, -1, 2, -1, -1], [-1, 2, -1, 3, -1, 2, 1, -1],
			[-1, -1, 2, -1, -1, 3, -1, -1], [-1, 1, -1, -1, -1, 2, -1, -1],
		],
	}
	match kind:
		"menu":
			pass
		"combat":
			bpm = 96.0
			tonal_center = "Re menor"
			chords = [
				[50, 53, 57, 60], [50, 53, 57], [46, 50, 53, 56], [45, 49, 52, 55],
				[43, 46, 50, 53], [46, 50, 53, 57], [48, 51, 55, 58], [45, 49, 52, 55],
				[50, 53, 57, 60], [46, 50, 53, 57], [41, 45, 48, 52], [48, 51, 55, 58],
				[43, 46, 50, 53], [46, 50, 53, 57], [45, 49, 52, 55], [45, 49, 52, 55],
			]
			cfg = {
				"arp": 0.29, "bass": 0.32, "pad": 0.055, "drums": 0.58,
				"melody": true, "melody_amp": 0.12, "melody_gate": 0.88, "arp_div": 4,
				"lead_style": "brass", "pad_style": "strings", "bass_pattern": [0, 2, 0, 2],
				"section_bars": sections, "section_gains": [0.74, 1.0, 0.86, 0.7],
				"melody_patterns": [
					[0, 0, -1, 2, 0, 1, -1, 2], [0, 1, 2, -1, 1, 3, 2, 1],
					[0, -1, 2, 1, 3, 2, 1, -1], [0, 2, -1, 1, 2, -1, 3, -1],
				],
				"melody_answers": [
					[0, -1, 1, 2, 3, 2, 1, -1], [2, -1, 1, 3, 2, 1, 0, -1],
					[0, 1, -1, 2, 3, 1, 2, -1], [0, 1, 2, -1, 3, 2, 1, -1],
				],
				"counterline": true, "counterline_gain": 0.24,
				"counterline_patterns": [
					[-1, -1, -1, 2, -1, -1, 3, -1], [-1, 2, -1, 3, -1, 1, -1, 2],
					[-1, -1, 2, -1, -1, 3, -1, 2], [-1, 1, -1, 2, -1, 3, -1, -1],
				],
				"drum_fills": true,
			}
		"boss":
			bpm = 108.0
			sections = [8, 8, 8, 8]
			form = "A-B-A'-retransition"
			tonal_center = "La menor con cromatismo"
			chords = [
				[45, 48, 52, 55], [41, 45, 48, 52], [43, 46, 50, 53], [44, 47, 51, 54],
				[45, 48, 52, 55], [47, 50, 53, 57], [43, 46, 50, 53], [44, 47, 51, 54],
				[45, 48, 52, 55], [41, 45, 48, 52], [43, 46, 50, 53], [44, 47, 51, 54],
				[45, 48, 52, 55], [47, 50, 53, 57], [44, 47, 51, 54], [44, 47, 51, 54],
			]
			cfg = {
				"arp": 0.27, "bass": 0.37, "pad": 0.075, "drums": 0.72,
				"melody": true, "melody_amp": 0.105, "melody_gate": 0.78, "arp_div": 4, "dark": true,
				"lead_style": "brass", "pad_style": "dark", "bass_pattern": [0, 2, 1, 2],
				"section_bars": sections, "section_gains": [0.76, 1.0, 0.9, 0.72],
				"melody_patterns": [
					[0, -1, 2, 1, 3, -1, 2, 0], [0, 2, -1, 1, 3, 2, -1, 1],
					[0, -1, 1, 2, 3, 1, -1, 0], [0, 2, -1, 3, 2, -1, 1, -1],
				],
				"melody_answers": [
					[0, 1, -1, 2, 3, 2, -1, 1], [1, -1, 0, 2, 3, 1, 2, -1],
					[0, 2, -1, 1, 3, 2, 1, -1], [0, 1, 3, -1, 2, 1, 0, -1],
				],
				"counterline": true, "counterline_gain": 0.2,
				"counterline_patterns": [
					[-1, -1, 2, -1, -1, 1, -1, 3], [-1, 2, -1, 3, 1, -1, 2, -1],
					[-1, -1, 3, -1, 2, -1, 1, -1], [-1, 1, -1, 2, -1, 3, -1, -1],
				],
				"drum_fills": true,
			}
		"blacksmith":
			bpm = 88.0
			tonal_center = "Sol menor"
			chords = [
				[43, 46, 50, 53], [48, 52, 55, 59], [50, 54, 57, 60], [43, 46, 50, 53],
				[39, 43, 46, 50], [46, 50, 53, 57], [50, 54, 57, 60], [43, 46, 50, 53],
				[43, 46, 50, 53], [48, 52, 55, 59], [39, 43, 46, 50], [50, 54, 57, 60],
				[43, 46, 50, 53], [39, 43, 46, 50], [50, 54, 57, 60], [50, 54, 57, 60],
			]
			cfg = {
				"arp": 0.24, "bass": 0.25, "pad": 0.085, "drums": 0.38,
				"melody": true, "melody_amp": 0.105, "melody_gate": 1.0, "arp_div": 2, "hammer": true,
				"lead_style": "hammered", "pad_style": "warm", "bass_pattern": [0, 2, 2, 0],
				"section_bars": sections, "section_gains": [0.72, 1.0, 0.84, 0.7],
				"melody_patterns": [
					[0, 2, -1, 1, 3, -1, 2, 0], [0, -1, 1, 3, 2, 1, -1, 0],
					[0, 2, -1, 1, 3, 2, 1, -1], [0, -1, 2, 1, 3, -1, 1, -1],
				],
				"melody_answers": [
					[0, 1, 2, -1, 3, 2, 1, -1], [0, 1, -1, 2, 3, 1, -1, 0],
					[0, 1, -1, 2, 3, 1, 2, -1], [0, 2, -1, 1, 3, 2, 0, -1],
				],
				"counterline": true, "counterline_gain": 0.18,
				"counterline_patterns": [
					[-1, -1, 2, -1, -1, -1, 3, -1], [-1, 2, -1, 3, -1, 1, -1, -1],
					[-1, -1, 1, -1, -1, 3, -1, 2], [-1, -1, 2, -1, -1, 1, -1, -1],
				],
			}
		"angel":
			bpm = 64.0
			tonal_center = "La mayor"
			chords = [
				[45, 49, 52, 56], [50, 54, 57, 61], [42, 45, 49, 52], [52, 56, 59, 62],
				[47, 50, 54, 57], [50, 54, 57, 61], [45, 49, 52, 56], [52, 56, 59, 62],
				[45, 49, 52, 56], [42, 45, 49, 52], [50, 54, 57, 61], [52, 56, 59, 62],
				[47, 50, 54, 57], [50, 54, 57, 61], [52, 56, 59, 62], [52, 56, 59, 62],
			]
			cfg = {
				"arp": 0.17, "bass": 0.12, "pad": 0.15, "drums": 0.0,
				"melody": true, "melody_amp": 0.15, "melody_gate": 1.65, "arp_div": 1,
				"lead_style": "choir", "pad_style": "choir", "bass_pattern": [0, 2, 1, 2],
				"lead_echo_delay": 0.38, "lead_echo_gain": 0.13,
				"section_bars": sections, "section_gains": [0.72, 0.96, 0.82, 0.66],
				"melody_patterns": [
					[0, -1, -1, 2, 3, -1, 2, -1], [0, -1, 2, -1, 3, -1, 2, 1],
					[0, -1, 1, -1, 3, -1, 2, -1], [0, -1, 2, -1, 3, -1, 1, -1],
				],
				"melody_answers": [
					[0, 1, -1, 2, 3, -1, 1, -1], [0, 2, -1, 1, 3, 2, -1, 1],
					[0, 2, -1, 1, 3, -1, 2, 1], [0, 1, -1, 2, 3, -1, 2, -1],
				],
				"counterline": true, "counterline_gain": 0.2,
				"counterline_patterns": [
					[-1, -1, 2, -1, -1, 3, -1, -1], [-1, 2, -1, 3, -1, 2, 1, -1],
					[-1, -1, 1, -1, -1, 3, -1, 2], [-1, 1, -1, -1, -1, 2, -1, -1],
				],
			}
		"death":
			bpm = 58.0
			sections = [8, 8, 8, 4]
			form = "A-B-A'-coda"
			tonal_center = "Re menor"
			chords = [
				[50, 53, 57, 60], [46, 50, 53, 57], [43, 46, 50, 53], [45, 49, 52, 55],
				[50, 53, 57, 60], [41, 45, 48, 52], [48, 52, 55, 58], [45, 49, 52, 55],
				[50, 53, 57, 60], [46, 50, 53, 57], [43, 46, 50, 53], [45, 49, 52, 55],
				[43, 46, 50, 53], [46, 50, 53, 57],
			]
			cfg = {
				"arp": 0.13, "bass": 0.2, "pad": 0.17, "drums": 0.0,
				"melody": true, "melody_amp": 0.09, "melody_gate": 1.8, "arp_div": 1,
				"lead_style": "strings", "pad_style": "dark", "bass_pattern": [0, 2, 1, 2],
				"lead_echo_delay": 0.3, "lead_echo_gain": 0.12,
				"section_bars": sections, "section_gains": [0.78, 0.92, 0.76, 0.62],
				"melody_patterns": [
					[3, -1, 2, -1, 1, -1, 0, -1], [0, -1, 2, 1, 3, -1, 2, -1],
					[3, -1, 2, -1, 1, -1, 0, -1], [2, -1, 1, -1, 0, -1, 1, -1],
				],
				"melody_answers": [
					[3, 2, -1, 1, 0, -1, 1, -1], [0, 2, -1, 1, 3, 2, -1, 1],
					[3, -1, 1, 2, 1, -1, 0, -1], [2, 1, -1, 0, 1, -1, 0, -1],
				],
				"counterline": false,
			}
		_:
			bpm = 80.0
	var total_bars := 0
	for section_length in sections:
		total_bars += int(section_length)
	return {
		"bpm": bpm,
		"bars": total_bars,
		"chords": chords,
		"form": form,
		"tonal_center": tonal_center,
		"cfg": cfg,
	}


static func _section_index(bar_position: float, section_bars: Array) -> int:
	var boundary := 0.0
	for section_index in range(section_bars.size()):
		boundary += float(section_bars[section_index])
		if bar_position < boundary:
			return section_index
	return maxi(0, section_bars.size() - 1)


static func _is_section_end(bar_index: int, section_bars: Array) -> bool:
	var boundary := 0
	for section_length in section_bars:
		boundary += int(section_length)
		if bar_index + 1 == boundary:
			return true
	return false


static func _track(bpm: float, bars: int, chords: Array, cfg: Dictionary) -> AudioStreamWAV:
	var beat := 60.0 / bpm
	var total := int(round(float(bars) * 4.0 * beat * RATE))
	var out := PackedFloat32Array()
	out.resize(total)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(bpm * 13.0) + bars * 31
	var bars_per_chord := maxf(1.0, float(bars) / float(chords.size()))
	var div: int = cfg.get("arp_div", 2)
	var section_bars: Array = cfg.get("section_bars", [bars])
	var section_gains: Array = cfg.get("section_gains", [])
	var bass_pattern: Array = cfg.get("bass_pattern", [0, 2])
	var melody_patterns: Array = cfg.get("melody_patterns", [])
	var melody_answers: Array = cfg.get("melody_answers", [])
	var lead_style := String(cfg.get("lead_style", "bell"))
	var pad_style := String(cfg.get("pad_style", "warm"))
	var step := beat / float(div)
	var arp_notes: Array = []
	match int(div):
		4:
			arp_notes = [0, 1, 2, 1, 0, 2, 1, 2]
		2:
			arp_notes = [0, 1, 2, 1]
		_:
			arp_notes = [0, 1, 2]
	for ci in range(chords.size()):
		var chord: Array = chords[ci]
		var start_bar := float(ci) * bars_per_chord
		var dur_bars := bars_per_chord
		var start_sample := int(start_bar * 4.0 * beat * RATE)
		var section_index := _section_index(start_bar, section_bars)
		var section_gain := 1.0
		if not section_gains.is_empty():
			section_gain = float(section_gains[mini(section_index, section_gains.size() - 1)])
		# pad sostenido
		if float(cfg.get("pad", 0.0)) > 0.0:
			var freqs: Array = []
			for n in chord:
				freqs.append(midi(int(n)))
			var pad := _pad(freqs, dur_bars * 4.0 * beat, float(cfg["pad"]) * section_gain, pad_style)
			_mix(out, pad, start_sample, 1.0)
		# arpegio
		var steps := int(dur_bars * 4.0 * float(div))
		for s in range(steps):
			var pattern_index := (s + ci + section_index * 2) % arp_notes.size()
			var chord_note := int(arp_notes[pattern_index]) % chord.size()
			var steps_per_bar := int(4.0 * float(div))
			if chord.size() > 3 and s % steps_per_bar == steps_per_bar - 1:
				chord_note = 3
			var tone: int = chord[chord_note]
			if cfg.get("dark", false) and rng.randf() < 0.08:
				tone -= 1
			var octave := 12 if (s % 8 >= 4) else 0
			var f := midi(int(tone) + 12 + octave)
			var accent := 1.12 if s % steps_per_bar == 0 else 0.9
			var amp: float = float(cfg["arp"]) * section_gain * rng.randf_range(0.82, 0.96) * accent
			var p := _pluck(f, minf(beat * 2.2, 0.9), amp)
			_mix(out, p, start_sample + int(s * step * RATE), 1.0)
		# bajo
		if float(cfg.get("bass", 0.0)) > 0.0:
			for b in range(int(dur_bars * 4.0)):
				if b % 2 == 0:
					var bass_step := int(b / 2) % maxi(1, bass_pattern.size())
					var bass_degree := int(bass_pattern[bass_step]) % chord.size()
					var bass_note: int = chord[bass_degree]
					var f2 := midi(int(bass_note) - 12)
					var p2 := _pluck(f2, beat * 1.45, float(cfg["bass"]) * section_gain, 0.998)
					_mix(out, p2, start_sample + int(b * beat * RATE), 1.0)
		# melodía
		if bool(cfg.get("melody", false)):
			var melody_pattern: Array = [0, -1, 1, 2, 3, -1, 2, -1]
			if not melody_patterns.is_empty():
				melody_pattern = melody_patterns[mini(section_index, melody_patterns.size() - 1)]
			if not melody_answers.is_empty() and ci % 2 == 1:
				melody_pattern = melody_answers[mini(section_index, melody_answers.size() - 1)]
			for m in range(melody_pattern.size()):
				var note_index := int(melody_pattern[m])
				if note_index < 0:
					continue
				var pickn: int = chord[note_index % chord.size()] + 12
				if section_index == 1 and m % 4 == 2:
					pickn += 12
				var accent: float = MELODY_ACCENTS[m % MELODY_ACCENTS.size()]
				var melody_amp := float(cfg.get("melody_amp", 0.12)) * section_gain * accent
				var fm := midi(pickn)
				var gate := float(cfg.get("melody_gate", 1.1))
				var pm := _lead_voice(fm, beat * gate, melody_amp, lead_style)
				var melody_at := start_sample + int(m * beat * RATE)
				_mix(out, pm, melody_at, 1.0)
				var echo_delay := float(cfg.get("lead_echo_delay", 0.0))
				if echo_delay > 0.0:
					_mix(out, pm, melody_at + int(echo_delay * RATE), float(cfg.get("lead_echo_gain", 0.0)))
			var counter_patterns: Array = cfg.get("counterline_patterns", [])
			if bool(cfg.get("counterline", false)) and counter_patterns.size() > section_index:
				var counter_pattern: Array = counter_patterns[section_index]
				for counter_step in range(counter_pattern.size()):
					var counter_degree := int(counter_pattern[counter_step])
					if counter_degree < 0:
						continue
					var counter_note := int(chord[counter_degree % chord.size()]) + 24
					var counter_voice := _lead_voice(
						midi(counter_note), beat * 0.72,
						float(cfg.get("melody_amp", 0.12)) * section_gain * float(cfg.get("counterline_gain", 0.24)),
						String(cfg.get("counterline_style", lead_style))
					)
					var counter_at := start_sample + int((float(counter_step) + 0.5) * beat * RATE)
					_mix(out, counter_voice, counter_at, 1.0)
	# percusión global
	var drum_amp: float = cfg.get("drums", 0.0)
	if drum_amp > 0.0:
		var beats_total := int(float(bars) * 4.0)
		var kick := _kick(0.18, 0.75 * drum_amp)
		var snare := _snare(0.12, 0.45 * drum_amp)
		var hat := _hat(0.045, 0.22 * drum_amp)
		for b in range(beats_total):
			var at := int(b * beat * RATE)
			var bar_index := int(b / 4)
			var section_index := _section_index(float(bar_index), section_bars)
			var section_gain := 1.0
			if not section_gains.is_empty():
				section_gain = float(section_gains[mini(section_index, section_gains.size() - 1)])
			if b % 4 == 0 or b % 4 == 2:
				_mix(out, kick, at, section_gain)
			if b % 4 == 1 or b % 4 == 3:
				_mix(out, snare, at, section_gain)
			_mix(out, hat, at + int(beat * 0.5 * RATE), section_gain)
			if drum_amp > 0.6:
				_mix(out, hat, at, 0.8 * section_gain)
			if b % 4 == 3 and bool(cfg.get("drum_fills", false)):
				if (bar_index + 1) % 4 == 0:
					_mix(out, hat, at + int(beat * 0.72 * RATE), 0.55 * section_gain)
				if _is_section_end(bar_index, section_bars):
					for fill_step in range(1, 4):
						var fill_at := at + int(beat * float(fill_step) * 0.25 * RATE)
						if fill_at + snare.size() <= total:
							_mix(out, snare, fill_at, 0.3 * section_gain)
	if bool(cfg.get("hammer", false)):
		for b in range(int(float(bars) * 4.0)):
			var bar_index := int(b / 4)
			var section_index := _section_index(float(bar_index), section_bars)
			var section_gain := 1.0
			if not section_gains.is_empty():
				section_gain = float(section_gains[mini(section_index, section_gains.size() - 1)])
			if b % 4 == 1 or (section_index == 1 and b % 4 == 3):
				var clank := _anvil()
				_mix(out, clank, int(b * beat * RATE), 0.72 * section_gain)
	_crossfade_loop(out, int(0.28 * RATE))
	# normalización suave
	var peak := 0.0
	for i in range(total):
		peak = maxf(peak, absf(out[i]))
	if peak > 0.9:
		var k := 0.9 / peak
		for i in range(total):
			out[i] *= k
	var w := _wav(out)
	w.loop_mode = AudioStreamWAV.LOOP_FORWARD
	w.loop_begin = 0
	w.loop_end = total
	return w


static func _crossfade_loop(samples: PackedFloat32Array, blend_size: int) -> void:
	var total := samples.size()
	var width := mini(blend_size, total >> 1)
	if width < 2:
		return
	var seam_value := (samples[0] + samples[total - 1]) * 0.5
	var head := PackedFloat32Array()
	var tail := PackedFloat32Array()
	head.resize(width)
	tail.resize(width)
	for i in range(width):
		head[i] = samples[i]
		tail[i] = samples[total - width + i]
	for i in range(width):
		var t := float(i) / float(width - 1)
		var eased := t * t * (3.0 - 2.0 * t)
		samples[i] = lerpf(seam_value, head[i], eased)
		samples[total - width + i] = lerpf(tail[i], seam_value, eased)


static func _anvil() -> PackedFloat32Array:
	var total := int(0.25 * RATE)
	var out := PackedFloat32Array()
	out.resize(total)
	for i in range(total):
		var t := float(i) / RATE
		var env := exp(-t * 30.0)
		var v := sin(TAU * 1180.0 * t) * 0.5 + sin(TAU * 1870.0 * t) * 0.3 + sin(TAU * 2630.0 * t) * 0.2
		out[i] = v * env * 0.35
	return out


# ------------------------------------------------------------------- SFX

static func sfx(kind: String) -> AudioStreamWAV:
	match kind:
		"select":
			return _tone_seq([880.0], 0.05, 0.25)
		"confirm":
			return _tone_seq([660.0, 990.0], 0.06, 0.28)
		"correct":
			return _chord_strike([523.25, 659.25, 783.99], 0.55, 0.32)
		"incorrect":
			return _thud(110.0, 0.3, 0.5)
		"attack":
			return _whoosh(0.18, 0.5)
		"arcane":
			return _sweep(180.0, 1400.0, 0.45, 0.35)
		"player_hit":
			return _thud(70.0, 0.35, 0.6)
		"enemy_hit":
			return _thud(150.0, 0.2, 0.45)
		"heal":
			return _sweep(520.0, 1560.0, 0.5, 0.28)
		"enemy_death":
			return _sweep(320.0, 60.0, 0.6, 0.5)
		"loot":
			return _chime_seq([1046.5, 1318.5], 0.4, 0.3)
		"equipment":
			return _wav(_anvil())
		"blacksmith":
			return _wav(_anvil())
		"angel":
			return _chord_strike([523.25, 659.25, 783.99, 1046.5], 1.2, 0.3)
		"boss":
			return _thud(55.0, 0.9, 0.7)
		"death":
			return _chord_strike([220.0, 261.63, 329.63], 1.4, 0.35)
		"victory":
			return _chime_seq([523.25, 659.25, 783.99, 1046.5], 0.7, 0.32)
		_:
			return _tone_seq([440.0], 0.05, 0.2)


static func _tone_seq(freqs: Array, dur: float, amp: float) -> AudioStreamWAV:
	var total := int(dur * RATE * freqs.size())
	var out := PackedFloat32Array()
	out.resize(total)
	var per := int(dur * RATE)
	for k in range(freqs.size()):
		var f: float = freqs[k]
		for i in range(per):
			var t := float(i) / RATE
			var env := exp(-t * 18.0)
			out[k * per + i] += sin(TAU * f * t) * env * amp
	return _wav(out)


static func _chime_seq(freqs: Array, dur: float, amp: float) -> AudioStreamWAV:
	var total := int(dur * RATE)
	var out := PackedFloat32Array()
	out.resize(total)
	var gap := total / maxi(1, freqs.size())
	for k in range(freqs.size()):
		var c := _chime(float(freqs[k]), dur, amp)
		for i in range(c.size()):
			var j := k * gap + i
			if j < total:
				out[j] += c[i]
	return _wav(out)


static func _chord_strike(freqs: Array, dur: float, amp: float) -> AudioStreamWAV:
	var total := int(dur * RATE)
	var out := PackedFloat32Array()
	out.resize(total)
	for f in freqs:
		for i in range(total):
			var t := float(i) / RATE
			var env := exp(-t * 4.0)
			out[i] += sin(TAU * float(f) * t) * env * amp / float(freqs.size())
	return _wav(out)


static func _thud(freq: float, dur: float, amp: float) -> AudioStreamWAV:
	var total := int(dur * RATE)
	var out := PackedFloat32Array()
	out.resize(total)
	var rng := RandomNumberGenerator.new()
	rng.seed = int(freq)
	for i in range(total):
		var t := float(i) / RATE
		var env := exp(-t * 16.0)
		out[i] = sin(TAU * freq * t * (1.0 - t * 0.4)) * env * amp + rng.randf_range(-1, 1) * env * 0.08
	return _wav(out)


static func _sweep(f0: float, f1: float, dur: float, amp: float) -> AudioStreamWAV:
	var total := int(dur * RATE)
	var out := PackedFloat32Array()
	out.resize(total)
	var phase := 0.0
	for i in range(total):
		var t := float(i) / RATE
		var k := t / dur
		var f := lerpf(f0, f1, k)
		phase += TAU * f / RATE
		var env := sin(PI * minf(1.0, k)) * exp(-k * 1.5)
		out[i] = sin(phase) * env * amp
	return _wav(out)


static func _whoosh(dur: float, amp: float) -> AudioStreamWAV:
	var total := int(dur * RATE)
	var out := PackedFloat32Array()
	out.resize(total)
	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	var y := 0.0
	for i in range(total):
		var t := float(i) / RATE
		var k := t / dur
		var env := sin(PI * k) * 0.8
		y = lerpf(y, rng.randf_range(-1, 1), 0.35 + k * 0.4)
		out[i] = y * env * amp
	return _wav(out)
