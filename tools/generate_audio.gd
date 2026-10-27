extends SceneTree
## Exporta las composiciones procedurales de Synth a WAV reproducibles.

const AudioSynth = preload("res://src/audio/synth.gd")

const MUSIC := {
	"menu": "music_menu.wav",
	"combat": "music_combat.wav",
	"boss": "music_boss.wav",
	"blacksmith": "music_blacksmith.wav",
	"angel": "music_angel.wav",
	"death": "music_game_over.wav",
}

const SFX := {
	"select": "sfx_select.wav",
	"confirm": "sfx_confirm.wav",
	"correct": "sfx_answer_correct.wav",
	"incorrect": "sfx_answer_incorrect.wav",
	"attack": "sfx_attack.wav",
	"arcane": "sfx_attack_arcane.wav",
	"player_hit": "sfx_player_hit.wav",
	"enemy_hit": "sfx_enemy_hit.wav",
	"heal": "sfx_heal.wav",
	"enemy_death": "sfx_enemy_death.wav",
	"loot": "sfx_loot.wav",
	"equipment": "sfx_equipment.wav",
	"blacksmith": "sfx_blacksmith.wav",
	"angel": "sfx_angel_appearance.wav",
	"boss": "sfx_boss_appearance.wav",
	"death": "sfx_death.wav",
	"victory": "sfx_victory.wav",
}


func _initialize() -> void:
	var failures := 0
	var music_manifest := {}
	var sfx_manifest := {}
	var music_dir := ProjectSettings.globalize_path("res://assets/audio/music")
	var sfx_dir := ProjectSettings.globalize_path("res://assets/audio/sfx")
	DirAccess.make_dir_recursive_absolute(music_dir)
	DirAccess.make_dir_recursive_absolute(sfx_dir)
	for id in MUSIC:
		var stream: AudioStreamWAV = AudioSynth.music(id)
		var filename := String(MUSIC[id])
		if not _save(stream, music_dir.path_join(filename)):
			failures += 1
		var music_id := "music_game_over" if String(id) == "death" else "music_" + String(id)
		var entry := _manifest_entry(stream, "music/" + filename, true)
		entry.merge(AudioSynth.music_info(String(id)), true)
		music_manifest[music_id] = entry
	for id in SFX:
		var stream: AudioStreamWAV = AudioSynth.sfx(id)
		var filename := String(SFX[id])
		if not _save(stream, sfx_dir.path_join(filename)):
			failures += 1
		sfx_manifest[filename.trim_suffix(".wav")] = _manifest_entry(stream, "sfx/" + filename, false)
	if failures == 0:
		if not _write_manifest({"format": "WAV PCM signed 16-bit", "sample_rate_hz": AudioSynth.RATE, "channels": 1, "music": music_manifest, "sfx": sfx_manifest}):
			failures += 1
	if failures == 0:
		print("Exportados %d loops y %d efectos WAV." % [MUSIC.size(), SFX.size()])
	quit(1 if failures > 0 else 0)


func _save(stream: AudioStreamWAV, path: String) -> bool:
	var result := stream.save_to_wav(path)
	if result != OK:
		push_error("No se pudo exportar %s (Error %d)." % [path, result])
		return false
	print("WAV: %s (%.2f s)" % [path.get_file(), stream.get_length()])
	return true


func _manifest_entry(stream: AudioStreamWAV, relative_path: String, looping: bool) -> Dictionary:
	var entry := {
		"file": relative_path,
		"sample_count": int(stream.data.size() / 2),
		"duration_seconds": snappedf(stream.get_length(), 0.001),
		"loop": looping,
		"source": "Synth.music" if looping else "Synth.sfx",
	}
	if looping:
		entry["loop_start_sample"] = 0
		entry["loop_end_sample"] = int(stream.data.size() / 2)
		entry["loop_start_seconds"] = 0.0
		entry["loop_end_seconds"] = snappedf(stream.get_length(), 0.001)
	return entry


func _write_manifest(data: Dictionary) -> bool:
	var path := ProjectSettings.globalize_path("res://assets/audio/audio_manifest.json")
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("No se pudo escribir el manifiesto de audio.")
		return false
	file.store_string(JSON.stringify(data, "\t"))
	file.close()
	return true
