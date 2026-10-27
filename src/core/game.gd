extends Node
## Estado persistente y estado de la run. Autoload: Game.

signal state_changed

const SAVE_PATH := "user://limits_breaker_save.json"
const BASE_MAX_HP := 100
const BLACKSMITH_INTERVAL := 4
const ANGEL_FIRST_ENCOUNTER := 3
const ANGEL_CHANCE := 0.06
const DEFAULT_WINDOW_RESOLUTION := "1280x720"
const WINDOW_RESOLUTION_OPTIONS: Array[String] = [
	"960x540",
	"1280x720",
	"1600x900",
	"1920x1080",
	"2560x1440",
]

var mastery: Dictionary = {}
var settings: Dictionary = {
	"music": 0.65,
	"sfx": 0.85,
	"reduced_motion": false,
	"resolution": DEFAULT_WINDOW_RESOLUTION,
	"screen_mode": "windowed",
}
var run: Dictionary = {}


func _ready() -> void:
	_reset_mastery()
	load_game()
	_normalize_display_settings()
	_reset_run()


func available_window_resolutions() -> Array[String]:
	var available: Array[String] = []
	var screen_index := DisplayServer.window_get_current_screen()
	var screen_size := DisplayServer.screen_get_size(screen_index)
	if screen_size.x <= 0 or screen_size.y <= 0:
		for resolution in WINDOW_RESOLUTION_OPTIONS:
			available.append(resolution)
		return available
	for resolution in WINDOW_RESOLUTION_OPTIONS:
		var size := _resolution_from_key(resolution)
		if size.x < screen_size.x and size.y < screen_size.y:
			available.append(resolution)
	if available.is_empty():
		available.append("%dx%d" % [screen_size.x, screen_size.y])
	return available


func apply_display_settings() -> void:
	# El editor controla el tamaño y el modo de la vista de juego integrada.
	# La preferencia queda guardada y se aplica cuando se ejecuta como ventana propia.
	if Engine.is_embedded_in_editor():
		return
	if String(settings.get("screen_mode", "windowed")) == "fullscreen":
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		return

	var window_size := _resolution_from_key(String(settings.get("resolution", DEFAULT_WINDOW_RESOLUTION)))
	if window_size == Vector2i.ZERO:
		window_size = _resolution_from_key(DEFAULT_WINDOW_RESOLUTION)
	var screen_index := DisplayServer.window_get_current_screen()
	var screen_size := DisplayServer.screen_get_size(screen_index)
	if screen_size.x > 0 and screen_size.y > 0:
		window_size = Vector2i(mini(window_size.x, screen_size.x), mini(window_size.y, screen_size.y))

	DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
	DisplayServer.window_set_size(window_size)
	if screen_size.x > 0 and screen_size.y > 0:
		var screen_position := DisplayServer.screen_get_position(screen_index)
		var centered_position := screen_position + Vector2i(
			maxi(0, int(float(screen_size.x - window_size.x) / 2.0)),
			maxi(0, int(float(screen_size.y - window_size.y) / 2.0)),
		)
		DisplayServer.window_set_position(centered_position)


func _normalize_display_settings() -> void:
	var available := available_window_resolutions()
	var resolution := String(settings.get("resolution", DEFAULT_WINDOW_RESOLUTION))
	if not available.has(resolution):
		resolution = available[available.size() - 1]
	settings["resolution"] = resolution
	var screen_mode := String(settings.get("screen_mode", "windowed"))
	if screen_mode not in ["windowed", "fullscreen"]:
		screen_mode = "windowed"
	settings["screen_mode"] = screen_mode


func _resolution_from_key(resolution: String) -> Vector2i:
	var parts := resolution.split("x")
	if parts.size() != 2:
		return Vector2i.ZERO
	var width := int(parts[0])
	var height := int(parts[1])
	if width <= 0 or height <= 0:
		return Vector2i.ZERO
	return Vector2i(width, height)


# ------------------------------------------------------------------ mastery

func _reset_mastery() -> void:
	mastery.clear()
	for t in MathEngine.TOPICS:
		mastery[t] = {
			"attempts": 0,
			"correct": 0,
			"by_diff": [0, 0, 0, 0],
			"correct_by_diff": [0, 0, 0, 0],
			"streak": 0,
			"best_streak": 0,
		}


func topic_stats(topic: String) -> Dictionary:
	return mastery.get(topic, {})


func accuracy(topic: String) -> float:
	var s := topic_stats(topic)
	var a := int(s.get("attempts", 0))
	if a <= 0:
		return 0.0
	return float(s.get("correct", 0)) / float(a)


func accuracy_diff(topic: String, diff: int) -> float:
	var s := topic_stats(topic)
	var arr: Array = s.get("by_diff", [0, 0, 0, 0])
	var carr: Array = s.get("correct_by_diff", [0, 0, 0, 0])
	var a := int(arr[clampi(diff, 0, 3)])
	if a <= 0:
		return 0.0
	return float(carr[clampi(diff, 0, 3)]) / float(a)


func mastery_level(topic: String) -> int:
	var s := topic_stats(topic)
	var carr: Array = s.get("correct_by_diff", [0, 0, 0, 0])
	var level := 0
	if int(carr[0]) >= 3 and accuracy(topic) >= 0.5:
		level = 1
	if level >= 1 and int(carr[1]) >= 4 and accuracy_diff(topic, 1) >= 0.6:
		level = 2
	if level >= 2 and int(carr[2]) >= 4 and accuracy_diff(topic, 2) >= 0.7:
		level = 3
	return level


func unlocked_difficulty(topic: String) -> int:
	# Fácil e Intermedio están disponibles desde el inicio; Avanzado y
	# Superdifícil exigen competencia demostrada.
	return clampi(1 + mastery_level(topic), 1, 3)


func record_answer(topic: String, diff: int, correct: bool) -> void:
	if not mastery.has(topic):
		return
	var s: Dictionary = mastery[topic]
	s["attempts"] = int(s["attempts"]) + 1
	var by: Array = s["by_diff"]
	var cby: Array = s["correct_by_diff"]
	by[diff] = int(by[diff]) + 1
	if correct:
		s["correct"] = int(s["correct"]) + 1
		cby[diff] = int(cby[diff]) + 1
		s["streak"] = int(s["streak"]) + 1
		s["best_streak"] = maxi(int(s["best_streak"]), int(s["streak"]))
	else:
		s["streak"] = 0
	if run.get("active", false):
		var st: Dictionary = run["stats"]
		st["problems"] = int(st["problems"]) + 1
		if correct:
			st["solved"] = int(st["solved"]) + 1
		var bt: Dictionary = st["by_topic"]
		if not bt.has(topic):
			bt[topic] = {"attempts": 0, "correct": 0}
		bt[topic]["attempts"] = int(bt[topic]["attempts"]) + 1
		if correct:
			bt[topic]["correct"] = int(bt[topic]["correct"]) + 1
	save_game()
	state_changed.emit()


func pick_topic(rng: RandomNumberGenerator) -> String:
	var weighted: Array = []
	for t in MathEngine.TOPICS:
		var s := topic_stats(t)
		var attempts := int(s.get("attempts", 0))
		var w := 1.0 + (1.0 - accuracy(t)) * 2.0
		if attempts < 3:
			w += 1.5
		var copies := maxi(1, int(round(w * 2.0)))
		for i in range(copies):
			weighted.append(t)
	return weighted[rng.randi_range(0, weighted.size() - 1)]


# ---------------------------------------------------------------- run state

func _reset_run() -> void:
	run = {
		"active": false,
		"encounter": 1,
		"level": 1,
		"xp": 0,
		"berserk_charge": 0,
		"hp": BASE_MAX_HP,
		"inventory": [],
		"equipped": {"weapon": "", "armor": "", "relic": ""},
		"upgrade_damage": 0,
		"upgrade_defense": 0,
		"upgrade_hp": 0,
		"angel_used": false,
		"stats": {
			"enemies": 0,
			"problems": 0,
			"solved": 0,
			"by_topic": {},
			"loot": [],
			"furthest": 0,
			"topics_need_practice": [],
		},
	}


func start_run() -> void:
	_reset_run()
	run["active"] = true
	save_game()
	state_changed.emit()


func max_hp() -> int:
	return BASE_MAX_HP + Combat.max_hp_bonus(run["equipped"]) + int(run.get("upgrade_hp", 0))


func hp() -> int:
	return int(run.get("hp", max_hp()))


func add_hp(amount: int) -> int:
	var before := hp()
	run["hp"] = mini(max_hp(), before + maxi(0, amount))
	state_changed.emit()
	return hp() - before


func damage_player(amount: int) -> int:
	var before := hp()
	run["hp"] = maxi(0, before - maxi(0, amount))
	state_changed.emit()
	return before - hp()


func player_level() -> int:
	return clampi(int(run.get("level", 1)), 1, Combat.MAX_PLAYER_LEVEL)


func xp_to_next_level() -> int:
	if player_level() >= Combat.MAX_PLAYER_LEVEL:
		return 0
	return 50 + (player_level() - 1) * 25


func award_combat_xp(amount: int) -> int:
	if not bool(run.get("active", false)) or player_level() >= Combat.MAX_PLAYER_LEVEL:
		return 0
	run["xp"] = int(run.get("xp", 0)) + maxi(0, amount)
	var gained := 0
	while player_level() < Combat.MAX_PLAYER_LEVEL and int(run.get("xp", 0)) >= xp_to_next_level():
		run["xp"] = int(run.get("xp", 0)) - xp_to_next_level()
		run["level"] = player_level() + 1
		gained += 1
	state_changed.emit()
	return gained


func berserk_progress() -> int:
	return clampi(int(run.get("berserk_charge", 0)), 0, Combat.BERSERK_CHARGE_ROUNDS)


func charge_berserk_turn() -> int:
	if not bool(run.get("active", false)):
		return berserk_progress()
	run["berserk_charge"] = mini(Combat.BERSERK_CHARGE_ROUNDS, berserk_progress() + 1)
	state_changed.emit()
	return berserk_progress()


func consume_berserk_charge() -> bool:
	if berserk_progress() < Combat.BERSERK_CHARGE_ROUNDS:
		return false
	run["berserk_charge"] = 0
	state_changed.emit()
	return true


func attack_damage(difficulty: int, attack_id: String = "") -> int:
	return Combat.player_attack(difficulty, run["equipped"], attack_id) + int(run.get("upgrade_damage", 0))


func defense() -> int:
	return Combat.player_defense(run["equipped"]) + int(run.get("upgrade_defense", 0))


func enemy_damage(enemy: Dictionary, living_enemy_count: int = 1) -> int:
	var ratio := float(hp()) / float(max_hp()) if max_hp() > 0 else 1.0
	var base := maxi(1, int(enemy.get("attack", 1)) + (2 if ratio <= 0.5 else 0) - defense())
	var group_scale := float(maxi(1, living_enemy_count))
	return maxi(1, int(roundf(float(base) / group_scale)))


func failing_self_damage(difficulty: int) -> int:
	if difficulty < 2:
		return 0
	return Combat.self_damage(difficulty)


# ---------------------------------------------------------------- inventario

func inventory() -> Array:
	return run.get("inventory", [])


func inventory_full() -> bool:
	return inventory().size() >= 4


func add_item(id: String) -> bool:
	if inventory_full():
		return false
	run["inventory"].append(id)
	run["stats"]["loot"].append(id)
	state_changed.emit()
	return true


func discard_item(id: String) -> void:
	var inv: Array = run["inventory"]
	var idx := inv.find(id)
	if idx >= 0:
		inv.remove_at(idx)
		state_changed.emit()


func equip_item(id: String) -> String:
	var it: Dictionary = Combat.item(id)
	if it.is_empty():
		return ""
	var slot: String = it.get("slot", "")
	if slot not in ["weapon", "armor", "relic"]:
		return ""
	var inv: Array = run["inventory"]
	var idx := inv.find(id)
	if idx < 0:
		return ""
	var previous: String = run["equipped"].get(slot, "")
	inv.remove_at(idx)
	if previous != "":
		inv.append(previous)
	run["equipped"][slot] = id
	run["hp"] = mini(hp(), max_hp())
	state_changed.emit()
	return previous


func unequip(slot: String) -> bool:
	var current: String = run["equipped"].get(slot, "")
	if current == "":
		return false
	if inventory_full():
		return false
	run["inventory"].append(current)
	run["equipped"][slot] = ""
	run["hp"] = mini(hp(), max_hp())
	state_changed.emit()
	return true


func use_consumable(id: String) -> bool:
	var it: Dictionary = Combat.item(id)
	if it.is_empty() or it.get("slot", "") != "consumable":
		return false
	add_hp(int(it.get("heal", 0)))
	discard_item(id)
	return true


func apply_upgrade(id: String) -> void:
	match id:
		"temper":
			run["upgrade_damage"] = int(run["upgrade_damage"]) + 2
		"reinforce":
			run["upgrade_hp"] = int(run["upgrade_hp"]) + 12
			add_hp(12)
		"enchant":
			run["upgrade_defense"] = int(run["upgrade_defense"]) + 2
	state_changed.emit()


func angel_heal_for(difficulty: int) -> int:
	return [20, 35, 50, 70][clampi(difficulty, 0, 3)]


func is_blacksmith_encounter(encounter: int) -> bool:
	return encounter > 1 and encounter % BLACKSMITH_INTERVAL == 0


func should_spawn_angel(encounter: int, rng: RandomNumberGenerator) -> bool:
	if encounter < ANGEL_FIRST_ENCOUNTER or bool(run.get("angel_used", false)):
		return false
	if rng.randf() >= ANGEL_CHANCE:
		return false
	run["angel_used"] = true
	return true


# ------------------------------------------------------------------ deaths

func end_run(victory: bool = false) -> Dictionary:
	var st: Dictionary = run["stats"]
	st["furthest"] = maxi(
		int(st.get("furthest", 0)),
		int(run["encounter"]) - (1 if victory else 0)
	)
	st["result"] = "victory" if victory else "death"
	var need: Array = []
	for t in MathEngine.TOPICS:
		var s := topic_stats(t)
		if int(s.get("attempts", 0)) >= 2 and accuracy(t) < 0.6:
			need.append(t)
	st["topics_need_practice"] = need
	run["active"] = false
	save_game()
	state_changed.emit()
	return st


# ------------------------------------------------------------------- guardar

func save_game() -> void:
	var data := {"mastery": mastery, "settings": settings, "version": 1}
	var f := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if f == null:
		return
	f.store_string(JSON.stringify(data, "\t"))
	f.close()


func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		return
	var f := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if f == null:
		return
	var text := f.get_as_text()
	f.close()
	var parser := JSON.new()
	if parser.parse(text) != OK:
		return
	var parsed: Variant = parser.data
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	var saved_mastery = parsed.get("mastery", {})
	if typeof(saved_mastery) == TYPE_DICTIONARY:
		for t in MathEngine.TOPICS:
			var topic_save = saved_mastery.get(t, null)
			if typeof(topic_save) == TYPE_DICTIONARY:
				mastery[t] = _sanitize_topic(topic_save)
	var saved_settings = parsed.get("settings", {})
	if typeof(saved_settings) == TYPE_DICTIONARY:
		if saved_settings.has("music"):
			settings["music"] = clampf(_number_or(saved_settings["music"], 0.65), 0.0, 1.0)
		if saved_settings.has("sfx"):
			settings["sfx"] = clampf(_number_or(saved_settings["sfx"], 0.85), 0.0, 1.0)
		if saved_settings.has("reduced_motion"):
			var reduced = saved_settings["reduced_motion"]
			settings["reduced_motion"] = reduced if typeof(reduced) == TYPE_BOOL else false
		if saved_settings.has("resolution"):
			var saved_resolution := String(saved_settings["resolution"])
			if _resolution_from_key(saved_resolution) != Vector2i.ZERO:
				settings["resolution"] = saved_resolution
		if saved_settings.has("screen_mode"):
			var saved_screen_mode := String(saved_settings["screen_mode"])
			if saved_screen_mode in ["windowed", "fullscreen"]:
				settings["screen_mode"] = saved_screen_mode


func _number_or(value: Variant, fallback: float) -> float:
	if typeof(value) in [TYPE_INT, TYPE_FLOAT]:
		return float(value)
	return fallback


func _sanitize_topic(saved: Dictionary) -> Dictionary:
	var by := _four_counts(saved.get("by_diff", []))
	var correct_by := _four_counts(saved.get("correct_by_diff", []))
	var correct_total := 0
	var attempts_total := 0
	for i in range(4):
		by[i] = maxi(by[i], correct_by[i])
		correct_by[i] = mini(correct_by[i], by[i])
		attempts_total += by[i]
		correct_total += correct_by[i]
	var attempts := maxi(_count_or(saved.get("attempts", 0)), attempts_total)
	var correct := clampi(_count_or(saved.get("correct", 0)), correct_total, attempts)
	var streak := mini(_count_or(saved.get("streak", 0)), correct)
	return {
		"attempts": attempts,
		"correct": correct,
		"by_diff": by,
		"correct_by_diff": correct_by,
		"streak": streak,
		"best_streak": maxi(streak, _count_or(saved.get("best_streak", 0))),
	}


func _four_counts(value: Variant) -> Array[int]:
	var result: Array[int] = [0, 0, 0, 0]
	if typeof(value) != TYPE_ARRAY:
		return result
	for i in range(mini(4, value.size())):
		result[i] = _count_or(value[i])
	return result


func _count_or(value: Variant) -> int:
	if typeof(value) in [TYPE_INT, TYPE_FLOAT]:
		return maxi(0, int(value))
	return 0
