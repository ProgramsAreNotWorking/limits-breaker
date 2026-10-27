extends Node
## Reproductor centralizado. Autoload: Audio.

const MediaManifest = preload("res://src/core/asset_manifest.gd")

const SFX_VOICES := 8
const MUSIC_SILENT_DB := -60.0
const SFX_REPEAT_GUARD_MS := 70

var music_player: AudioStreamPlayer
var sfx_players: Array[AudioStreamPlayer] = []
var cache: Dictionary = {}
var current_music: String = ""
var sfx_cursor: int = 0
var music_tween: Tween
var last_sfx_at: Dictionary = {}
var playback_enabled := true


func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.name = "Music"
	add_child(music_player)
	for i in range(SFX_VOICES):
		var p := AudioStreamPlayer.new()
		p.name = "Sfx%d" % i
		add_child(p)
		sfx_players.append(p)
	apply_volumes()
	get_tree().root.tree_exiting.connect(shutdown)


func apply_volumes() -> void:
	if music_player == null:
		return
	var mv := clampf(float(Game.settings.get("music", 0.65)), 0.0, 1.0)
	var sv := clampf(float(Game.settings.get("sfx", 0.85)), 0.0, 1.0)
	var music_db := linear_to_db(maxf(0.0001, mv))
	if music_tween == null or not music_tween.is_running():
		music_player.volume_db = music_db
	for p in sfx_players:
		p.volume_db = linear_to_db(maxf(0.0001, sv))


func play_music(id: String) -> void:
	if not playback_enabled or music_player == null:
		return
	if id == current_music and music_player.playing:
		return
	var key := "music:" + id
	var stream: AudioStream
	if cache.has(key):
		stream = cache[key]
	else:
		stream = _music_stream(id)
		cache[key] = stream
	if music_tween != null and music_tween.is_running():
		music_tween.kill()
	if music_player.playing:
		music_tween = create_tween()
		music_tween.tween_property(music_player, "volume_db", MUSIC_SILENT_DB, 0.18)
		music_tween.tween_callback(Callable(self, "_switch_music").bind(stream, id))
	else:
		_switch_music(stream, id)


func _switch_music(stream: AudioStream, id: String) -> void:
	music_player.stream = stream
	music_player.volume_db = MUSIC_SILENT_DB
	music_player.play()
	current_music = id
	music_tween = create_tween()
	music_tween.tween_property(music_player, "volume_db", _music_volume_db(), 0.35)


func stop_music() -> void:
	if music_player == null:
		return
	if music_tween != null and music_tween.is_running():
		music_tween.kill()
	if not music_player.playing:
		current_music = ""
		return
	music_tween = create_tween()
	music_tween.tween_property(music_player, "volume_db", MUSIC_SILENT_DB, 0.18)
	music_tween.tween_callback(func() -> void:
		music_player.stop()
		current_music = ""
	)


func shutdown() -> void:
	if music_tween != null and music_tween.is_running():
		music_tween.kill()
	if music_player != null:
		music_player.stop()
		music_player.stream = null
		music_player.queue_free()
		music_player = null
	for p in sfx_players:
		p.stop()
		p.stream = null
		p.queue_free()
	sfx_players.clear()
	cache.clear()
	last_sfx_at.clear()
	current_music = ""


func play_sfx(id: String) -> void:
	if not playback_enabled or sfx_players.is_empty():
		return
	var now := Time.get_ticks_msec()
	if now - int(last_sfx_at.get(id, -1000000)) < SFX_REPEAT_GUARD_MS:
		return
	last_sfx_at[id] = now
	var key := "sfx:" + id
	if not cache.has(key):
		cache[key] = _sfx_stream(id)
	var p := sfx_players[sfx_cursor]
	sfx_cursor = (sfx_cursor + 1) % sfx_players.size()
	p.stream = cache[key]
	p.play()


func _music_stream(id: String) -> AudioStream:
	var path := String(MediaManifest.MUSIC_FILES.get(id, MediaManifest.MUSIC_FILES["combat"]))
	if ResourceLoader.exists(path):
		var resource := load(path) as AudioStream
		if resource != null:
			if resource is AudioStreamWAV:
				var wave := resource as AudioStreamWAV
				wave.loop_mode = AudioStreamWAV.LOOP_FORWARD
				wave.loop_begin = 0
				wave.loop_end = int(round(wave.get_length() * float(wave.mix_rate)))
			return resource
	return Synth.music(id)


func _sfx_stream(id: String) -> AudioStream:
	var path := String(MediaManifest.SFX_FILES.get(id, ""))
	if path != "" and ResourceLoader.exists(path):
		var resource := load(path) as AudioStream
		if resource != null:
			return resource
	return Synth.sfx(id)


func _music_volume_db() -> float:
	return linear_to_db(maxf(0.0001, clampf(float(Game.settings.get("music", 0.65)), 0.0, 1.0)))
