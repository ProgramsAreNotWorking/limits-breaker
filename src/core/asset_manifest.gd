class_name AssetManifest
extends RefCounted
## Contrato estable para los PNG estáticos de runtime y los recursos de audio del juego.
## Regla de arte: no se cargan sprites animados ni video; la animación vive en la UI y las partículas.

const MUSIC_FILES := {
	"menu": "res://assets/audio/music/music_menu.wav",
	"combat": "res://assets/audio/music/music_combat.wav",
	"boss": "res://assets/audio/music/music_boss.wav",
	"blacksmith": "res://assets/audio/music/music_blacksmith.wav",
	"angel": "res://assets/audio/music/music_angel.wav",
	"death": "res://assets/audio/music/music_game_over.wav",
}

const SFX_FILES := {
	"select": "res://assets/audio/sfx/sfx_select.wav",
	"confirm": "res://assets/audio/sfx/sfx_confirm.wav",
	"correct": "res://assets/audio/sfx/sfx_answer_correct.wav",
	"incorrect": "res://assets/audio/sfx/sfx_answer_incorrect.wav",
	"attack": "res://assets/audio/sfx/sfx_attack.wav",
	"arcane": "res://assets/audio/sfx/sfx_attack_arcane.wav",
	"player_hit": "res://assets/audio/sfx/sfx_player_hit.wav",
	"enemy_hit": "res://assets/audio/sfx/sfx_enemy_hit.wav",
	"heal": "res://assets/audio/sfx/sfx_heal.wav",
	"enemy_death": "res://assets/audio/sfx/sfx_enemy_death.wav",
	"loot": "res://assets/audio/sfx/sfx_loot.wav",
	"equipment": "res://assets/audio/sfx/sfx_equipment.wav",
	"blacksmith": "res://assets/audio/sfx/sfx_blacksmith.wav",
	"angel": "res://assets/audio/sfx/sfx_angel_appearance.wav",
	"boss": "res://assets/audio/sfx/sfx_boss_appearance.wav",
	"death": "res://assets/audio/sfx/sfx_death.wav",
	"victory": "res://assets/audio/sfx/sfx_victory.wav",
}

const ITEM_ART := {
	"rusted_blade": "res://assets/art/icons/items/rusted_blade.png",
	"ashen_edge": "res://assets/art/icons/items/ashen_edge.png",
	"arcane_staff": "res://assets/art/icons/items/arcane_staff.png",
	"iron_cuirass": "res://assets/art/icons/items/iron_cuirass.png",
	"warden_plate": "res://assets/art/icons/items/warden_plate.png",
	"oak_shield": "res://assets/art/icons/items/oak_shield.png",
	"ember_charm": "res://assets/art/icons/items/ember_charm.png",
	"void_sigil": "res://assets/art/icons/items/void_sigil.png",
	"pilgrim_relic": "res://assets/art/icons/items/pilgrim_relic.png",
	"healing_draught": "res://assets/art/icons/items/healing_draught.png",
	"greater_draught": "res://assets/art/icons/items/greater_draught.png",
	# Los objetos de la ampliación reutilizan los maestros de icono existentes
	# y se distinguen con el tinte de runtime definido en Combat.ITEMS.
	"oathbrand": "res://assets/art/icons/items/rusted_blade.png",
	"cinder_maul": "res://assets/art/icons/items/ashen_edge.png",
	"mirror_needle": "res://assets/art/icons/items/arcane_staff.png",
	"ash_mantle": "res://assets/art/icons/items/iron_cuirass.png",
	"mirror_scale": "res://assets/art/icons/items/oak_shield.png",
	"choir_plate": "res://assets/art/icons/items/warden_plate.png",
	"bell_fragment": "res://assets/art/icons/items/pilgrim_relic.png",
	"rift_ember": "res://assets/art/icons/items/ember_charm.png",
	"hollow_eye": "res://assets/art/icons/items/void_sigil.png",
	"ash_salve": "res://assets/art/icons/items/healing_draught.png",
	"fading_elixir": "res://assets/art/icons/items/greater_draught.png",
}

const ENVIRONMENTS := {
	"menu": "res://assets/art/environments/menu.png",
	"dungeon": "res://assets/art/environments/dungeon.png",
	"boss_arena": "res://assets/art/environments/boss-arena.png",
	"forge": "res://assets/art/environments/forge.png",
	"angel": "res://assets/art/environments/angel.png",
	"death": "res://assets/art/environments/death.png",
}

const CHARACTER_ART := {
	"player": "res://assets/art/characters/player.png",
	"skeleton": "res://assets/art/characters/skeleton.png",
	"brigand": "res://assets/art/characters/brigand.png",
	"warden": "res://assets/art/characters/warden.png",
	"cultist": "res://assets/art/characters/cultist.png",
	"colossus": "res://assets/art/characters/colossus.png",
	"limitless": "res://assets/art/characters/limitless.png",
	"blacksmith": "res://assets/art/characters/blacksmith.png",
	"angel": "res://assets/art/characters/angel.png",
}

const CUTOUT_CHARACTER_ART: Array[String] = [
	"player",
	"skeleton",
	"brigand",
	"warden",
	"cultist",
	"colossus",
	"limitless",
	"blacksmith",
	"angel",
]

const EFFECT_ART := {
	"slash": "res://assets/art/effects/slash.png",
	"arcane": "res://assets/art/effects/arcane.png",
	"critical": "res://assets/art/effects/critical.png",
	"impact": "res://assets/art/effects/impact.png",
	"heal": "res://assets/art/effects/heal.png",
	"defeat": "res://assets/art/effects/defeat.png",
	"correct": "res://assets/art/effects/correct.png",
	"incorrect": "res://assets/art/effects/incorrect.png",
	"forge_spark": "res://assets/art/effects/forge_spark.png",
	"particle": "res://assets/art/effects/particle.png",
}

const CHARACTERS := {
	"player": "player",
	"blacksmith": "blacksmith",
	"angel": "angel",
}

const ENEMIES := {
	"skeleton": "skeleton",
	"brigand": "brigand",
	"warden": "warden",
	"cultist": "cultist",
	"colossus": "colossus",
	"limitless": "limitless",
	# Ampliación: cada enemigo usa un maestro PNG existente y un tinte de
	# runtime distinto, sin sprites animados ni imágenes nuevas.
	"oath_acolyte": "cultist",
	"bone_pilgrim": "skeleton",
	"ash_brigand": "brigand",
	"cinder_warden": "warden",
	"slag_priest": "cultist",
	"hollow_choir": "cultist",
	"bell_keeper": "cultist",
	"mirror_scholar": "angel",
	"rift_sentinel": "warden",
}


static func item_icon(item_id: String) -> String:
	return item_art(item_id)


static func environment(scene_id: String) -> String:
	return String(ENVIRONMENTS.get(scene_id, ""))


static func character(character_id: String) -> String:
	return String(CHARACTERS.get(character_id, ""))


static func character_art(character_id: String) -> String:
	return String(CHARACTER_ART.get(character_id, ""))


static func is_cutout_character_art(character_id: String) -> bool:
	return character_id in CUTOUT_CHARACTER_ART


static func enemy(enemy_id: String) -> String:
	return String(ENEMIES.get(enemy_id, ""))


static func item_art(item_id: String) -> String:
	return String(ITEM_ART.get(item_id, ""))


static func effect_art(effect_id: String) -> String:
	var key := effect_id
	match effect_id:
		"attack":
			key = "slash"
		"hit":
			key = "impact"
		"spark":
			key = "forge_spark"
	return String(EFFECT_ART.get(key, ""))


static func has_item_art(item_id: String) -> bool:
	return item_id in ITEM_ART
