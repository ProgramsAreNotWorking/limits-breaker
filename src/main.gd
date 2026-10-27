extends Control
## Router de pantallas.

const MenuScreen := preload("res://src/ui/main_menu.gd")
const CombatScreen := preload("res://src/ui/combat_screen.gd")
const BlacksmithScreen := preload("res://src/ui/blacksmith_screen.gd")
const AngelScreen := preload("res://src/ui/angel_screen.gd")
const DeathScreen := preload("res://src/ui/death_screen.gd")
const VictoryScreen := preload("res://src/ui/victory_screen.gd")
const MasteryScreen := preload("res://src/ui/mastery_screen.gd")
const SettingsScreen := preload("res://src/ui/settings_screen.gd")

var current: Control = null
var backdrop: Backdrop


func _ready() -> void:
	backdrop = Backdrop.new()
	backdrop.add_to_group("world_backdrop")
	add_child(backdrop)
	backdrop.set_environment("menu")
	Audio.play_music("menu")
	_swap(MenuScreen.new())
	# Esperar a que el editor termine de ubicar la ventana antes de aplicar la preferencia guardada.
	await get_tree().create_timer(0.25).timeout
	Game.apply_display_settings()


func _swap(screen: Control) -> void:
	if current != null and is_instance_valid(current):
		current.hide()
		current.process_mode = Node.PROCESS_MODE_DISABLED
		current.queue_free()
	current = screen
	add_child(screen)
	screen.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	if screen.has_signal("go"):
		screen.connect("go", Callable(self, "_on_go"))


func _on_go(target: String, payload: Variant = null) -> void:
	if target == "blacksmith" or target == "angel":
		if current != null and is_instance_valid(current) and current.get_script() == CombatScreen:
			var combat_phase := String(current.get("phase"))
			var remaining_enemies := 0
			if current.has_method("living_enemy_count"):
				remaining_enemies = int(current.call("living_enemy_count"))
			elif int(current.get("enemy_hp")) > 0:
				remaining_enemies = 1
			if combat_phase != "transition" or remaining_enemies > 0:
				return
	if backdrop != null:
		match target:
			"combat":
				var encounter := int(Game.run.get("encounter", 1))
				var world := Combat.world_for_encounter(encounter)
				if encounter % 10 == 0:
					backdrop.set_world(world)
				elif encounter % 5 == 0:
					backdrop.set_environment("boss_arena")
				else:
					backdrop.set_world(world)
			"blacksmith":
				backdrop.set_environment("forge")
			"angel":
				backdrop.set_environment("angel")
			"death":
				backdrop.set_environment("death")
			"victory":
				backdrop.set_environment("boss_arena")
			_:
				backdrop.set_environment("menu")
	match target:
		"menu":
			Audio.play_music("menu")
			_swap(MenuScreen.new())
		"combat":
			_swap(CombatScreen.new())
		"blacksmith":
			_swap(BlacksmithScreen.new())
		"angel":
			_swap(AngelScreen.new())
		"death":
			_swap(DeathScreen.new())
		"victory":
			_swap(VictoryScreen.new())
		"mastery":
			_swap(MasteryScreen.new())
		"settings":
			_swap(SettingsScreen.new())
		"quit":
			get_tree().quit()
