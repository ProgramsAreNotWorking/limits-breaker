class_name CombatScreen
extends Control

const MediaManifest = preload("res://src/core/asset_manifest.gd")
const EnemyActorScript = preload("res://src/ui/enemy_battle_actor.gd")

signal go(target: String, payload: Variant)

var rng := RandomNumberGenerator.new()
var enemy: Dictionary = {}
var enemies: Array[Dictionary] = []
var enemy_hps: Array[int] = []
var enemy_max_hps: Array[int] = []
var enemy_intents: Array[Dictionary] = []
var enemy_guards: Array[int] = []
var enemy_bonus_damage: Array[int] = []
var enemy_bonus_turns: Array[int] = []
var enemy_fragile_bonus: Array[int] = []
var enemy_fragile_turns: Array[int] = []
var enemy_weak_pct: Array[int] = []
var enemy_weak_turns: Array[int] = []
var enemy_weak_applied_turn: Array[int] = []
var enemy_flux_damage: Array[int] = []
var enemy_flux_turns: Array[int] = []
var enemy_flux_applied_turn: Array[int] = []
var enemy_bleed_damage: Array[int] = []
var enemy_bleed_turns: Array[int] = []
var enemy_bleed_applied_turn: Array[int] = []
var enemy_stun_turns: Array[int] = []
var enemy_death_turns: Array[int] = []
var enemy_last_ability: Array[String] = []
var enemy_last_kind: Array[String] = []
var turn_number := 0
var player_shield := 0
var player_shield_expires_turn := 0
var player_shield_grace_eligible := false
var player_weaken_pct := 0
var player_weaken_turns := 0
var player_vulnerable_bonus := 0
var player_vulnerable_turns := 0
var enemy_actors: Array[EnemyBattleActor] = []
var selected_enemy_index := 0
var enemy_layout_portrait_size := Vector2.ZERO
var enemy_layout_actor_width := 0.0
var world: Dictionary = {}
var enemy_hp := 0
var enemy_max_hp := 1
var phase := "select"
var time_left := 0.0
var time_limit := 0.0
var problems: Array = []
var chosen: MathEngine.Problem = null
var chosen_diff := 0
var chosen_attack_id := ""
var attack_target_indices: Array[int] = []
var berserk_armed := false
var berserk_attack_active := false
var topic := ""
var pending_loot := ""
var last_message := ""
var milestone_victory := false
var equipment_icons: Array[EquipmentIcon] = []
var equipment_item_labels: Array[Label] = []

const EQUIPMENT_SLOTS: Array[String] = ["weapon", "armor", "relic"]
const EQUIPMENT_SLOT_LABELS := {
	"weapon": "Arma",
	"armor": "Armadura",
	"relic": "Reliquia",
}

var phase_box: VBoxContainer
var phase_content: VBoxContainer
var phase_footer: HBoxContainer
var timer_label: Label
var timer_bar: ProgressBar
var encounter_label: Label
var stats_label: Label
var level_label: Label
var status_label: Label
var phase_scroll: ScrollContainer
var player_hp_bar: ProgressBar
var player_hp_label: Label
var enemy_hp_bar: ProgressBar
var enemy_hp_label: Label
var input: LineEdit
var overlay: Control = null
var player_portrait: FantasyPortrait
var enemy_portrait: FantasyPortrait
var mid: HBoxContainer
var phase_panel: PanelContainer
var focus_bar: PanelContainer
var focus_player_portrait: FantasyPortrait
var focus_enemy_portrait: FantasyPortrait
var focus_player_label: Label
var focus_enemy_label: Label
var focus_player_bar: ProgressBar
var focus_enemy_bar: ProgressBar
var enemy_actor_grid: GridContainer
var enemy_formation_margin: MarginContainer
var player_battle_hud: PanelContainer
var enemy_count_label: Label
var selected_target_label: Label
var berserk_button: Button
var berserk_meter: ProgressBar
var vfx: CombatVFX


func _ready() -> void:
	rng.seed = int(Time.get_unix_time_from_system() * 1000.0) ^ (Game.run.get("encounter", 1) * 7919)
	var encounter := int(Game.run.get("encounter", 1))
	world = Combat.world_for_encounter(encounter)
	enemies = Combat.enemy_group_for_encounter(encounter, rng)
	if enemies.size() > Combat.MAX_ENEMIES_PER_ENCOUNTER:
		enemies.resize(Combat.MAX_ENEMIES_PER_ENCOUNTER)
	for data in enemies:
		var maximum := maxi(1, int(data.get("hp", 1)))
		enemy_max_hps.append(maximum)
		enemy_hps.append(maximum)
		enemy_intents.append({})
		enemy_guards.append(0)
		enemy_bonus_damage.append(0)
		enemy_bonus_turns.append(0)
		enemy_fragile_bonus.append(0)
		enemy_fragile_turns.append(0)
		enemy_weak_pct.append(0)
		enemy_weak_turns.append(0)
		enemy_weak_applied_turn.append(-1)
		enemy_flux_damage.append(0)
		enemy_flux_turns.append(0)
		enemy_flux_applied_turn.append(-1)
		enemy_bleed_damage.append(0)
		enemy_bleed_turns.append(0)
		enemy_bleed_applied_turn.append(-1)
		enemy_stun_turns.append(0)
		enemy_death_turns.append(-1)
		enemy_last_ability.append("")
		enemy_last_kind.append("")
	selected_enemy_index = 0
	_sync_selected_enemy()
	var boss_encounter := _contains_tier("boss") or _contains_tier("miniboss")
	Audio.play_music("boss" if boss_encounter else "combat")
	if boss_encounter:
		Audio.play_sfx("boss")
	_build()
	vfx = CombatVFX.new()
	vfx.z_index = 5
	add_child(vfx)
	_begin_turn()


func _process(delta: float) -> void:
	if overlay != null and is_instance_valid(overlay):
		return
	if phase != "select":
		return
	time_left -= delta
	if timer_label != null and is_instance_valid(timer_label):
		timer_label.text = "Tiempo para elegir: %.1f s" % maxf(0.0, time_left)
	if timer_bar != null and is_instance_valid(timer_bar):
		timer_bar.value = maxf(0.0, time_left)
	if time_left <= 0.0:
		_on_timeout()


# ------------------------------------------------------------------- layout

func _build() -> void:
	var margin := MarginContainer.new()
	margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	margin.add_theme_constant_override("margin_left", 18)
	margin.add_theme_constant_override("margin_right", 18)
	margin.add_theme_constant_override("margin_top", 14)
	margin.add_theme_constant_override("margin_bottom", 14)
	add_child(margin)

	var root := UIKit.vbox(7)
	root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	margin.add_child(root)

	# --- barra superior: una sola pieza de información, sin texto flotando.
	var top_panel := UIKit.panel(Color(0.045, 0.055, 0.07, 0.94), Color("#353e4a"), true, UIKit.GOLD_SOFT)
	top_panel.custom_minimum_size = Vector2(0, 58)
	top_panel.z_index = 20
	root.add_child(top_panel)
	var top := UIKit.hbox(14)
	top_panel.add_child(top)
	var top_identity := UIKit.vbox(0)
	top_identity.custom_minimum_size = Vector2(190, 0)
	top.add_child(top_identity)
	top_identity.add_child(UIKit.eyebrow("Mundo %d · %s" % [
		int(world.get("index", 1)),
		String(world.get("short", "Pasillo")),
	], _world_accent()))
	encounter_label = UIKit.display_label("Encuentro %d" % int(Game.run.get("encounter", 1)), 20, UIKit.GOLD, 600, 0)
	encounter_label.name = "Encounter"
	encounter_label.custom_minimum_size = Vector2(170, 25)
	encounter_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	top_identity.add_child(encounter_label)
	var spacer := Control.new()
	spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(spacer)
	var stats_box := UIKit.vbox(1)
	stats_box.alignment = BoxContainer.ALIGNMENT_CENTER
	level_label = UIKit.eyebrow("Nivel %d · XP %d/%d" % [Game.player_level(), int(Game.run.get("xp", 0)), Game.xp_to_next_level()], UIKit.GOLD_SOFT)
	level_label.name = "RunLevel"
	level_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	stats_box.add_child(level_label)
	stats_label = UIKit.label(_progress_text(), 12, UIKit.STEEL)
	stats_label.name = "Stats"
	stats_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	stats_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	stats_label.custom_minimum_size = Vector2(360, 17)
	stats_box.add_child(stats_label)
	top.add_child(stats_box)
	var menu_btn := UIKit.button("Menú", UIKit.STEEL_DARK)
	menu_btn.custom_minimum_size = Vector2(92, 36)
	menu_btn.add_theme_font_size_override("font_size", 14)
	menu_btn.pressed.connect(_show_system_menu)
	top.add_child(menu_btn)
	var inv_btn := UIKit.button("Inventario", UIKit.STEEL_DARK)
	inv_btn.custom_minimum_size = Vector2(126, 36)
	inv_btn.add_theme_font_size_override("font_size", 14)
	inv_btn.pressed.connect(_show_inventory)
	top.add_child(inv_btn)

	# --- franja compacta para resolver: conserva los retratos y la vida visibles.
	focus_bar = UIKit.panel(Color(0.045, 0.055, 0.07, 0.95), Color("#353e4a"), false, UIKit.STEEL_DARK)
	focus_bar.visible = false
	focus_bar.custom_minimum_size = Vector2(0, 80)
	focus_bar.z_index = 20
	root.add_child(focus_bar)
	var fh := UIKit.hbox(12)
	focus_bar.add_child(fh)
	focus_player_portrait = UIKit.add_portrait(fh, MediaManifest.character("player"), Vector2(58, 58))
	var fp := UIKit.vbox(4)
	fp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fh.add_child(fp)
	focus_player_label = UIKit.inline_label("", 13, UIKit.OK, 500)
	fp.add_child(focus_player_label)
	focus_player_bar = UIKit.bar(100, 100, UIKit.OK, 10)
	fp.add_child(focus_player_bar)
	var versus := UIKit.display_label("VS", 14, UIKit.GOLD_SOFT, 600, 0)
	versus.custom_minimum_size = Vector2(30, 0)
	versus.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	versus.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	fh.add_child(versus)
	var fe := UIKit.vbox(4)
	fe.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	fh.add_child(fe)
	focus_enemy_label = UIKit.inline_label("", 13, UIKit.DANGER, 500)
	focus_enemy_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	fe.add_child(focus_enemy_label)
	focus_enemy_bar = UIKit.bar(1, 1, _tier_color(String(enemy.get("tier", ""))), 10)
	fe.add_child(focus_enemy_bar)
	focus_enemy_portrait = UIKit.add_portrait(fh, MediaManifest.enemy(String(enemy.get("id", ""))), Vector2(58, 58))
	_apply_enemy_tint(focus_enemy_portrait)

	# --- escenario amplio: los enemigos recortados quedan sobre el fondo del mundo.
	mid = UIKit.hbox(14)
	mid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	mid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	root.add_child(mid)
	var stage_root := Control.new()
	stage_root.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	stage_root.size_flags_vertical = Control.SIZE_EXPAND_FILL
	mid.add_child(stage_root)

	var ep := UIKit.panel(Color(0.02, 0.025, 0.035, 0.12), Color.TRANSPARENT, false, _tier_color(String(enemy.get("tier", ""))))
	ep.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	stage_root.add_child(ep)
	var stage_style := ep.get_theme_stylebox("panel") as StyleBoxFlat
	if stage_style != null:
		stage_style.content_margin_left = 7
		stage_style.content_margin_right = 7
		stage_style.content_margin_top = 5
		stage_style.content_margin_bottom = 4
		stage_style.shadow_size = 0
	var ev := UIKit.vbox(5)
	ep.add_child(ev)
	var enemy_top := UIKit.hbox(8)
	ev.add_child(enemy_top)
	enemy_top.add_child(UIKit.eyebrow("ENEMIGOS EN ESCENA", UIKit.DANGER))
	selected_target_label = UIKit.inline_label("", 10, UIKit.STEEL, 500)
	selected_target_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	selected_target_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	selected_target_label.autowrap_mode = TextServer.AUTOWRAP_OFF
	enemy_top.add_child(selected_target_label)
	enemy_count_label = UIKit.inline_label("", 11, UIKit.STEEL, 500)
	enemy_top.add_child(enemy_count_label)
	var boss_hp_row := UIKit.hbox(8)
	ev.add_child(boss_hp_row)
	var boss_hp_title := UIKit.eyebrow("Vitalidad del jefe", UIKit.STEEL_DARK)
	boss_hp_row.add_child(boss_hp_title)
	var boss_hp_spacer := Control.new()
	boss_hp_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	boss_hp_row.add_child(boss_hp_spacer)
	enemy_hp_label = UIKit.inline_label("", 12, UIKit.DANGER, 500)
	boss_hp_row.add_child(enemy_hp_label)
	enemy_hp_bar = UIKit.bar(enemy_max_hp, enemy_max_hp, _tier_color(String(enemy.get("tier", ""))), 9)
	ev.add_child(enemy_hp_bar)
	var enemy_group_center := VBoxContainer.new()
	enemy_group_center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	enemy_group_center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	enemy_group_center.alignment = BoxContainer.ALIGNMENT_BEGIN
	enemy_group_center.mouse_filter = Control.MOUSE_FILTER_IGNORE
	ev.add_child(enemy_group_center)
	enemy_formation_margin = MarginContainer.new()
	enemy_formation_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	enemy_formation_margin.add_theme_constant_override("margin_left", 0)
	enemy_group_center.add_child(enemy_formation_margin)
	enemy_actor_grid = GridContainer.new()
	enemy_actor_grid.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	enemy_actor_grid.size_flags_vertical = Control.SIZE_SHRINK_BEGIN
	enemy_actor_grid.add_theme_constant_override("h_separation", 7)
	enemy_actor_grid.add_theme_constant_override("v_separation", 4)
	enemy_formation_margin.add_child(enemy_actor_grid)
	_rebuild_enemy_actors()

	player_battle_hud = UIKit.panel(Color(0.045, 0.055, 0.07, 0.9), Color("#353e4a"), false, UIKit.GOLD_SOFT)
	player_battle_hud.name = "PlayerBattleHUD"
	player_battle_hud.anchor_left = 0.0
	player_battle_hud.anchor_top = 1.0
	player_battle_hud.anchor_right = 0.0
	player_battle_hud.anchor_bottom = 1.0
	player_battle_hud.offset_left = 12.0
	player_battle_hud.offset_top = -74.0
	player_battle_hud.offset_right = 384.0
	player_battle_hud.offset_bottom = -8.0
	player_battle_hud.z_index = 12
	stage_root.add_child(player_battle_hud)
	var player_status := UIKit.hbox(7)
	player_status.custom_minimum_size = Vector2(310, 0)
	player_battle_hud.add_child(player_status)
	player_portrait = UIKit.add_portrait(player_status, MediaManifest.character("player"), Vector2(38, 38))
	var player_vitals := UIKit.vbox(2)
	player_vitals.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	player_status.add_child(player_vitals)
	var vitals_heading := UIKit.hbox(5)
	player_vitals.add_child(vitals_heading)
	vitals_heading.add_child(UIKit.eyebrow("Vitalidad", UIKit.STEEL_DARK))
	var vitals_spacer := Control.new()
	vitals_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	vitals_heading.add_child(vitals_spacer)
	player_hp_label = UIKit.inline_label("", 10, UIKit.OK, 500)
	vitals_heading.add_child(player_hp_label)
	player_hp_bar = UIKit.bar(100, 100, UIKit.OK, 7)
	player_vitals.add_child(player_hp_bar)
	var player_stats := UIKit.inline_label("Ataque: %d · Defensa: %d" % [Game.attack_damage(1), Game.defense()], 9, UIKit.STEEL)
	player_stats.name = "PlayerStats"
	player_vitals.add_child(player_stats)
	status_label = UIKit.inline_label("", 9, UIKit.VIOLET, 600)
	status_label.name = "PlayerStatus"
	status_label.visible = false
	player_vitals.add_child(status_label)
	var gear_strip := UIKit.hbox(2)
	gear_strip.custom_minimum_size = Vector2(78, 0)
	gear_strip.alignment = BoxContainer.ALIGNMENT_CENTER
	player_status.add_child(gear_strip)
	var equipped: Dictionary = Game.run.get("equipped", {})
	for slot in EQUIPMENT_SLOTS:
		var item_id := String(equipped.get(slot, ""))
		var icon := UIKit.add_item_icon(gear_strip, item_id, Vector2(22, 22), _item_tint(item_id))
		icon.tooltip_text = "%s · %s" % [String(EQUIPMENT_SLOT_LABELS[slot]), _equipment_name(item_id)]
		equipment_icons.append(icon)
	_set_subtree_mouse_passthrough(player_battle_hud)
	_sync_selected_enemy()
	resized.connect(_schedule_enemy_formation_fit)
	call_deferred("_fit_enemy_formation")

	# --- zona de interacción: siempre enmarcada, nunca texto suelto sobre el fondo.
	phase_panel = UIKit.panel(Color(0.055, 0.065, 0.08, 0.95), Color("#343d49"), true, UIKit.GOLD_SOFT)
	phase_panel.custom_minimum_size = Vector2(0, 250)
	phase_panel.size_flags_vertical = Control.SIZE_SHRINK_END
	var phase_style := phase_panel.get_theme_stylebox("panel") as StyleBoxFlat
	if phase_style != null:
		phase_style.content_margin_left = 8
		phase_style.content_margin_right = 8
		phase_style.content_margin_top = 5
		phase_style.content_margin_bottom = 5
	root.add_child(phase_panel)
	phase_content = UIKit.vbox(4)
	phase_content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	phase_content.size_flags_vertical = Control.SIZE_EXPAND_FILL
	phase_panel.add_child(phase_content)
	phase_scroll = ScrollContainer.new()
	phase_scroll.custom_minimum_size = Vector2(0, 0)
	phase_scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	phase_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	phase_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	phase_content.add_child(phase_scroll)
	var phase_margin := MarginContainer.new()
	phase_margin.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	phase_margin.size_flags_vertical = Control.SIZE_EXPAND_FILL
	phase_margin.add_theme_constant_override("margin_left", 20)
	phase_margin.add_theme_constant_override("margin_right", 20)
	phase_margin.add_theme_constant_override("margin_top", 8)
	phase_margin.add_theme_constant_override("margin_bottom", 8)
	phase_scroll.add_child(phase_margin)
	phase_box = UIKit.vbox(5)
	phase_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	phase_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
	phase_box.alignment = BoxContainer.ALIGNMENT_CENTER
	phase_margin.add_child(phase_box)
	phase_footer = UIKit.hbox(10)
	phase_footer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	phase_footer.custom_minimum_size = Vector2(0, 44)
	phase_footer.alignment = BoxContainer.ALIGNMENT_END
	phase_footer.visible = false
	phase_content.add_child(phase_footer)
	_refresh_hud()
	_set_combat_backdrop()


func _rebuild_enemy_actors() -> void:
	if enemy_actor_grid == null or not is_instance_valid(enemy_actor_grid):
		return
	for child in enemy_actor_grid.get_children():
		enemy_actor_grid.remove_child(child)
		child.queue_free()
	enemy_actors.clear()
	enemy_actor_grid.columns = maxi(1, enemies.size())
	var portrait_size := _enemy_portrait_size(maxi(1, enemies.size()))
	for i in range(enemies.size()):
		var actor := EnemyActorScript.new() as EnemyBattleActor
		actor.custom_minimum_size = Vector2(_enemy_actor_width(maxi(1, enemies.size())), _enemy_actor_height(maxi(1, enemies.size())))
		actor.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
		actor.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		actor.configure(
			i, enemies[i], enemy_hps[i], enemy_max_hps[i],
			_enemy_intent_text(i), i == selected_enemy_index, portrait_size,
			_enemy_intent_color(i), _enemy_status_text(i), _enemy_status_color(i)
		)
		actor.pressed.connect(_select_target.bind(i))
		enemy_actors.append(actor)
		var actor_slot := CenterContainer.new()
		actor_slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		actor_slot.size_flags_vertical = Control.SIZE_EXPAND_FILL
		actor_slot.mouse_filter = Control.MOUSE_FILTER_IGNORE
		enemy_actor_grid.add_child(actor_slot)
		actor_slot.add_child(actor)
	if phase_panel != null and is_instance_valid(phase_panel):
		_schedule_enemy_formation_fit()


func _progress_text() -> String:
	return "%d derrotados  ·  %d/%d aciertos" % [
		int(Game.run["stats"].get("enemies", 0)),
		int(Game.run["stats"].get("solved", 0)),
		int(Game.run["stats"].get("problems", 0)),
	]


func _equipment_name(item_id: String) -> String:
	if item_id == "":
		return "Vacío"
	return String(Combat.item(item_id).get("name", item_id))


func _enemy_portrait_size(enemy_count: int) -> Vector2:
	if enemy_count == 1 and (_contains_tier("boss") or _contains_tier("miniboss")):
		return Vector2(322, 322)
	match enemy_count:
		1:
			return Vector2(286, 286)
		2:
			return Vector2(264, 264)
		3:
			return Vector2(226, 226)
		_:
			return Vector2(202, 202)


func _enemy_actor_width(enemy_count: int) -> float:
	match enemy_count:
		1:
			return 420.0
		2:
			return 360.0
		3:
			return 292.0
		_:
			return 248.0


func _enemy_actor_height(enemy_count: int) -> float:
	# La franja inferior reserva una línea para Debilidad, Sangrado, Flujo de
	# magia o Mutilación, aunque el enemigo no tenga estados activos.
	if enemy_count == 1 and (_contains_tier("boss") or _contains_tier("miniboss")):
		return 377.0
	match enemy_count:
		1:
			return 349.0
		2:
			return 337.0
		3:
			return 319.0
		_:
			return 305.0


func _schedule_enemy_formation_fit() -> void:
	call_deferred("_fit_enemy_formation_after_layout")


func _fit_enemy_formation_after_layout() -> void:
	# El panel cambia de alto en el mismo frame en que se renderiza la fase.
	# Espera a que el contenedor recalcule su posición antes de ajustar actores.
	await get_tree().process_frame
	await get_tree().process_frame
	_fit_enemy_formation()


func _fit_enemy_formation() -> void:
	if enemy_actor_grid == null or not is_instance_valid(enemy_actor_grid) or enemy_actors.is_empty():
		return
	if enemy_formation_margin == null or not is_instance_valid(enemy_formation_margin):
		return
	var formation_area := enemy_formation_margin.get_parent() as Control
	if formation_area == null or formation_area.size.x <= 0.0 or formation_area.size.y <= 0.0:
		return
	if phase_panel == null or not is_instance_valid(phase_panel):
		return

	var enemy_count := maxi(1, enemies.size())
	var base_portrait_size := _enemy_portrait_size(enemy_count)
	var base_actor_height := _enemy_actor_height(enemy_count)
	var base_actor_width := _enemy_actor_width(enemy_count)
	var actor_chrome_height := maxf(0.0, base_actor_height - base_portrait_size.y)
	var available_actor_bottom := phase_panel.global_position.y - 8.0
	var available_actor_height := maxf(72.0, available_actor_bottom - formation_area.global_position.y)
	var fitted_actor_height := minf(base_actor_height, available_actor_height)
	var fitted_portrait_height := clampf(fitted_actor_height - actor_chrome_height, 24.0, base_portrait_size.y)
	var hud_clearance := 0.0
	if enemy_count > 1 and player_battle_hud != null and is_instance_valid(player_battle_hud):
		hud_clearance = maxf(0.0, player_battle_hud.get_global_rect().end.x - formation_area.global_position.x + 8.0)
	enemy_formation_margin.add_theme_constant_override("margin_left", int(round(hud_clearance)))
	var available_actor_width := maxf(96.0, (formation_area.size.x - hud_clearance - 8.0 - 7.0 * float(enemy_count - 1)) / float(enemy_count))
	var fitted_actor_width := minf(base_actor_width, available_actor_width)
	var portrait_scale := minf(fitted_portrait_height / base_portrait_size.y, fitted_actor_width / base_actor_width)
	enemy_layout_portrait_size = base_portrait_size * clampf(portrait_scale, 0.1, 1.0)
	enemy_layout_actor_width = fitted_actor_width
	fitted_actor_height = minf(fitted_actor_height, enemy_layout_portrait_size.y + actor_chrome_height)
	for i in range(enemy_actors.size()):
		var actor := enemy_actors[i]
		actor.custom_minimum_size = Vector2(enemy_layout_actor_width, fitted_actor_height)
		actor.configure(
			i,
			enemies[i],
			enemy_hps[i],
			enemy_max_hps[i],
			_enemy_intent_text(i),
			i == selected_enemy_index,
			enemy_layout_portrait_size,
			_enemy_intent_color(i),
			_enemy_status_text(i),
			_enemy_status_color(i)
		)


func _set_combat_backdrop() -> void:
	for node in get_tree().get_nodes_in_group("world_backdrop"):
		if node is Backdrop:
			node.set_artwork_opacity(0.94)
			node.set_artwork_readability(1.18, 0.025, 1.08)


func _set_subtree_mouse_passthrough(node: Node) -> void:
	if node is Control:
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
	for child in node.get_children():
		_set_subtree_mouse_passthrough(child)


func _item_tint(item_id: String) -> String:
	return Combat.item_tint(item_id)


func _world_accent() -> Color:
	var hex := String(world.get("accent", ""))
	return Color(hex) if hex != "" else UIKit.VIOLET


func _apply_enemy_tint(portrait: Control) -> void:
	if portrait == null:
		return
	var tint := Combat.enemy_tint(enemy)
	portrait.modulate = Color(tint) if tint != "" else Color.WHITE


func _tier_color(tier: String) -> Color:
	match tier:
		"weak":
			return Color("#7f9a6a")
		"ordinary":
			return Color("#8a94a6")
		"strong":
			return Color("#b08a4e")
		"elite":
			return Color("#a3455c")
		"miniboss":
			return UIKit.VIOLET
		_:
			return UIKit.BURGUNDY_HI


func _active_player_portrait() -> Control:
	if focus_bar != null and focus_bar.visible:
		return focus_player_portrait
	return player_portrait


func _active_enemy_portrait() -> Control:
	if selected_enemy_index >= 0 and selected_enemy_index < enemy_actors.size():
		return enemy_actors[selected_enemy_index].portrait
	return enemy_portrait


func _portrait_center(portrait: Control) -> Vector2:
	if vfx == null or portrait == null or not is_instance_valid(portrait):
		return size * 0.5
	return vfx.get_global_transform().affine_inverse() * portrait.get_global_rect().get_center()


func _contains_tier(tier: String) -> bool:
	for data in enemies:
		if String(data.get("tier", "")) == tier:
			return true
	return false


func _ingest_legacy_target_state() -> void:
	if enemies.is_empty() or selected_enemy_index < 0 or selected_enemy_index >= enemies.size() or enemy.is_empty():
		return
	var stored_id := String(enemies[selected_enemy_index].get("id", ""))
	var legacy_id := String(enemy.get("id", ""))
	if legacy_id != stored_id or enemy_hp != enemy_hps[selected_enemy_index] or enemy_max_hp != enemy_max_hps[selected_enemy_index]:
		enemies[selected_enemy_index] = enemy.duplicate(true)
		enemy_hps[selected_enemy_index] = maxi(0, enemy_hp)
		enemy_max_hps[selected_enemy_index] = maxi(1, enemy_max_hp)


func _sync_selected_enemy() -> void:
	if enemies.is_empty():
		enemy = {}
		enemy_hp = 0
		enemy_max_hp = 1
		enemy_portrait = null
		return
	selected_enemy_index = clampi(selected_enemy_index, 0, enemies.size() - 1)
	enemy = enemies[selected_enemy_index]
	enemy_hp = enemy_hps[selected_enemy_index]
	enemy_max_hp = enemy_max_hps[selected_enemy_index]
	if selected_enemy_index < enemy_actors.size():
		enemy_portrait = enemy_actors[selected_enemy_index].portrait
		focus_enemy_portrait = enemy_portrait


func _living_enemy_indices() -> Array[int]:
	var alive: Array[int] = []
	for i in range(enemy_hps.size()):
		if enemy_hps[i] > 0:
			alive.append(i)
	return alive


func _remove_enemy_at(index: int) -> void:
	if index < 0 or index >= enemies.size():
		return
	enemies.remove_at(index)
	enemy_hps.remove_at(index)
	enemy_max_hps.remove_at(index)
	enemy_intents.remove_at(index)
	enemy_guards.remove_at(index)
	enemy_bonus_damage.remove_at(index)
	enemy_bonus_turns.remove_at(index)
	enemy_fragile_bonus.remove_at(index)
	enemy_fragile_turns.remove_at(index)
	enemy_weak_pct.remove_at(index)
	enemy_weak_turns.remove_at(index)
	enemy_weak_applied_turn.remove_at(index)
	enemy_flux_damage.remove_at(index)
	enemy_flux_turns.remove_at(index)
	enemy_flux_applied_turn.remove_at(index)
	enemy_bleed_damage.remove_at(index)
	enemy_bleed_turns.remove_at(index)
	enemy_bleed_applied_turn.remove_at(index)
	enemy_stun_turns.remove_at(index)
	enemy_death_turns.remove_at(index)
	enemy_last_ability.remove_at(index)
	enemy_last_kind.remove_at(index)


func _purge_expired_enemy_corpses() -> void:
	# Los derrotados permanecen en escena durante el turno de su muerte y los
	# dos turnos siguientes; al comenzar el tercer turno posterior se retiran.
	var expired: Array[int] = []
	for i in range(mini(enemies.size(), enemy_death_turns.size())):
		if enemy_hps[i] <= 0 and enemy_death_turns[i] >= 0 and turn_number - enemy_death_turns[i] >= 3:
			expired.append(i)
	if expired.is_empty():
		return
	var selected := selected_enemy_index
	for idx in range(expired.size() - 1, -1, -1):
		var index := expired[idx]
		if selected == index:
			selected = -1
		elif index < selected:
			selected -= 1
		_remove_enemy_at(index)
	selected_enemy_index = selected
	var alive := _living_enemy_indices()
	if selected_enemy_index < 0 or selected_enemy_index >= enemy_hps.size() or enemy_hps[selected_enemy_index] <= 0:
		selected_enemy_index = alive[0] if not alive.is_empty() else 0
	attack_target_indices.clear()
	_rebuild_enemy_actors()
	_sync_selected_enemy()
	_refresh_battlefield()


func living_enemy_count() -> int:
	_ingest_legacy_target_state()
	return _living_enemy_indices().size()


func _choose_enemy_intents() -> void:
	while enemy_death_turns.size() < enemies.size():
		enemy_death_turns.append(-1)
	for i in range(enemies.size()):
		if i >= enemy_intents.size():
			enemy_intents.append({})
			enemy_guards.append(0)
			enemy_bonus_damage.append(0)
			enemy_bonus_turns.append(0)
			enemy_fragile_bonus.append(0)
			enemy_fragile_turns.append(0)
			enemy_weak_pct.append(0)
			enemy_weak_turns.append(0)
			enemy_weak_applied_turn.append(-1)
			enemy_flux_damage.append(0)
			enemy_flux_turns.append(0)
			enemy_flux_applied_turn.append(-1)
			enemy_bleed_damage.append(0)
			enemy_bleed_turns.append(0)
			enemy_bleed_applied_turn.append(-1)
			enemy_stun_turns.append(0)
			enemy_last_ability.append("")
			enemy_last_kind.append("")
		if enemy_hps[i] <= 0:
			enemy_intents[i] = {}
			continue
		var ability: Dictionary
		if turn_number <= 1:
			ability = Combat.enemy_basic_attack(enemies[i])
		else:
			ability = Combat.choose_enemy_ability(enemies[i], rng, enemy_last_ability[i], enemy_last_kind[i])
		if String(ability.get("kind", "")) == "summon" and enemies.size() >= Combat.MAX_ENEMIES_PER_ENCOUNTER:
			ability = Combat.enemy_basic_attack(enemies[i])
		enemy_intents[i] = ability
		enemy_last_ability[i] = String(ability.get("name", ""))
		enemy_last_kind[i] = String(ability.get("kind", "attack"))
		if String(ability.get("kind", "")) == "defend":
			enemy_guards[i] = maxi(enemy_guards[i], int(ability.get("value", 0)))


func _enemy_intent_for(index: int) -> Dictionary:
	if index >= 0 and index < enemy_intents.size() and not enemy_intents[index].is_empty():
		return enemy_intents[index]
	if index >= 0 and index < enemies.size():
		return Combat.enemy_basic_attack(enemies[index])
	return {}


func _enemy_attack_damage(index: int, ability: Dictionary, bonus: int = 0) -> int:
	var damage := Game.enemy_ability_damage(ability, maxi(1, _living_enemy_indices().size()), bonus, player_vulnerable_bonus)
	return _weakened_enemy_damage(index, damage)


func _weakened_enemy_damage(index: int, damage: int) -> int:
	if index < 0 or index >= enemy_weak_turns.size():
		return damage
	if enemy_weak_turns[index] <= 0:
		return damage
	if index < enemy_weak_applied_turn.size() and enemy_weak_applied_turn[index] == turn_number:
		# La Debilidad recién aplicada empieza a contar en el turno siguiente.
		return damage
	var pct := enemy_weak_pct[index] if index < enemy_weak_pct.size() else 0
	if pct <= 0:
		return damage
	return maxi(1, int(roundf(float(damage) * (1.0 - float(pct) / 100.0))))


func _enemy_intent_text(index: int) -> String:
	if index < 0 or index >= enemies.size() or enemy_hps[index] <= 0:
		return "Derrotado"
	if index < enemy_stun_turns.size() and enemy_stun_turns[index] > 0:
		return "Mutilado · pierde el turno"
	var ability := _enemy_intent_for(index)
	var kind := String(ability.get("kind", "attack"))
	var damage := 0
	if kind == "attack":
		var bonus := enemy_bonus_damage[index] if index < enemy_bonus_damage.size() else 0
		damage = _enemy_attack_damage(index, ability, bonus)
	var text := Combat.ability_intent_text(ability, damage)
	var guard := enemy_guards[index] if index < enemy_guards.size() else 0
	if kind == "defend":
		text = "%s · %d" % [String(ability.get("name", "Guardia")), guard]
	elif guard > 0:
		text = "Guardia %d · %s" % [guard, text]
	return "%s · %s" % [Combat.ability_indicator(ability), text]


func _enemy_intent_short_text(index: int) -> String:
	if index < 0 or index >= enemies.size() or enemy_hps[index] <= 0:
		return "Derrotado"
	if index < enemy_stun_turns.size() and enemy_stun_turns[index] > 0:
		return "Mutilado · pierde el turno"
	var ability := _enemy_intent_for(index)
	var kind := String(ability.get("kind", "attack"))
	var indicator := Combat.ability_indicator(ability)
	match kind:
		"attack":
			var bonus := enemy_bonus_damage[index] if index < enemy_bonus_damage.size() else 0
			var damage := _enemy_attack_damage(index, ability, bonus)
			var hits := maxi(1, int(ability.get("hits", 1)))
			if hits > 1:
				return "%s %d×%d" % [indicator, hits, damage]
			return "%s %d" % [indicator, damage]
		"defend":
			var guard := enemy_guards[index] if index < enemy_guards.size() else int(ability.get("value", 0))
			return "%s %d" % [indicator, guard]
		"heal":
			return "%s +%d HP" % [indicator, int(ability.get("value", 0))]
		"buff":
			return "%s +%d" % [indicator, int(ability.get("value", 0))]
		"debuff":
			return "%s −%d%%" % [indicator, int(ability.get("value", 0))]
		"summon":
			return indicator
		"idle":
			return "Se incorpora"
	return indicator


func _render_enemy_intent_strip() -> Control:
	var row := UIKit.hbox(8)
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(UIKit.eyebrow("ACCIONES ENEMIGAS", UIKit.DANGER))
	for index in _living_enemy_indices():
		var enemy_name := String(enemies[index].get("name", "Enemigo"))
		if enemy_name.length() > 17:
			enemy_name = enemy_name.substr(0, 16) + "…"
		var chip := UIKit.inline_label("%s · %s" % [enemy_name, _enemy_intent_short_text(index)], 10, _enemy_intent_color(index), 500)
		chip.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		chip.clip_text = true
		chip.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		chip.tooltip_text = _enemy_intent_text(index)
		row.add_child(chip)
	return row


func _enemy_intent_color(index: int) -> Color:
	var kind := String(_enemy_intent_for(index).get("kind", "attack"))
	match kind:
		"attack":
			return Color("#e08a70")
		"defend":
			return Color("#8ab7d4")
		"heal":
			return UIKit.OK
		"buff":
			return UIKit.GOLD
		"debuff":
			return UIKit.VIOLET
		"summon":
			return Color("#df6179")
		"idle":
			return UIKit.STEEL_DARK
	return UIKit.STEEL


func _enemy_tooltip(index: int) -> String:
	if index < 0 or index >= enemies.size():
		return ""
	var data: Dictionary = enemies[index]
	var ability := _enemy_intent_for(index)
	var lines: Array[String] = [String(data.get("name", "Enemigo"))]
	lines.append("Cuerpo: %s" % Combat.enemy_type_label(data))
	if Combat.is_magic_flux_immune(data):
		lines.append("Inmune a flujo de magia")
	if not Combat.is_living_enemy(data):
		lines.append("No sangra")
	if not ability.is_empty():
		lines.append("Acción: %s" % Combat.ability_indicator(ability))
		lines.append("Intención: %s" % String(ability.get("name", "")))
		lines.append(Combat.ability_effect_text(ability))
	lines.append("HP %d / %d · Armadura %d · Resistencia mágica %d" % [
		enemy_hps[index], enemy_max_hps[index],
		int(data.get("armor", 0)), int(data.get("magic_resist", 0)),
	])
	var weaknesses: Dictionary = data.get("weaknesses", {})
	var weak_parts: Array[String] = []
	for damage_kind in weaknesses:
		if float(weaknesses[damage_kind]) > 1.01:
			weak_parts.append("%s ×%.2f" % ["física" if damage_kind == "physical" else "mágica", float(weaknesses[damage_kind])])
	if not weak_parts.is_empty():
		lines.append("Débil a: " + ", ".join(weak_parts))
	if index < enemy_guards.size() and enemy_guards[index] > 0:
		lines.append("Guardia: %d" % enemy_guards[index])
	if index < enemy_bonus_damage.size() and enemy_bonus_damage[index] > 0:
		lines.append("Furia: +%d de daño (%d turnos)" % [enemy_bonus_damage[index], enemy_bonus_turns[index]])
	if index < enemy_fragile_turns.size() and enemy_fragile_turns[index] > 0:
		lines.append("Frágil: +%d de daño recibido (%d turnos)" % [enemy_fragile_bonus[index], enemy_fragile_turns[index]])
	if index < enemy_weak_turns.size() and enemy_weak_turns[index] > 0:
		lines.append("Debilidad: −%d%% de daño enemigo (%d turnos)" % [enemy_weak_pct[index], enemy_weak_turns[index]])
	if index < enemy_flux_turns.size() and enemy_flux_turns[index] > 0:
		lines.append("Flujo de magia: %d de daño por turno (%d turnos)" % [enemy_flux_damage[index], enemy_flux_turns[index]])
	if index < enemy_bleed_turns.size() and enemy_bleed_turns[index] > 0:
		lines.append("Sangrado: %d de daño por turno (%d turnos)" % [enemy_bleed_damage[index], enemy_bleed_turns[index]])
	if index < enemy_stun_turns.size() and enemy_stun_turns[index] > 0:
		lines.append("Mutilación: pierde el siguiente turno")
	return "\n".join(lines)


func _enemy_status_text(index: int) -> String:
	var parts: Array[String] = []
	if index < enemy_stun_turns.size() and enemy_stun_turns[index] > 0:
		parts.append("Mutilado: pierde turno")
	if index < enemy_bleed_turns.size() and enemy_bleed_turns[index] > 0:
		parts.append("Sangrado %d · %dt" % [enemy_bleed_damage[index], enemy_bleed_turns[index]])
	if index < enemy_flux_turns.size() and enemy_flux_turns[index] > 0:
		parts.append("Flujo %d · %dt" % [enemy_flux_damage[index], enemy_flux_turns[index]])
	if index < enemy_weak_turns.size() and enemy_weak_turns[index] > 0:
		parts.append("Debilidad −%d%% · %dt" % [enemy_weak_pct[index], enemy_weak_turns[index]])
	if index < enemy_fragile_turns.size() and enemy_fragile_turns[index] > 0:
		parts.append("Frágil +%d · %dt" % [enemy_fragile_bonus[index], enemy_fragile_turns[index]])
	return "  ·  ".join(parts)


func _enemy_status_color(index: int) -> Color:
	if index < enemy_stun_turns.size() and enemy_stun_turns[index] > 0:
		return UIKit.DANGER
	if index < enemy_flux_turns.size() and enemy_flux_turns[index] > 0:
		return UIKit.VIOLET
	if index < enemy_bleed_turns.size() and enemy_bleed_turns[index] > 0:
		return Color("#d97862")
	if index < enemy_weak_turns.size() and enemy_weak_turns[index] > 0:
		return Color("#d7b46a")
	return UIKit.STEEL


func _most_wounded_enemy() -> int:
	var best := -1
	var best_ratio := 2.0
	for i in range(enemies.size()):
		if enemy_hps[i] <= 0:
			continue
		var ratio := float(enemy_hps[i]) / float(maxi(1, enemy_max_hps[i]))
		if ratio < best_ratio:
			best_ratio = ratio
			best = i
	return best


func _refresh_battlefield() -> void:
	if enemies.is_empty():
		return
	var alive := _living_enemy_indices()
	var show_boss_bar := _contains_tier("boss") and alive.size() == 1
	if enemy_hp_bar != null:
		enemy_hp_bar.visible = show_boss_bar
	if enemy_hp_label != null:
		enemy_hp_label.visible = show_boss_bar
		var boss_hp_row := enemy_hp_label.get_parent() as Control
		if boss_hp_row != null:
			boss_hp_row.visible = show_boss_bar
	if enemy_count_label != null:
		enemy_count_label.text = "%d / %d VIVOS" % [alive.size(), enemies.size()]
	if selected_enemy_index >= 0 and selected_enemy_index < enemies.size():
		var selected_data: Dictionary = enemies[selected_enemy_index]
		if selected_target_label != null:
			var target_text := "Objetivo: %s" % String(selected_data.get("name", "Enemigo"))
			if chosen_attack_id != "" and Combat.is_support_attack(chosen_attack_id):
				var support_name := String(Combat.PLAYER_ATTACKS.get(chosen_attack_id, {}).get("name", "Técnica"))
				target_text = "%s · sin objetivo" % support_name
			elif phase == "select" and chosen_attack_id == "":
				target_text += " · elige una técnica para ver su efecto"
			elif not attack_target_indices.is_empty():
				target_text = "Objetivos: " + _target_names(attack_target_indices)
			selected_target_label.text = target_text
	for i in range(mini(enemy_actors.size(), enemies.size())):
		var selected := i == selected_enemy_index
		var portrait_size := enemy_layout_portrait_size if enemy_layout_portrait_size != Vector2.ZERO else _enemy_portrait_size(enemies.size())
		enemy_actors[i].configure(
			i, enemies[i], enemy_hps[i], enemy_max_hps[i],
			_enemy_intent_text(i), selected, portrait_size, _enemy_intent_color(i),
			_enemy_status_text(i), _enemy_status_color(i)
		)
		enemy_actors[i].set_selected_for_action(selected)
		enemy_actors[i].set_targetable(phase == "select")
		enemy_actors[i].tooltip_text = _enemy_tooltip(i)
	if selected_enemy_index < enemy_actors.size():
		_sync_selected_enemy()


func _refresh_hud() -> void:
	if encounter_label != null and is_instance_valid(encounter_label):
		encounter_label.text = "Encuentro %d" % int(Game.run.get("encounter", 1))
	if stats_label != null and is_instance_valid(stats_label):
		stats_label.text = _progress_text()
	if level_label != null and is_instance_valid(level_label):
		var next_level := Game.xp_to_next_level()
		var xp_text := "MAX" if next_level <= 0 else "%d/%d" % [int(Game.run.get("xp", 0)), next_level]
		level_label.text = "Nivel %d · XP %s" % [Game.player_level(), xp_text]
	var mhp := Game.max_hp()
	var hp := Game.hp()
	if player_hp_bar == null or not is_instance_valid(player_hp_bar):
		return
	player_hp_bar.max_value = maxi(1, mhp)
	player_hp_bar.value = hp
	var player_fill := UIKit.OK if hp > mhp * 0.35 else UIKit.DANGER
	player_hp_bar.add_theme_stylebox_override("fill", UIKit.flat(player_fill, Color.TRANSPARENT, 4))
	player_hp_label.text = "HP %d / %d" % [hp, mhp]
	if enemy_hp_bar != null:
		enemy_hp_bar.max_value = maxi(1, enemy_max_hp)
		enemy_hp_bar.value = maxi(0, enemy_hp)
		enemy_hp_bar.add_theme_stylebox_override("fill", UIKit.flat(_tier_color(String(enemy.get("tier", ""))), Color.TRANSPARENT, 4))
	if enemy_hp_label != null:
		enemy_hp_label.text = "HP %d / %d" % [maxi(0, enemy_hp), enemy_max_hp]
	if focus_player_label != null and is_instance_valid(focus_player_label):
		focus_player_label.text = "Rompe-límites · HP %d / %d" % [hp, mhp]
		focus_player_bar.max_value = maxi(1, mhp)
		focus_player_bar.value = hp
		focus_player_bar.add_theme_stylebox_override("fill", UIKit.flat(player_fill, Color.TRANSPARENT, 4))
	if focus_enemy_label != null and is_instance_valid(focus_enemy_label):
		focus_enemy_label.text = "%s · HP %d / %d" % [String(enemy.get("name", "Enemigo")), maxi(0, enemy_hp), enemy_max_hp]
		focus_enemy_bar.max_value = maxi(1, enemy_max_hp)
		focus_enemy_bar.value = maxi(0, enemy_hp)
		focus_enemy_bar.add_theme_stylebox_override("fill", UIKit.flat(_tier_color(String(enemy.get("tier", ""))), Color.TRANSPARENT, 4))
	var stats_node := find_child("PlayerStats", true, false)
	if stats_node is Label:
		stats_node.text = "Ataque: %d  ·  Defensa: %d" % [Game.attack_damage(1), Game.defense()]
	if status_label != null and is_instance_valid(status_label):
		var status_parts: Array[String] = []
		if player_weaken_turns > 0:
			status_parts.append("Maldito −%d%% (%d)" % [player_weaken_pct, player_weaken_turns])
		if player_vulnerable_turns > 0:
			status_parts.append("Marcado +%d daño (%d)" % [player_vulnerable_bonus, player_vulnerable_turns])
		if player_shield > 0:
			var shield_extra := maxi(0, player_shield_expires_turn - turn_number - 1)
			if shield_extra > 0:
				status_parts.append("Escudo %d · %d turno%s extra" % [player_shield, shield_extra, "" if shield_extra == 1 else "s"])
			else:
				status_parts.append("Escudo %d" % player_shield)
		status_label.text = " · ".join(status_parts)
		status_label.visible = not status_parts.is_empty()
	var equipped: Dictionary = Game.run.get("equipped", {})
	for i in range(mini(equipment_icons.size(), EQUIPMENT_SLOTS.size())):
		var item_id := String(equipped.get(EQUIPMENT_SLOTS[i], ""))
		equipment_icons[i].configure(item_id, _item_tint(item_id))
		equipment_icons[i].tooltip_text = "%s · %s" % [String(EQUIPMENT_SLOT_LABELS[EQUIPMENT_SLOTS[i]]), _equipment_name(item_id)]
		if i < equipment_item_labels.size():
			equipment_item_labels[i].text = _equipment_name(item_id)
	_refresh_battlefield()


func _set_focus(enabled: bool) -> void:
	if focus_bar == null or mid == null or phase_panel == null:
		return
	# El escenario y sus enemigos siguen a la vista mientras se responde.
	focus_bar.visible = false
	mid.visible = true
	phase_panel.custom_minimum_size = Vector2(0, 250 if enabled else 276)
	phase_panel.size_flags_vertical = Control.SIZE_SHRINK_END
	# El panel cambia de alto al pasar de elegir técnica a resolver o feedback.
	# Reajusta la formación para que nombres e intenciones enemigas no queden
	# debajo del panel cuando se toma la decisión.
	_schedule_enemy_formation_fit()


func _clear_phase() -> void:
	for c in phase_box.get_children():
		c.queue_free()
	for c in phase_footer.get_children():
		c.queue_free()
	phase_footer.visible = false
	if phase_scroll != null:
		phase_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
		phase_scroll.scroll_vertical = 0


# -------------------------------------------------------------------- turno

func _begin_turn() -> void:
	_ingest_legacy_target_state()
	var alive := _living_enemy_indices()
	if alive.is_empty():
		_victory()
		return
	turn_number += 1
	_purge_expired_enemy_corpses()
	alive = _living_enemy_indices()
	if alive.is_empty():
		_victory()
		return
	if selected_enemy_index < 0 or selected_enemy_index >= enemy_hps.size() or enemy_hps[selected_enemy_index] <= 0:
		selected_enemy_index = alive[0]
	_sync_selected_enemy()
	if player_shield <= 0 or turn_number >= player_shield_expires_turn:
		player_shield = 0
		player_shield_expires_turn = 0
	player_shield_grace_eligible = false
	_choose_enemy_intents()
	phase = "select"
	time_limit = 999.0
	for index in alive:
		time_limit = minf(time_limit, Combat.selection_time_for(enemies[index], rng))
	time_left = time_limit
	topic = Game.pick_topic(rng)
	problems.clear()
	for d in range(4):
		problems.append(MathEngine.generate(topic, d, rng))
	chosen = null
	chosen_attack_id = ""
	attack_target_indices.clear()
	berserk_armed = false
	berserk_attack_active = false
	_render_select()
	_refresh_hud()


func _render_select() -> void:
	_set_focus(false)
	_clear_phase()
	phase_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	phase_box.add_theme_constant_override("separation", 5)
	phase_box.alignment = BoxContainer.ALIGNMENT_CENTER
	var top := UIKit.hbox(14)
	top.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	phase_box.add_child(top)
	var title_box := UIKit.vbox(1)
	top.add_child(title_box)
	title_box.add_child(UIKit.eyebrow("Elegí una técnica", UIKit.STEEL_DARK))
	var t := UIKit.display_label("Prueba de %s · nivel %d" % [String(MathEngine.TOPIC_LABELS.get(topic, topic)), Game.player_level()], 22, UIKit.TEXT, 600, 0)
	title_box.add_child(t)
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	top.add_child(sp)
	var timer_box := UIKit.vbox(2)
	timer_box.custom_minimum_size = Vector2(230, 0)
	timer_box.alignment = BoxContainer.ALIGNMENT_CENTER
	top.add_child(timer_box)
	timer_label = UIKit.inline_label("", 14, UIKit.GOLD, 500)
	timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	timer_label.custom_minimum_size = Vector2(230, 20)
	timer_label.text = "Tiempo para elegir: %.1f s" % time_left
	timer_box.add_child(timer_label)
	timer_bar = UIKit.bar(time_left, maxf(1.0, time_limit), UIKit.GOLD, 8)
	timer_box.add_child(timer_bar)

	var row := GridContainer.new()
	row.columns = Combat.ATTACK_IDS.size()
	row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_theme_constant_override("h_separation", 6)
	row.add_theme_constant_override("v_separation", 6)
	phase_box.add_child(row)
	for attack_id in Combat.ATTACK_IDS:
		var attack_profile: Dictionary = Combat.PLAYER_ATTACKS[attack_id]
		var damage_type := String(attack_profile.get("type", "physical"))
		var is_defense := damage_type == "defense"
		var is_heal := damage_type == "heal"
		var accent := Color("#8ab7d4") if is_defense else (UIKit.OK if is_heal else (Color("#bc8755") if damage_type == "physical" else UIKit.VIOLET))
		var card := Button.new()
		card.flat = false
		card.focus_mode = Control.FOCUS_ALL
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.custom_minimum_size = Vector2(140, 116)
		card.add_theme_stylebox_override("normal", UIKit.flat(Color("#11151c"), accent.darkened(0.38), 5))
		card.add_theme_stylebox_override("hover", UIKit.flat(Color("#1b202a"), accent, 5))
		card.add_theme_stylebox_override("pressed", UIKit.flat(Color("#27222a"), accent.lightened(0.2), 5))
		card.add_theme_stylebox_override("focus", UIKit.flat(Color.TRANSPARENT, Color("#f2d18a"), 5))
		row.add_child(card)
		var card_inner := MarginContainer.new()
		card_inner.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		card_inner.add_theme_constant_override("margin_left", 12)
		card_inner.add_theme_constant_override("margin_right", 12)
		card_inner.add_theme_constant_override("margin_top", 5)
		card_inner.add_theme_constant_override("margin_bottom", 5)
		card_inner.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card.add_child(card_inner)
		var cv := UIKit.vbox(4)
		cv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		cv.size_flags_vertical = Control.SIZE_EXPAND_FILL
		cv.mouse_filter = Control.MOUSE_FILTER_IGNORE
		card_inner.add_child(cv)
		var kind_label := "DEFENSA" if is_defense else ("CURACIÓN" if is_heal else ("FÍSICO" if damage_type == "physical" else "MÁGICO"))
		cv.add_child(UIKit.eyebrow(kind_label, accent))
		var attack_name := UIKit.display_label(String(attack_profile.get("name", attack_id)), 14, UIKit.TEXT, 600, 0)
		attack_name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		cv.add_child(attack_name)
		var diff_range := Combat.attack_difficulty_range(Game.player_level(), Game.unlocked_difficulty(topic), attack_id)
		var low_damage := _attack_value_preview(attack_id, diff_range.x, enemy)
		var high_damage := _attack_value_preview(attack_id, diff_range.y, enemy)
		var range_text: String = String(MathEngine.DIFF_NAMES[diff_range.x])
		if diff_range.y != diff_range.x:
			range_text += "–" + MathEngine.DIFF_NAMES[diff_range.y]
		var target_limit := mini(int(attack_profile.get("targets", 1)), Combat.MAX_ENEMIES_PER_ENCOUNTER)
		var target_text := "propio" if (is_defense or is_heal) else ("1 objetivo" if target_limit == 1 else ("hasta %d obj." % target_limit if target_limit < enemies.size() else "todos"))
		var value_text := ""
		if is_defense:
			value_text = "%d escudo" % low_damage if low_damage == high_damage else "%d–%d escudo" % [low_damage, high_damage]
		elif is_heal:
			value_text = "%d HP" % low_damage if low_damage == high_damage else "%d–%d HP" % [low_damage, high_damage]
		else:
			value_text = "%d daño" % low_damage if low_damage == high_damage else "%d–%d daño" % [low_damage, high_damage]
		var damage_copy := UIKit.inline_label("%s · %s" % [target_text, value_text], 9, accent, 600)
		damage_copy.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		damage_copy.clip_text = true
		damage_copy.text_overrun_behavior = TextServer.OVERRUN_TRIM_ELLIPSIS
		cv.add_child(damage_copy)
		if is_defense:
			card.tooltip_text = ("%s\nPrueba: %s\nEl escudo absorbe los ataques de este turno; el remanente protege hasta 2 turnos más. Suma 2 por punto de defensa." % [
				String(attack_profile.get("description", "")),
				range_text,
			]).strip_edges()
		elif is_heal:
			card.tooltip_text = ("%s\nPrueba: %s\nCura %d–%d HP según la dificultad. Los enemigos siguen atacando este turno." % [
				String(attack_profile.get("description", "")),
				range_text,
				mini(low_damage, high_damage),
				maxi(low_damage, high_damage),
			]).strip_edges()
		else:
			var resistance_label := "armadura" if damage_type == "physical" else "resistencia mágica"
			card.tooltip_text = ("%s\nPrueba aleatoria: %s\nPenetración %d de %s" % [
				String(attack_profile.get("description", "")),
				range_text,
				int(attack_profile.get("penetration", 0)),
				resistance_label,
			]).strip_edges()
		var trial_label := UIKit.inline_label("Prueba %s" % range_text, 9, UIKit.STEEL)
		trial_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cv.add_child(trial_label)
		var effectiveness := Combat.attack_effectiveness_label(attack_id, enemy)
		var effectiveness_color := UIKit.OK if effectiveness == "Explotará su debilidad" else (UIKit.DANGER if effectiveness == "El enemigo resiste este tipo" else UIKit.STEEL_DARK)
		var effectiveness_copy := "Debilidad" if effectiveness == "Explotará su debilidad" else ("Resistencia" if effectiveness == "El enemigo resiste este tipo" else "Efectividad normal")
		if is_defense:
			effectiveness_color = UIKit.OK
			effectiveness_copy = "Protección"
		elif is_heal:
			effectiveness_color = UIKit.OK
			effectiveness_copy = "Curación directa"
		elif int(attack_profile.get("flux", 0)) > 0:
			effectiveness_color = UIKit.VIOLET
			effectiveness_copy = "Área · Flujo %d · %dt" % [
				int(attack_profile.get("flux", 0)),
				maxi(1, int(attack_profile.get("flux_turns", 1))),
			]
		elif int(attack_profile.get("bleed", 0)) > 0:
			effectiveness_color = Color("#d97862")
			effectiveness_copy = "Sangrado %d · %dt" % [
				int(attack_profile.get("bleed", 0)),
				maxi(1, int(attack_profile.get("bleed_turns", 1))),
			]
		elif float(attack_profile.get("mutilation_chance", 0.0)) > 0.0:
			effectiveness_color = UIKit.DANGER
			effectiveness_copy = "Mutilación %d%%" % int(roundf(float(attack_profile.get("mutilation_chance", 0.0)) * 100.0))
		elif int(attack_profile.get("weak_pct", 0)) > 0:
			effectiveness_color = Color("#d7b46a")
			effectiveness_copy = "Debilidad −%d%%" % int(attack_profile.get("weak_pct", 0))
		var effectiveness_label := UIKit.inline_label(effectiveness_copy, 9, effectiveness_color, 600)
		effectiveness_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		cv.add_child(effectiveness_label)
		card.pressed.connect(Callable(self, "_choose_attack").bind(attack_id))

	var footer := UIKit.hbox(10)
	phase_box.add_child(footer)
	var charge := Game.berserk_progress()
	var berserk_ready := charge >= Combat.BERSERK_CHARGE_ROUNDS
	var berserk_copy := UIKit.vbox(3)
	berserk_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(berserk_copy)
	berserk_copy.add_child(UIKit.eyebrow("BERSERK · %d / %d turnos" % [charge, Combat.BERSERK_CHARGE_ROUNDS], UIKit.GOLD))
	berserk_meter = UIKit.bar(Combat.BERSERK_CHARGE_ROUNDS, Combat.BERSERK_CHARGE_ROUNDS, UIKit.GOLD, 7)
	berserk_meter.value = charge
	berserk_copy.add_child(berserk_meter)
	berserk_button = UIKit.button("Berserk activo" if berserk_armed else ("Activar Berserk" if berserk_ready else "Berserk en carga"), UIKit.BURGUNDY if berserk_armed else UIKit.STEEL_DARK)
	berserk_button.custom_minimum_size = Vector2(190, 38)
	berserk_button.tooltip_text = "Berserk tarda %d turnos en cargarse. Si aciertas, aumenta el daño 50%%; si fallas, el ataque todavía hace 40%% de daño. El reloj solo corre mientras eliges." % Combat.BERSERK_CHARGE_ROUNDS
	berserk_button.disabled = not berserk_ready and not berserk_armed
	berserk_button.pressed.connect(_toggle_berserk)
	footer.add_child(berserk_button)
	_refresh_battlefield()


func _damage_preview(attack_id: String, difficulty: int, target: Dictionary) -> int:
	var raw := Game.attack_damage(difficulty, attack_id)
	return Combat.damage_for_attack(raw, attack_id, target)


func _attack_value_preview(attack_id: String, difficulty: int, target: Dictionary) -> int:
	if Combat.is_defense_attack(attack_id):
		return Game.attack_shield(difficulty, attack_id)
	if Combat.is_healing_attack(attack_id):
		return Game.attack_heal(difficulty, attack_id)
	return _damage_preview(attack_id, difficulty, target)


func _attack_status_tag(profile: Dictionary) -> String:
	var parts: Array[String] = []
	if int(profile.get("flux", 0)) > 0:
		parts.append("Flujo %d · %dt" % [
			int(profile.get("flux", 0)),
			maxi(1, int(profile.get("flux_turns", 1))),
		])
	if int(profile.get("bleed", 0)) > 0:
		parts.append("Sangrado %d · %dt" % [
			int(profile.get("bleed", 0)),
			maxi(1, int(profile.get("bleed_turns", 1))),
		])
	if float(profile.get("mutilation_chance", 0.0)) > 0.0:
		parts.append("Mutilación %d%%" % int(roundf(float(profile.get("mutilation_chance", 0.0)) * 100.0)))
	if int(profile.get("weak_pct", 0)) > 0:
		parts.append("Debilidad −%d%% · %dt" % [
			int(profile.get("weak_pct", 0)),
			maxi(1, int(profile.get("weak_turns", 1))),
		])
	if int(profile.get("fragile", 0)) > 0:
		parts.append("Frágil +%d · %dt" % [
			int(profile.get("fragile", 0)),
			maxi(1, int(profile.get("fragile_turns", 1))),
		])
	return " · ".join(parts)


func _target_names(indices: Array[int]) -> String:
	var names: Array[String] = []
	for index in indices:
		if index >= 0 and index < enemies.size():
			names.append(String(enemies[index].get("name", "Enemigo")))
	return ", ".join(names)


func _targets_for_attack(attack_id: String) -> Array[int]:
	var alive := _living_enemy_indices()
	var targets: Array[int] = []
	if alive.is_empty():
		return targets
	if Combat.is_support_attack(attack_id):
		return targets
	var anchor := selected_enemy_index if selected_enemy_index in alive else alive[0]
	targets.append(anchor)
	var profile: Dictionary = Combat.PLAYER_ATTACKS.get(attack_id, Combat.PLAYER_ATTACKS["piercing_strike"])
	var limit := clampi(int(profile.get("targets", 1)), 1, Combat.MAX_ENEMIES_PER_ENCOUNTER)
	for index in alive:
		if targets.size() >= limit:
			break
		if index != anchor:
			targets.append(index)
	return targets


func _select_target(index: int) -> void:
	if phase != "select" or index < 0 or index >= enemies.size():
		return
	_ingest_legacy_target_state()
	if enemy_hps[index] <= 0:
		return
	selected_enemy_index = index
	_sync_selected_enemy()
	Audio.play_sfx("select")
	_render_select()
	_refresh_hud()


func _toggle_berserk() -> void:
	if Game.berserk_progress() < Combat.BERSERK_CHARGE_ROUNDS and not berserk_armed:
		return
	berserk_armed = not berserk_armed
	_render_select()


func _choose(choice: Variant) -> void:
	# Compatibilidad con llamadas antiguas: un entero selecciona el ataque por índice.
	var attack_id := str(choice)
	if typeof(choice) == TYPE_INT:
		attack_id = String(Combat.ATTACK_IDS[clampi(int(choice), 0, Combat.ATTACK_IDS.size() - 1)])
	_choose_attack(attack_id)


func _choose_attack(attack_id: String) -> void:
	if phase != "select" or attack_id not in Combat.ATTACK_IDS:
		return
	_ingest_legacy_target_state()
	var alive := _living_enemy_indices()
	if alive.is_empty():
		return
	if selected_enemy_index < 0 or selected_enemy_index >= enemy_hps.size() or enemy_hps[selected_enemy_index] <= 0:
		selected_enemy_index = alive[0]
	_sync_selected_enemy()
	chosen_attack_id = attack_id
	var difficulty_range := Combat.attack_difficulty_range(Game.player_level(), Game.unlocked_difficulty(topic), attack_id)
	chosen_diff = rng.randi_range(difficulty_range.x, difficulty_range.y)
	if chosen_diff < problems.size():
		chosen = problems[chosen_diff] as MathEngine.Problem
	else:
		chosen = MathEngine.generate(topic, chosen_diff, rng)
	attack_target_indices = _targets_for_attack(attack_id)
	berserk_attack_active = berserk_armed and Game.consume_berserk_charge()
	berserk_armed = false
	phase = "solve"
	Audio.play_sfx("select")
	_refresh_battlefield()
	_render_solve()
	_refresh_hud()
func _difficulty_color(d: int) -> Color:
	return UIKit.DIFF_COLORS[clampi(d, 0, 3)]


func _render_solve() -> void:
	_set_focus(true)
	var graph_problem := chosen != null and chosen.topic == "graph"
	phase_panel.custom_minimum_size = Vector2(0, 372 if graph_problem else 288)
	_clear_phase()
	phase_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO if graph_problem else ScrollContainer.SCROLL_MODE_DISABLED
	phase_box.add_theme_constant_override("separation", 4)
	phase_box.alignment = BoxContainer.ALIGNMENT_CENTER
	var head := UIKit.hbox(8)
	head.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	phase_box.add_child(head)
	var head_copy := UIKit.vbox(0)
	head.add_child(head_copy)
	var attack_profile: Dictionary = Combat.PLAYER_ATTACKS.get(chosen_attack_id, Combat.PLAYER_ATTACKS["piercing_strike"])
	head_copy.add_child(UIKit.eyebrow(String(attack_profile.get("name", "Ataque")), UIKit.STEEL_DARK))
	var heading := UIKit.display_label("%s  ·  %s" % [chosen.difficulty_label(), chosen.topic_label()], 18, UIKit.GOLD, 600, 0)
	heading.autowrap_mode = TextServer.AUTOWRAP_OFF
	head_copy.add_child(heading)
	var is_defense := Combat.is_defense_attack(chosen_attack_id)
	var is_heal := Combat.is_healing_attack(chosen_attack_id)
	var is_support := is_defense or is_heal
	var targets_copy := UIKit.inline_label("Objetivo: " + ("propio" if is_support else _target_names(attack_target_indices)), 10, UIKit.STEEL)
	head_copy.add_child(targets_copy)
	var sp := Control.new()
	sp.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(sp)
	var damage_box := UIKit.vbox(1)
	damage_box.alignment = BoxContainer.ALIGNMENT_CENTER
	head.add_child(damage_box)
	var value_header := "Curación potencial" if is_heal else ("Escudo potencial" if is_defense else "Daño potencial")
	damage_box.add_child(UIKit.eyebrow(value_header, UIKit.STEEL_DARK))
	var potential_damage := 0
	if is_defense:
		potential_damage = Game.attack_shield(chosen_diff, chosen_attack_id)
		if berserk_attack_active:
			potential_damage = maxi(0, int(roundf(float(potential_damage) * Combat.BERSERK_HIT_MULTIPLIER)))
	elif is_heal:
		potential_damage = Game.attack_heal(chosen_diff, chosen_attack_id)
		if berserk_attack_active:
			potential_damage = maxi(0, int(roundf(float(potential_damage) * Combat.BERSERK_HIT_MULTIPLIER)))
	else:
		var raw_damage := Game.attack_damage(chosen_diff, chosen_attack_id)
		if berserk_attack_active:
			raw_damage = maxi(1, int(roundf(float(raw_damage) * Combat.BERSERK_HIT_MULTIPLIER)))
		for index in attack_target_indices:
			if index >= 0 and index < enemies.size():
				var fragile_bonus := enemy_fragile_bonus[index] if index < enemy_fragile_bonus.size() else 0
				potential_damage += Combat.damage_for_attack(raw_damage, chosen_attack_id, enemies[index]) + fragile_bonus
	var damage_label := UIKit.display_label("%d" % potential_damage, 24, UIKit.OK if is_support else UIKit.GOLD, 600, 0)
	damage_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	damage_box.add_child(damage_label)
	var value_sub := "HP recuperable" if is_heal else ("para este turno" if is_defense else "a %d objetivo(s)" % attack_target_indices.size())
	var status_tag := _attack_status_tag(attack_profile)
	if status_tag != "":
		value_sub += " · " + status_tag
	damage_box.add_child(UIKit.inline_label(value_sub, 10, UIKit.STEEL_DARK))
	# El panel de resolución puede crecer sobre las etiquetas de intención del
	# escenario. Esta tira mantiene las acciones enemigas visibles durante la
	# decisión, incluso en gráficas o ventanas bajas.
	phase_box.add_child(_render_enemy_intent_strip())

	var card := UIKit.panel(Color(0.055, 0.066, 0.082, 0.96), Color("#3d4652"), true, _difficulty_color(chosen_diff))
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	var card_style := card.get_theme_stylebox("panel") as StyleBoxFlat
	if card_style != null:
		card_style.content_margin_left = 9
		card_style.content_margin_right = 9
		card_style.content_margin_top = 5
		card_style.content_margin_bottom = 5
	phase_box.add_child(card)
	var cv := UIKit.vbox(4)
	card.add_child(cv)

	var body_row := UIKit.hbox(10)
	body_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cv.add_child(body_row)
	var prompt_copy := UIKit.vbox(3)
	prompt_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body_row.add_child(prompt_copy)
	var problem_head := UIKit.hbox(7)
	prompt_copy.add_child(problem_head)
	problem_head.add_child(UIKit.eyebrow("Pregunta", _difficulty_color(chosen_diff)))
	problem_head.add_child(UIKit.badge("DIFICULTAD %d / 4" % (chosen_diff + 1), _difficulty_color(chosen_diff), 9))
	if berserk_attack_active:
		problem_head.add_child(UIKit.badge("BERSERK", UIKit.BURGUNDY, 9))

	var stmt := UIKit.label(chosen.statement, 12, UIKit.MUTED)
	stmt.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	prompt_copy.add_child(stmt)
	var expression_size := 29
	if chosen.expression.length() > 75:
		expression_size = 22
	elif chosen.expression.length() > 52:
		expression_size = 25
	elif chosen.expression.length() > 36:
		expression_size = 27
	var expr := UIKit.math_label(chosen.expression, expression_size, UIKit.TEXT)
	expr.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	expr.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	prompt_copy.add_child(expr)

	if chosen.topic == "graph" and not chosen.graph.is_empty():
		var gv := GraphView.new()
		gv.setup(chosen.graph)
		var gc := CenterContainer.new()
		gc.custom_minimum_size = Vector2(500, 200)
		gc.size_flags_horizontal = Control.SIZE_SHRINK_END
		gv.custom_minimum_size = Vector2(500, 200)
		gc.add_child(gv)
		body_row.add_child(gc)
	elif chosen.topic == "table" and not chosen.table.is_empty():
		var gc := CenterContainer.new()
		gc.custom_minimum_size = Vector2(230, 110)
		gc.size_flags_horizontal = Control.SIZE_SHRINK_END
		var grid := GridContainer.new()
		grid.columns = 2
		grid.add_theme_constant_override("h_separation", 24)
		grid.add_theme_constant_override("v_separation", 1)
		grid.add_child(UIKit.inline_label("x", 11, UIKit.GOLD, 600))
		grid.add_child(UIKit.inline_label("f(x)", 11, UIKit.GOLD, 600))
		for pair in chosen.table:
			grid.add_child(UIKit.inline_label("%.3f" % float(pair[0]), 11, UIKit.STEEL))
			grid.add_child(UIKit.inline_label("%.4f" % float(pair[1]), 11, UIKit.TEXT))
		gc.add_child(grid)
		body_row.add_child(gc)

	var row := UIKit.hbox(7)
	cv.add_child(row)
	input = UIKit.line_edit("Escribí el valor exacto (ej. 3, -1/2, 2.5)", 15)
	input.custom_minimum_size = Vector2(0, 38)
	input.text_submitted.connect(func(_t: String) -> void: _submit(input.text))
	row.add_child(input)
	var submit_label := "Sellar" if is_defense else ("Curar" if is_heal else "Atacar")
	var submit := UIKit.button(submit_label, UIKit.BURGUNDY)
	submit.custom_minimum_size = Vector2(118, 38)
	submit.pressed.connect(func() -> void: _submit(input.text))
	row.add_child(submit)
	var dne := UIKit.button("No existe", UIKit.STEEL_DARK)
	dne.custom_minimum_size = Vector2(110, 38)
	dne.pressed.connect(func() -> void: _submit("no existe"))
	row.add_child(dne)

	var footer := UIKit.hbox(8)
	cv.add_child(footer)
	footer.add_child(UIKit.keycap("PISTA"))
	var hint_copy := UIKit.inline_label(chosen.hint, 10, UIKit.STEEL_DARK)
	hint_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	hint_copy.clip_text = true
	footer.add_child(hint_copy)
	input.grab_focus()


func _submit(raw: String) -> void:
	if phase != "solve" or chosen == null:
		return
	var correct := MathEngine.grade(chosen, raw)
	_resolve(correct)


func _resolve(correct: bool) -> void:
	_ingest_legacy_target_state()
	if chosen_attack_id == "" or chosen_attack_id not in Combat.ATTACK_IDS:
		chosen_attack_id = "piercing_strike"
	if attack_target_indices.is_empty():
		attack_target_indices = _targets_for_attack(chosen_attack_id)
	phase = "feedback"
	Game.record_answer(topic, chosen_diff, correct)
	var weaken_at_start := player_weaken_turns
	var vulnerable_at_start := player_vulnerable_turns
	var enemy_fragile_before := enemy_fragile_turns.duplicate()
	var result_parts: Array[String] = []
	var level_messages: Array[String] = []
	var used_berserk := berserk_attack_active
	var attack_landed := correct or used_berserk
	var total_player_damage := 0
	var guard_absorbed := 0
	var fragile_targets: Array[String] = []
	var weak_targets: Array[String] = []
	var flux_targets: Array[String] = []
	var bleed_targets: Array[String] = []
	var mutilated_targets: Array[String] = []
	var defeated_names: Array[String] = []
	var attack_profile: Dictionary = Combat.PLAYER_ATTACKS[chosen_attack_id]
	var damage_type := String(attack_profile.get("type", "physical"))
	var is_defense := Combat.is_defense_attack(chosen_attack_id)
	var is_heal := Combat.is_healing_attack(chosen_attack_id)
	var is_support := is_defense or is_heal
	if attack_landed:
		if is_instance_valid(player_portrait):
			player_portrait.play_effect("correct" if correct else "incorrect")
		if is_instance_valid(focus_player_portrait):
			focus_player_portrait.play_effect("correct" if correct else "incorrect")
		var multiplier := 1.0
		if used_berserk:
			multiplier = Combat.BERSERK_HIT_MULTIPLIER if correct else Combat.BERSERK_MISS_MULTIPLIER
		if is_defense:
			var shield := Game.attack_shield(chosen_diff, chosen_attack_id)
			shield = maxi(0, int(roundf(float(shield) * multiplier)))
			player_shield = shield
			player_shield_expires_turn = turn_number + 1
			player_shield_grace_eligible = shield > 0
			if vfx != null:
				var player_center := _portrait_center(_active_player_portrait())
				vfx.burst(player_center, "correct", 1.0)
				vfx.pop_number(player_center, "+%d" % shield, UIKit.OK, 28, Vector2(0, -60))
			Audio.play_sfx("correct" if correct else "incorrect")
			Audio.play_sfx("arcane")
			if correct:
				result_parts.append("Acierto · %s (+%d escudo)" % [String(attack_profile.get("name", "Sello")), shield])
			else:
				result_parts.append("Berserk fallido · sello parcial (+%d escudo)" % shield)
		elif is_heal:
			var heal := Game.attack_heal(chosen_diff, chosen_attack_id)
			heal = maxi(0, int(roundf(float(heal) * multiplier)))
			var healed := Game.add_hp(heal)
			if is_instance_valid(player_portrait):
				player_portrait.play_effect("heal")
			if is_instance_valid(focus_player_portrait):
				focus_player_portrait.play_effect("heal")
			if vfx != null:
				var player_center := _portrait_center(_active_player_portrait())
				vfx.burst(player_center, "heal", 1.0)
				vfx.pop_number(player_center, "+%d" % healed, UIKit.OK, 28, Vector2(0, -60))
			Audio.play_sfx("heal")
			if correct:
				if healed > 0:
					result_parts.append("Acierto · %s (+%d HP)" % [String(attack_profile.get("name", "Aliento")), healed])
				else:
					result_parts.append("Acierto · %s (HP ya al máximo)" % String(attack_profile.get("name", "Aliento")))
			else:
				result_parts.append("Berserk fallido · aliento parcial (+%d HP)" % healed)
		else:
			var base_damage := Game.attack_damage(chosen_diff, chosen_attack_id)
			base_damage = maxi(1, int(roundf(float(base_damage) * multiplier)))
			var weakened := player_weaken_turns > 0 and player_weaken_pct > 0
			if weakened:
				base_damage = maxi(1, int(roundf(float(base_damage) * (1.0 - float(player_weaken_pct) / 100.0))))
			for index in attack_target_indices:
				if index < 0 or index >= enemies.size() or enemy_hps[index] <= 0:
					continue
				var target: Dictionary = enemies[index]
				var fragile_bonus := enemy_fragile_bonus[index] if index < enemy_fragile_bonus.size() else 0
				var dealt := Combat.damage_for_attack(base_damage, chosen_attack_id, target) + fragile_bonus
				var guard := enemy_guards[index] if index < enemy_guards.size() else 0
				if guard > 0:
					var blocked := mini(guard, dealt)
					enemy_guards[index] = guard - blocked
					dealt -= blocked
					guard_absorbed += blocked
				var before_hp := enemy_hps[index]
				enemy_hps[index] = maxi(0, before_hp - dealt)
				total_player_damage += dealt
				var target_name := String(target.get("name", "Enemigo"))
				var actor_portrait: FantasyPortrait = enemy_actors[index].portrait if index < enemy_actors.size() else null
				var hit_effect := "critical" if used_berserk and correct else ("arcane" if damage_type == "magic" else "slash")
				if is_instance_valid(actor_portrait):
					actor_portrait.play_effect(hit_effect)
				if vfx != null:
					var target_center := _portrait_center(actor_portrait)
					var player_center := _portrait_center(_active_player_portrait())
					vfx.burst(target_center, hit_effect, 1.12 if used_berserk else 1.0, (target_center - player_center).normalized())
					if dealt > 0:
						vfx.pop_number(target_center, "-%d" % dealt, UIKit.GOLD, 30 if used_berserk else 26)
					elif guard > 0:
						vfx.pop_number(target_center, "0", UIKit.STEEL, 22)
				if enemy_hps[index] <= 0:
					enemy_fragile_bonus[index] = 0
					enemy_fragile_turns[index] = 0
					enemy_weak_pct[index] = 0
					enemy_weak_turns[index] = 0
					enemy_weak_applied_turn[index] = -1
					enemy_flux_damage[index] = 0
					enemy_flux_turns[index] = 0
					enemy_flux_applied_turn[index] = -1
					enemy_bleed_damage[index] = 0
					enemy_bleed_turns[index] = 0
					enemy_bleed_applied_turn[index] = -1
					enemy_stun_turns[index] = 0
					if index < enemy_death_turns.size() and enemy_death_turns[index] < 0:
						enemy_death_turns[index] = turn_number
					defeated_names.append(target_name)
					Game.run["stats"]["enemies"] = int(Game.run["stats"].get("enemies", 0)) + 1
					var levels_gained := Game.award_combat_xp(Combat.xp_for(target))
					if levels_gained > 0:
						level_messages.append("Subes a nivel %d" % Game.player_level())
					if is_instance_valid(actor_portrait):
						actor_portrait.play_effect("defeat")
					if vfx != null:
						vfx.burst(_portrait_center(actor_portrait), "defeat", 1.2)
					Audio.play_sfx("enemy_death")
				else:
					var fragile_value := int(attack_profile.get("fragile", 0))
					if fragile_value > 0:
						var fragile_turns := maxi(1, int(attack_profile.get("fragile_turns", 1)))
						enemy_fragile_bonus[index] = maxi(enemy_fragile_bonus[index], fragile_value)
						enemy_fragile_turns[index] = maxi(enemy_fragile_turns[index], fragile_turns)
						fragile_targets.append(target_name)
					var weak_pct := int(attack_profile.get("weak_pct", 0))
					if weak_pct > 0:
						var weak_turns := maxi(1, int(attack_profile.get("weak_turns", 1)))
						enemy_weak_pct[index] = maxi(enemy_weak_pct[index], weak_pct)
						enemy_weak_turns[index] = maxi(enemy_weak_turns[index], weak_turns)
						enemy_weak_applied_turn[index] = turn_number
						weak_targets.append(target_name)
					var bleed_value := int(attack_profile.get("bleed", 0))
					if bleed_value > 0 and Combat.is_living_enemy(target):
						var bleed_turns := maxi(1, int(attack_profile.get("bleed_turns", 1)))
						enemy_bleed_damage[index] = maxi(enemy_bleed_damage[index], bleed_value)
						enemy_bleed_turns[index] = maxi(enemy_bleed_turns[index], bleed_turns)
						enemy_bleed_applied_turn[index] = turn_number
						bleed_targets.append(target_name)
					var flux_value := int(attack_profile.get("flux", 0))
					if flux_value > 0 and not Combat.is_magic_flux_immune(target):
						var flux_turns := maxi(1, int(attack_profile.get("flux_turns", 1)))
						enemy_flux_damage[index] = maxi(enemy_flux_damage[index], flux_value)
						enemy_flux_turns[index] = maxi(enemy_flux_turns[index], flux_turns)
						enemy_flux_applied_turn[index] = turn_number
						flux_targets.append(target_name)
					var mutilation_chance := float(attack_profile.get("mutilation_chance", 0.0))
					if mutilation_chance > 0.0 and rng.randf() < mutilation_chance:
						enemy_stun_turns[index] = maxi(enemy_stun_turns[index], 1)
						mutilated_targets.append(target_name)
						if vfx != null:
							vfx.pop_number(_portrait_center(actor_portrait), "MUTILADO", UIKit.DANGER, 14, Vector2(0, 24))
					Audio.play_sfx("enemy_hit")
			_refresh_battlefield()
			Audio.play_sfx("correct" if correct else "incorrect")
			Audio.play_sfx("arcane" if damage_type == "magic" else "attack")
			if correct:
				result_parts.append("Acierto · %s" % String(attack_profile.get("name", "Ataque")))
			else:
				result_parts.append("Berserk fallido · daño reducido")
			if weakened:
				result_parts.append("Maldición: −%d%% de daño" % player_weaken_pct)
			if guard_absorbed > 0:
				result_parts.append("Guardia enemiga absorbe %d" % guard_absorbed)
			if not fragile_targets.is_empty():
				result_parts.append("Frágil aplicado a %s: +%d de daño recibido durante %d turnos" % [
					", ".join(fragile_targets),
					int(attack_profile.get("fragile", 0)),
					maxi(1, int(attack_profile.get("fragile_turns", 1))),
				])
			if not weak_targets.is_empty():
				result_parts.append("Debilidad en %s: −%d%% de daño enemigo durante %d turnos" % [
					", ".join(weak_targets),
					int(attack_profile.get("weak_pct", 0)),
					maxi(1, int(attack_profile.get("weak_turns", 1))),
				])
			if not bleed_targets.is_empty():
				result_parts.append("Sangrado en %s: %d de daño por turno durante %d turnos" % [
					", ".join(bleed_targets),
					int(attack_profile.get("bleed", 0)),
					maxi(1, int(attack_profile.get("bleed_turns", 1))),
				])
			if not flux_targets.is_empty():
				result_parts.append("Flujo de magia en %s: %d de daño por turno durante %d turnos" % [
					", ".join(flux_targets),
					int(attack_profile.get("flux", 0)),
					maxi(1, int(attack_profile.get("flux_turns", 1))),
				])
			if not mutilated_targets.is_empty():
				result_parts.append("Mutilación en %s: pierde el siguiente turno" % ", ".join(mutilated_targets))
			if not defeated_names.is_empty():
				result_parts.append("Derrotados: " + ", ".join(defeated_names))
			result_parts.append_array(level_messages)
	else:
		Audio.play_sfx("incorrect")
		if is_instance_valid(player_portrait):
			player_portrait.play_effect("incorrect")
		if is_instance_valid(focus_player_portrait):
			focus_player_portrait.play_effect("incorrect")
		if is_defense:
			result_parts.append("Fallo · el sello se disipa antes de formarse")
		elif is_heal:
			result_parts.append("Fallo · el aliento se disipa sin curar")
		else:
			result_parts.append("Fallo · el ataque no llega a ningún enemigo")

	var self_dmg := 0
	if not correct:
		self_dmg = Game.failing_self_damage(chosen_diff)
		if self_dmg > 0:
			Game.damage_player(self_dmg)
			if vfx != null:
				var player_center := _portrait_center(_active_player_portrait())
				vfx.burst(player_center + Vector2(-22, 10), "incorrect", 0.55)
				vfx.pop_number(player_center, "-%d" % self_dmg, UIKit.VIOLET, 22, Vector2(0, -60))

	var enemy_attack_result := _apply_enemy_attacks()
	var enemy_damage_total := int(enemy_attack_result.get("total", 0))
	var absorbed_total := int(enemy_attack_result.get("absorbed", 0))
	var enemy_summary := str(enemy_attack_result.get("summary", ""))
	var reaction_parts: Array[String] = []
	if self_dmg > 0:
		reaction_parts.append("−%d HP de retroceso arcano" % self_dmg)
	if absorbed_total > 0:
		reaction_parts.append("Escudo absorbe %d" % absorbed_total)
	if enemy_summary != "":
		reaction_parts.append(enemy_summary)
	elif enemy_damage_total > 0:
		reaction_parts.append("Contraataque −%d HP" % enemy_damage_total)
	if player_shield_grace_eligible and player_shield > 0:
		player_shield_expires_turn = turn_number + 3
		reaction_parts.append("Escudo restante: %d · hasta 2 turnos más" % player_shield)
	player_shield_grace_eligible = false
	if not reaction_parts.is_empty():
		result_parts.append(" · ".join(reaction_parts))
	var dot_levels: Array = enemy_attack_result.get("dot_levels", [])
	if not dot_levels.is_empty():
		result_parts.append_array(dot_levels)
	_tick_player_statuses(weaken_at_start, vulnerable_at_start)
	_tick_enemy_statuses(enemy_fragile_before)
	_tick_enemy_weakness()
	Game.charge_berserk_turn()
	berserk_attack_active = false
	berserk_armed = false
	if attack_landed and not is_support:
		result_parts.insert(1, "Daño total: −%d" % total_player_damage)
	last_message = "\n".join(result_parts)
	_render_feedback(correct, last_message)
	_refresh_hud()


func _tick_player_statuses(weaken_before: int, vulnerable_before: int) -> void:
	if weaken_before > 0:
		player_weaken_turns = maxi(0, player_weaken_turns - 1)
		if player_weaken_turns == 0:
			player_weaken_pct = 0
	if vulnerable_before > 0:
		player_vulnerable_turns = maxi(0, player_vulnerable_turns - 1)
		if player_vulnerable_turns == 0:
			player_vulnerable_bonus = 0


func _tick_enemy_statuses(fragile_before: Array) -> void:
	for index in range(enemy_fragile_turns.size()):
		var was_active := index < fragile_before.size() and int(fragile_before[index]) > 0
		if not was_active:
			continue
		enemy_fragile_turns[index] = maxi(0, enemy_fragile_turns[index] - 1)
		if enemy_fragile_turns[index] == 0:
			enemy_fragile_bonus[index] = 0


func _tick_enemy_weakness() -> void:
	for index in range(enemy_weak_turns.size()):
		if enemy_weak_turns[index] <= 0:
			continue
		if index < enemy_weak_applied_turn.size() and enemy_weak_applied_turn[index] == turn_number:
			# La Debilidad aplicada este turno no se descuenta en la misma ronda.
			continue
		enemy_weak_turns[index] = maxi(0, enemy_weak_turns[index] - 1)
		if enemy_weak_turns[index] == 0:
			enemy_weak_pct[index] = 0
			enemy_weak_applied_turn[index] = -1


func _render_feedback(correct: bool, result: String) -> void:
	_set_focus(true)
	_clear_phase()
	phase_panel.custom_minimum_size = Vector2(0, 260)
	phase_scroll.vertical_scroll_mode = ScrollContainer.SCROLL_MODE_AUTO
	phase_box.alignment = BoxContainer.ALIGNMENT_BEGIN
	phase_footer.visible = true
	var color := UIKit.OK if correct else UIKit.DANGER
	var card := UIKit.panel(Color(0.055, 0.066, 0.082, 0.96), color.darkened(0.45), true, color)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	phase_box.add_child(card)
	var cv := UIKit.vbox(5)
	cv.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.add_child(cv)
	var body := UIKit.hbox(16)
	body.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	cv.add_child(body)
	var summary_column := UIKit.vbox(4)
	summary_column.custom_minimum_size = Vector2(380, 0)
	body.add_child(summary_column)
	var head := UIKit.hbox(9)
	head.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	summary_column.add_child(head)
	var mark := UIKit.display_label("✓" if correct else "✕", 34, color, 600, 0)
	mark.custom_minimum_size = Vector2(42, 0)
	mark.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	head.add_child(mark)
	var head_copy := UIKit.vbox(1)
	head_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(head_copy)
	head_copy.add_child(UIKit.eyebrow("Resultado de la técnica", color))
	var result_label := UIKit.label(result, 14, color, 600)
	result_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	result_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	head_copy.add_child(result_label)
	var explanation := UIKit.vbox(4)
	explanation.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(explanation)
	var statement_label := UIKit.label(chosen.statement, 13, UIKit.MUTED)
	statement_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	explanation.add_child(statement_label)
	var expression_label := UIKit.math_label(chosen.expression, 26, UIKit.TEXT)
	expression_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	expression_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	explanation.add_child(expression_label)
	var answer_row := UIKit.hbox(10)
	answer_row.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	explanation.add_child(answer_row)
	answer_row.add_child(UIKit.badge("RESPUESTA CORRECTA", UIKit.GOLD, 10))
	answer_row.add_child(UIKit.display_label(MathEngine.format_answer(chosen), 18, UIKit.GOLD, 600, 0))
	var steps := UIKit.vbox(1)
	steps.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	explanation.add_child(steps)
	var limit := mini(chosen.steps.size(), 3)
	for i in range(limit):
		var step_label := UIKit.label("· " + chosen.steps[i], 11, UIKit.STEEL)
		step_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		steps.add_child(step_label)
	var cont := UIKit.button("Continuar", UIKit.VIOLET_SOFT)
	cont.custom_minimum_size = Vector2(180, 40)
	cont.pressed.connect(_after_feedback)
	phase_footer.add_child(cont)
func _after_feedback() -> void:
	if phase != "feedback":
		return
	if Game.hp() <= 0:
		_die()
		return
	_ingest_legacy_target_state()
	if _living_enemy_indices().is_empty():
		_victory()
		return
	_begin_turn()


func _play_enemy_attack(index: int) -> void:
	if index < 0 or index >= enemy_actors.size():
		return
	Audio.play_sfx("attack")
	var attacker_portrait: FantasyPortrait = enemy_actors[index].portrait
	enemy_actors[index].play_effect("slash")
	enemy_actors[index].play_lunge()
	if vfx != null:
		var enemy_center := _portrait_center(attacker_portrait)
		var player_center := _portrait_center(_active_player_portrait())
		var attack_aim := (player_center - enemy_center).normalized()
		vfx.burst(enemy_center, "slash", 0.85, attack_aim)


func _play_enemy_support(index: int, effect: String) -> void:
	if index < 0 or index >= enemy_actors.size():
		return
	var actor_portrait: FantasyPortrait = enemy_actors[index].portrait
	if is_instance_valid(actor_portrait):
		actor_portrait.play_effect(effect)
	if vfx != null:
		vfx.burst(_portrait_center(actor_portrait), effect, 0.8)


func _summon_enemy(ability: Dictionary) -> String:
	if enemies.size() >= Combat.MAX_ENEMIES_PER_ENCOUNTER:
		return ""
	var template := Combat.enemy_by_id(String(ability.get("enemy", "")))
	if template.is_empty():
		return ""
	var data := template.duplicate(true)
	var summon_name := String(ability.get("summon_name", ""))
	if summon_name != "":
		data["name"] = summon_name
	var maximum := maxi(1, int(data.get("hp", 1)))
	enemies.append(data)
	enemy_hps.append(maximum)
	enemy_max_hps.append(maximum)
	enemy_intents.append({
		"name": "Se incorpora",
		"kind": "idle",
		"text": "Se incorpora al combate; actuará desde el próximo turno.",
	})
	enemy_guards.append(0)
	enemy_bonus_damage.append(0)
	enemy_bonus_turns.append(0)
	enemy_fragile_bonus.append(0)
	enemy_fragile_turns.append(0)
	enemy_weak_pct.append(0)
	enemy_weak_turns.append(0)
	enemy_weak_applied_turn.append(-1)
	enemy_flux_damage.append(0)
	enemy_flux_turns.append(0)
	enemy_flux_applied_turn.append(-1)
	enemy_bleed_damage.append(0)
	enemy_bleed_turns.append(0)
	enemy_bleed_applied_turn.append(-1)
	enemy_stun_turns.append(0)
	enemy_death_turns.append(-1)
	enemy_last_ability.append("")
	enemy_last_kind.append("idle")
	_rebuild_enemy_actors()
	return String(data.get("name", "un aliado"))


func _tick_enemy_damage_over_time() -> Dictionary:
	var total := 0
	var summaries: Array[String] = []
	var deaths: Array[String] = []
	var levels: Array[String] = []
	var touched := false
	for index in range(enemies.size()):
		if enemy_hps[index] <= 0:
			continue
		var target: Dictionary = enemies[index]
		var bleed_damage := 0
		if index < enemy_bleed_turns.size() and enemy_bleed_turns[index] > 0:
			if Combat.is_living_enemy(target) and enemy_bleed_applied_turn[index] != turn_number:
				bleed_damage = maxi(1, enemy_bleed_damage[index])
				enemy_bleed_turns[index] = maxi(0, enemy_bleed_turns[index] - 1)
				if enemy_bleed_turns[index] == 0:
					enemy_bleed_damage[index] = 0
					enemy_bleed_applied_turn[index] = -1
		var flux_damage := 0
		if index < enemy_flux_turns.size() and enemy_flux_turns[index] > 0:
			if not Combat.is_magic_flux_immune(target) and enemy_flux_applied_turn[index] != turn_number:
				flux_damage = maxi(1, enemy_flux_damage[index])
				enemy_flux_turns[index] = maxi(0, enemy_flux_turns[index] - 1)
				if enemy_flux_turns[index] == 0:
					enemy_flux_damage[index] = 0
					enemy_flux_applied_turn[index] = -1
		if bleed_damage <= 0 and flux_damage <= 0:
			continue
		touched = true
		var target_name := String(target.get("name", "Enemigo"))
		var before_hp := int(enemy_hps[index])
		enemy_hps[index] = maxi(0, before_hp - bleed_damage - flux_damage)
		var dealt := before_hp - enemy_hps[index]
		total += dealt
		var parts: Array[String] = []
		if bleed_damage > 0:
			parts.append("sangrado −%d" % bleed_damage)
		if flux_damage > 0:
			parts.append("flujo −%d" % flux_damage)
		summaries.append("%s: %s" % [target_name, ", ".join(parts)])
		var actor_portrait: FantasyPortrait = enemy_actors[index].portrait if index < enemy_actors.size() else null
		if is_instance_valid(actor_portrait):
			actor_portrait.play_effect("arcane" if flux_damage > 0 else "slash")
		if vfx != null:
			var target_center := _portrait_center(actor_portrait)
			vfx.burst(target_center, "arcane" if flux_damage > 0 else "slash", 0.7)
			vfx.pop_number(target_center, "−%d" % dealt, UIKit.VIOLET if flux_damage > 0 else Color("#d97862"), 22)
		if enemy_hps[index] <= 0:
			enemy_fragile_bonus[index] = 0
			enemy_fragile_turns[index] = 0
			enemy_weak_pct[index] = 0
			enemy_weak_turns[index] = 0
			enemy_weak_applied_turn[index] = -1
			enemy_flux_damage[index] = 0
			enemy_flux_turns[index] = 0
			enemy_flux_applied_turn[index] = -1
			enemy_bleed_damage[index] = 0
			enemy_bleed_turns[index] = 0
			enemy_bleed_applied_turn[index] = -1
			enemy_stun_turns[index] = 0
			if index < enemy_death_turns.size() and enemy_death_turns[index] < 0:
				enemy_death_turns[index] = turn_number
			deaths.append(target_name)
			Game.run["stats"]["enemies"] = int(Game.run["stats"].get("enemies", 0)) + 1
			var levels_gained := Game.award_combat_xp(Combat.xp_for(target))
			if levels_gained > 0:
				levels.append("Subes a nivel %d" % Game.player_level())
			if is_instance_valid(actor_portrait):
				actor_portrait.play_effect("defeat")
			if vfx != null:
				vfx.burst(_portrait_center(actor_portrait), "defeat", 1.2)
			Audio.play_sfx("enemy_death")
		else:
			Audio.play_sfx("enemy_hit")
	if touched:
		_refresh_battlefield()
	return {"total": total, "summary": ", ".join(summaries), "deaths": deaths, "levels": levels}


func _apply_enemy_attacks() -> Dictionary:
	var dot := _tick_enemy_damage_over_time()
	var attackers := _living_enemy_indices()
	var attacker_count := attackers.size()
	var total := 0
	var absorbed := 0
	var attacked := false
	var summaries: Array[String] = []
	if String(dot.get("summary", "")) != "":
		summaries.append(String(dot.get("summary", "")))
	var bonus_for_round := enemy_bonus_damage.duplicate()
	var buff_turns_at_start := enemy_bonus_turns.duplicate()
	var vulnerable_for_round := player_vulnerable_bonus
	for index in attackers:
		if Game.hp() <= 0:
			break
		var ability := _enemy_intent_for(index)
		var kind := String(ability.get("kind", "attack"))
		var enemy_name := String(enemies[index].get("name", "Enemigo"))
		if index < enemy_stun_turns.size() and enemy_stun_turns[index] > 0:
			enemy_stun_turns[index] = maxi(0, enemy_stun_turns[index] - 1)
			summaries.append("%s está mutilado y pierde el turno" % enemy_name)
			_play_enemy_support(index, "incorrect")
			continue
		if kind == "idle":
			summaries.append("%s se incorpora al combate" % enemy_name)
			continue
		if kind == "summon":
			var summoned := _summon_enemy(ability)
			if summoned != "":
				summaries.append("%s invoca a %s" % [enemy_name, summoned])
				_play_enemy_support(index, "arcane")
			else:
				summaries.append("%s intenta invocar, pero no hay espacio" % enemy_name)
			continue
		if kind == "defend":
			summaries.append("%s se protege" % enemy_name)
			continue
		if kind == "heal":
			var heal_target := _most_wounded_enemy()
			if heal_target >= 0:
				var healed := mini(int(ability.get("value", 0)), enemy_max_hps[heal_target] - enemy_hps[heal_target])
				healed = maxi(0, healed)
				enemy_hps[heal_target] = enemy_hps[heal_target] + healed
				summaries.append("%s cura %d HP a %s" % [enemy_name, healed, String(enemies[heal_target].get("name", "un aliado"))])
				_play_enemy_support(heal_target, "heal")
			continue
		if kind == "buff":
			var buff := int(ability.get("value", 0))
			enemy_bonus_damage[index] += buff
			enemy_bonus_turns[index] = maxi(enemy_bonus_turns[index], maxi(1, int(ability.get("turns", 1))))
			summaries.append("%s se enfurece (+%d daño)" % [enemy_name, buff])
			_play_enemy_support(index, "correct")
			continue
		if kind == "debuff":
			var debuff_value := int(ability.get("value", 0))
			var debuff_turns := maxi(1, int(ability.get("turns", 1)))
			if String(ability.get("effect", "")) == "weaken":
				player_weaken_pct = maxi(player_weaken_pct, debuff_value)
				player_weaken_turns = maxi(player_weaken_turns, debuff_turns)
			summaries.append("%s te maldice (−%d%% daño, %d turnos)" % [enemy_name, debuff_value, debuff_turns])
			_play_enemy_support(index, "incorrect")
			continue

		attacked = true
		_play_enemy_attack(index)
		var hits := maxi(1, int(ability.get("hits", 1)))
		var received_here := 0
		var absorbed_here := 0
		var bonus := int(bonus_for_round[index]) if index < bonus_for_round.size() else 0
		for _hit in range(hits):
			if Game.hp() <= 0:
				break
			var damage := _weakened_enemy_damage(index, Game.enemy_ability_damage(ability, attacker_count, bonus, vulnerable_for_round))
			var blocked := mini(player_shield, damage)
			player_shield -= blocked
			absorbed += blocked
			absorbed_here += blocked
			var received := damage - blocked
			if received > 0:
				var lost := Game.damage_player(received)
				total += lost
				received_here += lost
		var effect := String(ability.get("effect", ""))
		var drained := 0
		if effect == "drain" and received_here > 0:
			drained = int(roundf(float(received_here) * float(ability.get("value", 0.0))))
			if drained > 0:
				enemy_hps[index] = mini(enemy_max_hps[index], enemy_hps[index] + drained)
		var marked := false
		if effect == "vulnerable":
			player_vulnerable_bonus = maxi(player_vulnerable_bonus, int(ability.get("value", 0)))
			player_vulnerable_turns = maxi(player_vulnerable_turns, maxi(1, int(ability.get("turns", 1))))
			marked = true
		if is_instance_valid(player_portrait):
			player_portrait.play_effect("impact")
		if is_instance_valid(focus_player_portrait):
			focus_player_portrait.play_effect("impact")
		if received_here > 0:
			Audio.play_sfx("player_hit")
		if vfx != null:
			var player_center := _portrait_center(_active_player_portrait())
			var attacker_portrait: FantasyPortrait = enemy_actors[index].portrait if index < enemy_actors.size() else null
			var enemy_center := _portrait_center(attacker_portrait)
			var hit_aim := (player_center - enemy_center).normalized()
			vfx.burst(player_center, "impact", 0.9, hit_aim)
			if received_here > 0:
				vfx.pop_number(player_center, "-%d" % received_here, UIKit.DANGER, 28, Vector2(0, -60))
			elif absorbed_here > 0:
				vfx.pop_number(player_center, "0", UIKit.STEEL, 22, Vector2(0, -60))
		var summary := "%s golpea por %d" % [enemy_name, received_here]
		if hits > 1:
			summary = "%s golpea %d veces por %d" % [enemy_name, hits, received_here]
		if absorbed_here > 0:
			summary += " (escudo −%d)" % absorbed_here
		if drained > 0:
			summary += ", se cura %d" % drained
		if marked:
			summary += ", te marca (+%d de daño)" % int(ability.get("value", 0))
		summaries.append(summary)
	for i in range(enemies.size()):
		if i < buff_turns_at_start.size() and int(buff_turns_at_start[i]) > 0:
			enemy_bonus_turns[i] = maxi(0, enemy_bonus_turns[i] - 1)
			if enemy_bonus_turns[i] == 0:
				enemy_bonus_damage[i] = 0
	return {
		"total": total,
		"absorbed": absorbed,
		"attacked": attacked,
		"summary": ", ".join(summaries),
		"dot_total": int(dot.get("total", 0)),
		"dot_deaths": dot.get("deaths", []),
		"dot_levels": dot.get("levels", []),
	}


func _apply_enemy_attack() -> int:
	return int(_apply_enemy_attacks().get("total", 0))


func _on_timeout() -> void:
	if phase != "select":
		return
	phase = "feedback"
	_set_focus(true)
	var weaken_at_start := player_weaken_turns
	var vulnerable_at_start := player_vulnerable_turns
	var enemy_fragile_before := enemy_fragile_turns.duplicate()
	var enemy_attack_result := _apply_enemy_attacks()
	var dmg := int(enemy_attack_result.get("total", 0))
	var timeout_summary := String(enemy_attack_result.get("summary", ""))
	_tick_player_statuses(weaken_at_start, vulnerable_at_start)
	_tick_enemy_statuses(enemy_fragile_before)
	_tick_enemy_weakness()
	Game.charge_berserk_turn()
	berserk_armed = false
	_clear_phase()
	phase_box.alignment = BoxContainer.ALIGNMENT_CENTER
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	phase_box.add_child(center)
	var card := UIKit.panel(Color(0.055, 0.066, 0.082, 0.96), Color("#5a3138"), true, UIKit.DANGER)
	card.custom_minimum_size = Vector2(780, 0)
	center.add_child(card)
	var cv := UIKit.vbox(8)
	card.add_child(cv)
	var head := UIKit.hbox(12)
	cv.add_child(head)
	head.add_child(UIKit.display_label("⏳", 30, UIKit.DANGER, 600, 0))
	var head_copy := UIKit.vbox(1)
	head_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(head_copy)
	head_copy.add_child(UIKit.eyebrow("El tiempo se agotó", UIKit.DANGER))
	head_copy.add_child(UIKit.heading("La duda tiene un costo", 25, UIKit.DANGER))
	cv.add_child(UIKit.label("Los enemigos aprovechan la duda: %s. Recibes %d de daño." % [timeout_summary, dmg] if dmg > 0 else "Los enemigos se reagrupan: %s. No recibes daño." % timeout_summary, 17, UIKit.TEXT))
	cv.add_child(UIKit.label("El reloj limita la elección del ataque; resolver la pregunta no tiene cronómetro.", 13, UIKit.MUTED))
	var footer := UIKit.hbox(10)
	footer.alignment = BoxContainer.ALIGNMENT_END
	cv.add_child(footer)
	var cont := UIKit.button("Continuar", UIKit.VIOLET_SOFT)
	cont.custom_minimum_size = Vector2(200, 44)
	cont.pressed.connect(_after_feedback)
	footer.add_child(cont)
	_refresh_hud()
func _die() -> void:
	if phase == "dead":
		return
	phase = "dead"
	Game.end_run()
	Audio.play_music("death")
	Audio.play_sfx("death")
	go.emit("death", null)


func _victory() -> void:
	if phase == "victory":
		return
	_ingest_legacy_target_state()
	Audio.play_sfx("victory")
	milestone_victory = _contains_tier("boss")
	var reward_enemy := _reward_enemy()
	var fallen_names: Array[String] = []
	for data in enemies:
		fallen_names.append(String(data.get("name", "Enemigo")))
	Game.run["encounter"] = int(Game.run["encounter"]) + 1
	_refresh_hud()
	phase = "victory"
	_set_focus(true)
	var loot := Combat.roll_loot(reward_enemy, rng, 0.35, String(world.get("id", "")))
	var next_world := Combat.world_for_encounter(int(Game.run.get("encounter", 1)))
	_clear_phase()
	phase_box.alignment = BoxContainer.ALIGNMENT_CENTER
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	phase_box.add_child(center)
	var card := UIKit.panel(Color(0.058, 0.065, 0.078, 0.96), Color("#4b402c"), true, UIKit.GOLD)
	card.custom_minimum_size = Vector2(820, 0)
	center.add_child(card)
	var cv := UIKit.vbox(8)
	card.add_child(cv)
	cv.add_child(UIKit.eyebrow("Encuentro superado · %s" % String(world.get("short", "Pasillo")), UIKit.GOLD))
	var title := UIKit.display_label("Victoria", 38, UIKit.GOLD, 600, 1)
	cv.add_child(title)
	cv.add_child(UIKit.label("Caen: %s. El pasillo respira." % ", ".join(fallen_names), 17, UIKit.TEXT))
	if String(next_world.get("id", "")) != String(world.get("id", "")):
		cv.add_child(UIKit.label("Nuevo umbral: %s. %s" % [
			String(next_world.get("name", "")),
			String(next_world.get("subtitle", "")),
		], 12, UIKit.VIOLET))
	cv.add_child(UIKit.rule(Color(UIKit.STONE, 0.7), 1))

	if loot != "":
		var it := Combat.item(loot)
		var loot_panel := UIKit.panel(Color(0.04, 0.05, 0.062, 0.75), Color(UIKit.GOLD_SOFT, 0.65), false, UIKit.GOLD_SOFT)
		cv.add_child(loot_panel)
		var loot_row := UIKit.hbox(12)
		loot_panel.add_child(loot_row)
		var icon_center := CenterContainer.new()
		loot_row.add_child(icon_center)
		UIKit.add_item_icon(icon_center, loot, Vector2(54, 54), _item_tint(loot))
		var loot_copy := UIKit.vbox(2)
		loot_copy.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		loot_row.add_child(loot_copy)
		loot_copy.add_child(UIKit.eyebrow("Botín encontrado", UIKit.GOLD))
		loot_copy.add_child(UIKit.heading(String(it.get("name", loot)), 19, UIKit.TEXT))
		loot_copy.add_child(UIKit.label(String(it.get("desc", "")), 12, UIKit.STEEL))
		var lore := String(it.get("lore", ""))
		if lore != "":
			var lore_label := UIKit.label("«%s»" % lore, 11, UIKit.MUTED)
			lore_label.max_lines_visible = 2
			loot_copy.add_child(lore_label)
		if Game.inventory_full():
			cv.add_child(UIKit.label("Inventario lleno (4/4). Elegí qué reemplazar.", 13, UIKit.DANGER))
			_render_loot_choice(loot, cv)
			return
		Game.add_item(loot)
		Audio.play_sfx("loot")
	else:
		cv.add_child(UIKit.label("Sin botín esta vez. El pasillo no siempre recompensa.", 14, UIKit.MUTED))
	_render_advance_button(cv)


func _reward_enemy() -> Dictionary:
	var priority := {"weak": 0, "ordinary": 1, "strong": 2, "elite": 3, "miniboss": 4, "boss": 5}
	var best: Dictionary = enemies[0] if not enemies.is_empty() else enemy
	for data in enemies:
		if int(priority.get(String(data.get("tier", "weak")), 0)) > int(priority.get(String(best.get("tier", "weak")), 0)):
			best = data
	return best


func _render_loot_choice(loot: String, parent: Control = null) -> void:
	var host: Control = parent if parent != null else phase_box
	var grid := GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	host.add_child(grid)
	var inv: Array = Game.inventory()
	for i in range(inv.size()):
		var old_id: String = inv[i]
		var b := UIKit.button("Reemplazar %s" % String(Combat.item(old_id).get("name", old_id)), UIKit.BURGUNDY)
		b.custom_minimum_size = Vector2(350, 40)
		b.add_theme_font_size_override("font_size", 13)
		b.pressed.connect(Callable(self, "_replace_loot").bind(old_id, loot))
		grid.add_child(b)
	var discard := UIKit.button("Descartar botín", UIKit.STEEL_DARK)
	discard.custom_minimum_size = Vector2(0, 40)
	discard.pressed.connect(_after_loot)
	host.add_child(discard)


func _replace_loot(old_id: String, loot: String) -> void:
	Game.discard_item(old_id)
	if Game.add_item(loot):
		Audio.play_sfx("loot")
	_after_loot()


func _after_loot() -> void:
	_clear_phase()
	phase_box.alignment = BoxContainer.ALIGNMENT_CENTER
	var center := CenterContainer.new()
	center.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	center.size_flags_vertical = Control.SIZE_EXPAND_FILL
	phase_box.add_child(center)
	var card := UIKit.panel(Color(0.055, 0.065, 0.082, 0.96), Color("#3d4652"), true, UIKit.GOLD_SOFT)
	card.custom_minimum_size = Vector2(660, 0)
	center.add_child(card)
	var cv := UIKit.vbox(8)
	card.add_child(cv)
	cv.add_child(UIKit.eyebrow("Botín resuelto", UIKit.GOLD))
	cv.add_child(UIKit.heading("La mochila está en orden", 24, UIKit.TEXT))
	cv.add_child(UIKit.label("Podés seguir descendiendo cuando quieras.", 13, UIKit.MUTED))
	_render_advance_button(cv)


func _render_advance_button(parent: Control = null) -> void:
	var host: Control = parent if parent != null else phase_box
	var row := UIKit.hbox(10)
	row.alignment = BoxContainer.ALIGNMENT_END
	host.add_child(row)
	var cont := UIKit.button("Continuar", UIKit.VIOLET_SOFT)
	cont.custom_minimum_size = Vector2(200, 44)
	cont.pressed.connect(_advance)
	row.add_child(cont)
func _advance() -> void:
	if phase != "victory":
		return
	phase = "transition"
	if milestone_victory:
		Game.end_run(true)
		Audio.play_music("menu")
		go.emit("victory", null)
		return
	var enc := int(Game.run.get("encounter", 1))
	if Game.is_blacksmith_encounter(enc):
		Audio.play_music("blacksmith")
		go.emit("blacksmith", null)
		return
	if Game.should_spawn_angel(enc, rng):
		Audio.play_music("angel")
		go.emit("angel", null)
		return
	Audio.play_music("boss" if enc % 10 == 0 else "combat")
	go.emit("combat", null)


# --------------------------------------------------------------- inventario

func _show_inventory() -> void:
	if overlay != null and is_instance_valid(overlay):
		return
	overlay = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 30
	add_child(overlay)
	overlay.add_child(UIKit.dimmer())

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var panel := UIKit.panel(Color(0.045, 0.055, 0.07, 0.98), Color("#4a4232"), true, UIKit.GOLD)
	panel.custom_minimum_size = Vector2(880, 592)
	center.add_child(panel)
	var v := UIKit.vbox(8)
	panel.add_child(v)

	var head := UIKit.hbox(12)
	v.add_child(head)
	var head_copy := UIKit.vbox(1)
	head.add_child(head_copy)
	head_copy.add_child(UIKit.eyebrow("Equipo y botín", UIKit.GOLD))
	head_copy.add_child(UIKit.display_label("Inventario", 30, UIKit.TEXT, 600, 0))
	var inv: Array = Game.inventory()
	var head_spacer := Control.new()
	head_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(head_spacer)
	var count_badge := UIKit.badge("%d / 4 CARGADOS" % inv.size(), UIKit.STEEL_DARK if inv.size() < 4 else UIKit.DANGER, 10)
	head.add_child(count_badge)
	v.add_child(UIKit.label("El equipo puesto no ocupa lugar. Podés cargar hasta cuatro objetos.", 12, UIKit.MUTED))
	v.add_child(UIKit.rule(Color(UIKit.STONE, 0.7), 1))

	var eq_head := UIKit.hbox(10)
	v.add_child(eq_head)
	eq_head.add_child(UIKit.eyebrow("EQUIPO PUESTO", UIKit.STEEL_DARK))
	eq_head.add_child(UIKit.rule(Color(UIKit.STONE, 0.55), 1))
	var eq: Dictionary = Game.run.get("equipped", {})
	var eq_row := UIKit.hbox(7)
	v.add_child(eq_row)
	for slot in EQUIPMENT_SLOTS:
		eq_row.add_child(_equipment_slot_card(slot, String(eq.get(slot, ""))))

	v.add_child(UIKit.rule(Color(UIKit.STONE, 0.7), 1))
	var inv_head := UIKit.hbox(10)
	v.add_child(inv_head)
	inv_head.add_child(UIKit.eyebrow("MOCHILA", UIKit.STEEL_DARK))
	inv_head.add_child(UIKit.rule(Color(UIKit.STONE, 0.55), 1))
	var grid := GridContainer.new()
	grid.columns = 2
	grid.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	grid.size_flags_vertical = Control.SIZE_EXPAND_FILL
	grid.add_theme_constant_override("h_separation", 8)
	grid.add_theme_constant_override("v_separation", 8)
	v.add_child(grid)
	for i in range(4):
		var item_id := String(inv[i]) if i < inv.size() else ""
		grid.add_child(_inventory_item_card(item_id, i))

	var footer := UIKit.hbox(10)
	v.add_child(footer)
	footer.add_child(UIKit.inline_label("Los objetos no equipados se pierden al morir.", 11, UIKit.STEEL_DARK))
	var foot_spacer := Control.new()
	foot_spacer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	footer.add_child(foot_spacer)
	var close := UIKit.button("Cerrar", UIKit.BURGUNDY)
	close.custom_minimum_size = Vector2(140, 40)
	close.pressed.connect(_close_overlay)
	footer.add_child(close)


func _equipment_slot_card(slot: String, item_id: String) -> Control:
	var card := UIKit.panel(Color(0.06, 0.07, 0.085, 0.9), Color("#343d49"), false, UIKit.GOLD_SOFT)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(0, 76)
	var row := UIKit.hbox(9)
	card.add_child(row)
	var icon_center := CenterContainer.new()
	row.add_child(icon_center)
	UIKit.add_item_icon(icon_center, item_id, Vector2(46, 46), _item_tint(item_id))
	var info := UIKit.vbox(1)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	info.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_child(info)
	info.add_child(UIKit.eyebrow(String(EQUIPMENT_SLOT_LABELS[slot]), UIKit.STEEL_DARK))
	var item_name := "Vacío" if item_id == "" else String(Combat.item(item_id).get("name", item_id))
	info.add_child(UIKit.label(item_name, 14, UIKit.STEEL if item_id == "" else UIKit.TEXT, 500))
	return card


func _inventory_item_card(item_id: String, index: int) -> Control:
	var card := UIKit.panel(Color(0.06, 0.07, 0.085, 0.92), Color("#343d49") if item_id != "" else Color("#28303a"), item_id != "", UIKit.GOLD_SOFT)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	card.size_flags_vertical = Control.SIZE_EXPAND_FILL
	card.custom_minimum_size = Vector2(0, 126)
	var cv := UIKit.vbox(5)
	card.add_child(cv)
	if item_id == "":
		cv.add_child(UIKit.eyebrow("RANURA %d" % (index + 1), UIKit.STEEL_DARK))
		cv.add_child(UIKit.label("Vacío", 16, UIKit.STEEL_DARK, 500))
		cv.add_child(UIKit.label("El próximo botín puede ocupar este lugar.", 11, UIKit.STEEL_DARK))
		return card
	var it := Combat.item(item_id)
	var row := UIKit.hbox(9)
	cv.add_child(row)
	var icon_center := CenterContainer.new()
	row.add_child(icon_center)
	UIKit.add_item_icon(icon_center, item_id, Vector2(56, 56), _item_tint(item_id))
	var info := UIKit.vbox(1)
	info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	row.add_child(info)
	var slot := String(it.get("slot", ""))
	var slot_label := String(EQUIPMENT_SLOT_LABELS.get(slot, "Consumible"))
	info.add_child(UIKit.eyebrow(slot_label.to_upper(), UIKit.GOLD_SOFT))
	info.add_child(UIKit.label(String(it.get("name", item_id)), 15, UIKit.TEXT, 500))
	var desc := UIKit.label(String(it.get("desc", "")), 10, UIKit.STEEL)
	desc.max_lines_visible = 2
	info.add_child(desc)
	var lore := String(it.get("lore", ""))
	if lore != "":
		var lore_label := UIKit.label("«%s»" % lore, 9, UIKit.MUTED)
		lore_label.max_lines_visible = 1
		info.add_child(lore_label)
	var actions := UIKit.hbox(5)
	cv.add_child(actions)
	if slot in ["weapon", "armor", "relic"]:
		var equip := UIKit.button("Equipar", UIKit.VIOLET_SOFT)
		equip.custom_minimum_size = Vector2(92, 30)
		equip.add_theme_font_size_override("font_size", 11)
		equip.pressed.connect(func() -> void:
			Game.equip_item(item_id)
			_close_overlay()
			_refresh_hud()
			_show_inventory())
		actions.add_child(equip)
	elif slot == "consumable":
		var use := UIKit.button("Usar", UIKit.OK)
		use.custom_minimum_size = Vector2(92, 30)
		use.add_theme_font_size_override("font_size", 11)
		use.pressed.connect(func() -> void:
			Game.use_consumable(item_id)
			_close_overlay()
			_refresh_hud()
			_show_inventory())
		actions.add_child(use)
	var discard := UIKit.button("Tirar", UIKit.STEEL_DARK)
	discard.custom_minimum_size = Vector2(78, 30)
	discard.add_theme_font_size_override("font_size", 11)
	discard.pressed.connect(func() -> void:
		Game.discard_item(item_id)
		_close_overlay()
		_show_inventory())
	actions.add_child(discard)
	return card


func _close_overlay() -> void:
	if overlay != null and is_instance_valid(overlay):
		overlay.queue_free()
	overlay = null
	if phase == "solve" and input != null and is_instance_valid(input):
		input.grab_focus()


func _open_system_overlay(min_size: Vector2) -> VBoxContainer:
	if overlay != null and is_instance_valid(overlay):
		overlay.queue_free()
	if input != null and is_instance_valid(input) and input.has_focus():
		input.release_focus()
	overlay = Control.new()
	overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 30
	add_child(overlay)
	overlay.add_child(UIKit.dimmer())
	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(center)
	var panel := UIKit.panel(Color(0.045, 0.055, 0.07, 0.98), Color("#4a4232"), true, UIKit.GOLD)
	panel.custom_minimum_size = min_size
	center.add_child(panel)
	var v := UIKit.vbox(10)
	panel.add_child(v)
	return v


func _show_system_menu() -> void:
	var v := _open_system_overlay(Vector2(600, 0))
	v.add_child(UIKit.eyebrow("Pausa · Encuentro %d" % int(Game.run.get("encounter", 1)), UIKit.GOLD))
	v.add_child(UIKit.display_label("Menú", 32, UIKit.TEXT, 600, 0))
	v.add_child(UIKit.label("%s · Nivel %d · %d/%d HP" % [
		String(world.get("name", "La Cripta")),
		Game.player_level(),
		Game.hp(),
		Game.max_hp(),
	], 13, UIKit.STEEL))
	v.add_child(UIKit.rule(Color(UIKit.STONE, 0.7), 1))
	var resume := _menu_action("Reanudar combate", UIKit.STEEL_DARK)
	resume.pressed.connect(_close_overlay)
	v.add_child(resume)
	var end_btn := _menu_action("Terminar run", UIKit.DANGER)
	end_btn.pressed.connect(_show_end_run_confirm)
	v.add_child(end_btn)
	v.add_child(UIKit.label("Terminar la run la cierra sin victoria y vuelve al menú principal. La maestría se conserva.", 11, UIKit.MUTED))


func _show_end_run_confirm() -> void:
	var v := _open_system_overlay(Vector2(600, 0))
	v.add_child(UIKit.eyebrow("Confirmar", UIKit.DANGER))
	v.add_child(UIKit.display_label("¿Terminar la run?", 28, UIKit.TEXT, 600, 0))
	v.add_child(UIKit.label("Cerrás la expedición en el Encuentro %d y perdés el botín y el progreso de esta run." % int(Game.run.get("encounter", 1)), 13, UIKit.STEEL))
	v.add_child(UIKit.rule(Color(UIKit.STONE, 0.7), 1))
	var row := UIKit.hbox(10)
	v.add_child(row)
	var cancel := _menu_action("Cancelar", UIKit.STEEL_DARK)
	cancel.pressed.connect(_show_system_menu)
	row.add_child(cancel)
	var confirm := _menu_action("Terminar run", UIKit.DANGER)
	confirm.pressed.connect(_end_run_now)
	row.add_child(confirm)


func _menu_action(text: String, accent: Color) -> Button:
	var b := UIKit.button(text, accent)
	b.custom_minimum_size = Vector2(0, 42)
	b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	b.add_theme_font_size_override("font_size", 14)
	return b


func _end_run_now() -> void:
	Game.end_run(false, "abandon")
	_close_overlay()
	go.emit("menu", null)
