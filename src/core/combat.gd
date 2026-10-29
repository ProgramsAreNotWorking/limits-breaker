class_name Combat
extends RefCounted

# Valores base. Los tests verifican que estas relaciones se cumplan.
const BASELINE_DAMAGE := [8, 14, 22, 27]
const FAIL_SELF_PCT := [0.0, 0.0, 0.10, 0.20]
const DIFF_NAMES := ["Fácil", "Intermedio", "Avanzado", "Superdifícil"]
const MAX_ENEMIES_PER_ENCOUNTER := 4
const MAX_PLAYER_LEVEL := 10

# Cada técnica combina tipo de daño, potencia, penetración, objetivos y una
# inclinación de dificultad. El resultado matemático se sortea al prepararla.
const ATTACK_IDS := ["piercing_strike", "sweeping_cut", "arcane_lance", "arcane_nova"]
const PLAYER_ATTACKS := {
	"piercing_strike": {
		"name": "Tajo perforante", "type": "physical", "power": 1.0,
		"targets": 1, "penetration": 2, "difficulty_shift": 1,
		"description": "Golpe físico preciso. Atraviesa 2 puntos de armadura.",
	},
	"sweeping_cut": {
		"name": "Barrido", "type": "physical", "power": 0.78,
		"targets": 2, "penetration": 0, "difficulty_shift": 0,
		"description": "Ataque físico amplio: alcanza hasta 2 enemigos.",
	},
	"arcane_lance": {
		"name": "Lanza arcana", "type": "magic", "power": 1.1,
		"targets": 1, "penetration": 1, "difficulty_shift": 2,
		"description": "Daño mágico concentrado; atraviesa 1 punto de resistencia mágica.",
	},
	"arcane_nova": {
		"name": "Nova astral", "type": "magic", "power": 0.54,
		"targets": MAX_ENEMIES_PER_ENCOUNTER, "penetration": 0, "difficulty_shift": -1,
		"description": "Daño mágico de área; alcanza a todos los enemigos vivos.",
	},
}

const BERSERK_CHARGE_ROUNDS := 7
const BERSERK_HIT_MULTIPLIER := 1.5
const BERSERK_MISS_MULTIPLIER := 0.4

# El reloj de selección lo impone el enemigo, no un ajuste manual. Las bandas
# no se solapan: un enemigo más peligroso siempre ofrece menos tiempo.
const SELECT_TIME_BY_TIER := {
	"weak": [18.0, 22.0],
	"ordinary": [15.0, 17.5],
	"strong": [12.0, 14.5],
	"elite": [10.0, 11.5],
	"miniboss": [8.0, 9.5],
	"boss": [6.0, 7.5],
}

# Los tres umbrales de la expedición y el trono final. El encuentro 5 sigue
# siendo el miniboss fijo y el 10 el jefe, para conservar el ritmo probado.
const WORLDS := [
	{
		"id": "crypt", "index": 1, "name": "Cripta de los Juramentos",
		"short": "Cripta", "subtitle": "Ecos de un juramento que nadie recuerda.",
		"environment": "dungeon", "accent": "#8c78d6", "tint": "#c8bfd8", "glow": 0.58,
		"min_encounter": 1, "max_encounter": 3,
		"pool": ["skeleton", "oath_acolyte", "bone_pilgrim", "brigand"],
		"elite_pool": [],
	},
	{
		"id": "ash", "index": 2, "name": "Galerías de Ceniza",
		"short": "Ceniza", "subtitle": "La fragua sigue caliente aunque nadie la alimente.",
		"environment": "forge", "accent": "#d8ad60", "tint": "#e0b48f", "glow": 0.62,
		"min_encounter": 4, "max_encounter": 6,
		"pool": ["ash_brigand", "cinder_warden", "warden"],
		"elite_pool": ["slag_priest"],
	},
	{
		"id": "bell", "index": 3, "name": "Santuario de la Campana Rota",
		"short": "Campana", "subtitle": "Alguien tocó la campana y el silencio respondió.",
		"environment": "angel", "accent": "#8fb4cf", "tint": "#a9c2dc", "glow": 0.50,
		"min_encounter": 7, "max_encounter": 9,
		"pool": ["hollow_choir", "rift_sentinel", "bone_pilgrim"],
		"elite_pool": ["bell_keeper", "mirror_scholar"],
	},
	{
		"id": "throne", "index": 4, "name": "Trono del Innombrable",
		"short": "Trono", "subtitle": "El pasillo termina donde empieza su forma.",
		"environment": "boss_arena", "accent": "#c34d64", "tint": "#d0a2ae", "glow": 0.48,
		"min_encounter": 10, "max_encounter": 999,
		"pool": ["limitless"],
		"elite_pool": [],
	},
]

const ENEMIES := [
	{
		"id": "skeleton", "name": "Esqueleto de Cripta", "tier": "weak",
		"hp": 15, "attack": 6, "armor": 0, "tier_label": "Débil",
		"weaknesses": {"magic": 1.25},
		"desc": "Huesos viejos sostenidos por rencor. Frágil, pero no perdona un error.",
	},
	{
		"id": "brigand", "name": "Bandido de la Marca", "tier": "ordinary",
		"hp": 30, "attack": 9, "armor": 0, "tier_label": "Ordinario",
		"weaknesses": {"magic": 1.15},
		"desc": "Acero oxidado y una sonrisa torcida. Vive de lo que arranca a los caídos.",
	},
	{
		"id": "warden", "name": "Guardián de Hierro", "tier": "strong",
		"hp": 45, "attack": 12, "armor": 2, "tier_label": "Fuerte",
		"weaknesses": {"magic": 1.25},
		"desc": "Una armadura vacía que sigue cumpliendo una orden olvidada.",
	},
	{
		"id": "cultist", "name": "Cultista Carmesí", "tier": "elite",
		"hp": 48, "attack": 15, "armor": 1, "tier_label": "Élite",
		"magic_resist": 2, "weaknesses": {"physical": 1.2},
		"desc": "Dibuja símbolos con ceniza. Su dios no responde, pero algo sí.",
	},
	{
		"id": "colossus", "name": "Coloso de Hueso", "tier": "miniboss",
		"hp": 90, "attack": 18, "armor": 3, "tier_label": "Miniboss",
		"weaknesses": {"magic": 1.25},
		"desc": "Se alza despacio, como si el pasillo entero se pusiera de pie.",
	},
	{
		"id": "limitless", "name": "El Innombrable", "tier": "boss",
		"hp": 150, "attack": 22, "armor": 4, "tier_label": "Jefe",
		"magic_resist": 1,
		"desc": "No tiene forma fija. Cada vez que lo miras, se parece un poco más a ti.",
	},
	# Umbral I · Cripta de los Juramentos
	{
		"id": "oath_acolyte", "name": "Acólito del Juramento", "tier": "weak",
		"hp": 18, "attack": 7, "armor": 0, "tier_label": "Débil",
		"tint": "#d8c79a", "weaknesses": {"physical": 1.15},
		"desc": "Canta una promesa que la cripta contesta con polvo.",
	},
	{
		"id": "bone_pilgrim", "name": "Peregrino de Hueso", "tier": "ordinary",
		"hp": 28, "attack": 8, "armor": 0, "tier_label": "Ordinario",
		"tint": "#b9c9a8", "weaknesses": {"magic": 1.2},
		"desc": "Camina hacia una reliquia que ya no está en ninguna parte.",
	},
	# Umbral II · Galerías de Ceniza
	{
		"id": "ash_brigand", "name": "Bandido de Ceniza", "tier": "ordinary",
		"hp": 34, "attack": 10, "armor": 0, "tier_label": "Ordinario",
		"tint": "#d9a07e", "weaknesses": {"magic": 1.15},
		"desc": "Robó una brasa y desde entonces la brasa lo sigue.",
	},
	{
		"id": "cinder_warden", "name": "Guardián de Brasas", "tier": "strong",
		"hp": 50, "attack": 13, "armor": 2, "tier_label": "Fuerte",
		"tint": "#e09a6c", "weaknesses": {"magic": 1.3},
		"desc": "Su armadura conserva el calor de una fragua muerta.",
	},
	{
		"id": "slag_priest", "name": "Sacerdote de Escoria", "tier": "elite",
		"hp": 56, "attack": 16, "armor": 1, "tier_label": "Élite",
		"tint": "#e7b07a", "magic_resist": 2, "weaknesses": {"physical": 1.2},
		"desc": "Predica desde el horno. Nadie sabe a quién escucha.",
	},
	# Umbral III · Santuario de la Campana Rota
	{
		"id": "hollow_choir", "name": "Coro Hueco", "tier": "ordinary",
		"hp": 32, "attack": 9, "armor": 0, "tier_label": "Ordinario",
		"tint": "#c9c1d8", "weaknesses": {"magic": 1.25},
		"desc": "No tiene bocas, pero repite el nombre de la campana.",
	},
	{
		"id": "bell_keeper", "name": "Guardiana de la Campana", "tier": "elite",
		"hp": 58, "attack": 16, "armor": 2, "tier_label": "Élite",
		"tint": "#d8c48e", "magic_resist": 1, "weaknesses": {"physical": 1.15},
		"desc": "No toca la campana. Solo escucha lo que responde.",
	},
	{
		"id": "mirror_scholar", "name": "Erudito del Espejo", "tier": "elite",
		"hp": 54, "attack": 15, "armor": 2, "tier_label": "Élite",
		"tint": "#a9c9e6", "magic_resist": 2, "weaknesses": {"physical": 1.25},
		"desc": "Aprendió a repetir cada límite que alguien rompe.",
	},
	{
		"id": "rift_sentinel", "name": "Centinela de la Grieta", "tier": "strong",
		"hp": 52, "attack": 14, "armor": 3, "tier_label": "Fuerte",
		"tint": "#b9a6e8", "weaknesses": {"magic": 1.2},
		"desc": "Vigila una grieta que no debería existir.",
	},
]

const ITEMS := {
	"rusted_blade": {
		"name": "Hoja Oxidada", "slot": "weapon", "rarity": "common",
		"damage": 2, "desc": "+2 de daño a todos los ataques.",
	},
	"ashen_edge": {
		"name": "Hacha de Ceniza", "slot": "weapon", "rarity": "rare",
		"damage": 4, "desc": "+4 de daño. Cabeza de hierro oscuro, templada en la fragua.",
	},
	"arcane_staff": {
		"name": "Báculo Arcano", "slot": "weapon", "rarity": "rare",
		"damage": 1, "spell": 4, "desc": "+1 de daño; +4 extra en Avanzado y Superdifícil.",
	},
	"iron_cuirass": {
		"name": "Coraza de Hierro", "slot": "armor", "rarity": "common",
		"max_hp": 15, "desc": "+15 HP máximo.",
	},
	"warden_plate": {
		"name": "Placa del Guardián", "slot": "armor", "rarity": "rare",
		"max_hp": 25, "defense": 1, "desc": "+25 HP máximo y +1 de defensa.",
	},
	"oak_shield": {
		"name": "Escudo de Roble", "slot": "armor", "rarity": "common",
		"defense": 2, "desc": "+2 de defensa.",
	},
	"ember_charm": {
		"name": "Talismán de Brasa", "slot": "relic", "rarity": "common",
		"damage": 2, "desc": "+2 de daño.",
	},
	"void_sigil": {
		"name": "Sigilo del Vacío", "slot": "relic", "rarity": "rare",
		"defense": 2, "desc": "+2 de defensa.",
	},
	"pilgrim_relic": {
		"name": "Reliquia del Peregrino", "slot": "relic", "rarity": "common",
		"max_hp": 10, "desc": "+10 HP máximo.",
	},
	"healing_draught": {
		"name": "Bremaje Curativo", "slot": "consumable", "rarity": "common",
		"heal": 30, "desc": "Restaura 30 HP. Se consume.",
	},
	"greater_draught": {
		"name": "Bremaje Mayor", "slot": "consumable", "rarity": "rare",
		"heal": 60, "desc": "Restaura 60 HP. Se consume.",
	},
	# Objetos de los nuevos umbrales. Comparten maestros PNG existentes y se
	# distinguen con un tinte de runtime; no se añaden imágenes nuevas.
	"oathbrand": {
		"name": "Filo del Juramento", "slot": "weapon", "rarity": "rare",
		"damage": 3, "spell": 2, "tint": "#d9c48c",
		"desc": "+3 de daño; +2 extra en Avanzado y Superdifícil.",
	},
	"cinder_maul": {
		"name": "Mazo de Ceniza", "slot": "weapon", "rarity": "rare",
		"damage": 5, "tint": "#d9a06c",
		"desc": "+5 de daño. El mango todavía está tibio.",
	},
	"mirror_needle": {
		"name": "Aguja de Espejo", "slot": "weapon", "rarity": "rare",
		"damage": 1, "spell": 5, "tint": "#a9c9e6",
		"desc": "+1 de daño; +5 extra en Avanzado y Superdifícil.",
	},
	"ash_mantle": {
		"name": "Manto de Ceniza", "slot": "armor", "rarity": "rare",
		"max_hp": 18, "defense": 1, "tint": "#d9a06c",
		"desc": "+18 HP máximo y +1 de defensa.",
	},
	"mirror_scale": {
		"name": "Escama de Espejo", "slot": "armor", "rarity": "rare",
		"max_hp": 12, "defense": 1, "tint": "#a9c9e6",
		"desc": "+12 HP máximo y +1 de defensa.",
	},
	"choir_plate": {
		"name": "Placa del Coro", "slot": "armor", "rarity": "rare",
		"max_hp": 22, "defense": 1, "tint": "#c9c1d8",
		"desc": "+22 HP máximo y +1 de defensa.",
	},
	"bell_fragment": {
		"name": "Fragmento de Campana", "slot": "relic", "rarity": "rare",
		"max_hp": 15, "damage": 1, "tint": "#d8c48e",
		"desc": "+15 HP máximo y +1 de daño.",
	},
	"rift_ember": {
		"name": "Brasa de la Grieta", "slot": "relic", "rarity": "rare",
		"damage": 3, "tint": "#b9a6e8",
		"desc": "+3 de daño. No ilumina, pero calienta los dedos.",
	},
	"hollow_eye": {
		"name": "Ojo Hueco", "slot": "relic", "rarity": "rare",
		"max_hp": 8, "defense": 2, "tint": "#a9c9e6",
		"desc": "+8 HP máximo y +2 de defensa.",
	},
	"ash_salve": {
		"name": "Ungüento de Ceniza", "slot": "consumable", "rarity": "common",
		"heal": 25, "tint": "#d9a06c", "desc": "Restaura 25 HP. Se consume.",
	},
	"fading_elixir": {
		"name": "Elixir Evanescente", "slot": "consumable", "rarity": "rare",
		"heal": 75, "tint": "#b9a6e8", "desc": "Restaura 75 HP. Se consume.",
	},
}

const LOOT_BY_TIER := {
	"weak": ["rusted_blade", "healing_draught", "pilgrim_relic", "ash_salve"],
	"ordinary": ["iron_cuirass", "oak_shield", "healing_draught", "ember_charm", "ash_salve"],
	"strong": [
		"ashen_edge", "warden_plate", "void_sigil", "greater_draught",
		"oathbrand", "cinder_maul", "ash_mantle", "mirror_scale", "fading_elixir",
	],
	"elite": [
		"arcane_staff", "warden_plate", "ember_charm", "greater_draught",
		"mirror_needle", "choir_plate", "bell_fragment", "fading_elixir",
	],
	"miniboss": [
		"ashen_edge", "arcane_staff", "void_sigil", "greater_draught",
		"rift_ember", "hollow_eye", "choir_plate",
	],
	"boss": [
		"ashen_edge", "arcane_staff", "warden_plate", "void_sigil",
		"rift_ember", "mirror_needle", "hollow_eye",
	],
}

# Botín temático de cada umbral. Se sortea antes de caer al botín por tier.
const WORLD_LOOT := {
	"crypt": ["oathbrand", "ash_salve", "pilgrim_relic", "healing_draught"],
	"ash": ["cinder_maul", "ash_mantle", "ash_salve", "ember_charm", "greater_draught"],
	"bell": ["mirror_needle", "mirror_scale", "bell_fragment", "fading_elixir", "hollow_eye"],
	"throne": ["rift_ember", "choir_plate", "hollow_eye", "void_sigil", "ashen_edge"],
}

const BLACKSMITH_UPGRADES := [
	{"id": "temper", "label": "Templar el arma", "desc": "+2 de daño permanente en esta run."},
	{"id": "reinforce", "label": "Reforzar la armadura", "desc": "+12 HP máximo y cura 12 HP."},
	{"id": "enchant", "label": "Encantar la reliquia", "desc": "+2 de defensa permanente en esta run."},
]


static func item(id: String) -> Dictionary:
	return ITEMS.get(id, {})


static func item_tint(id: String) -> String:
	return String(item(id).get("tint", ""))


static func enemy_by_id(id: String) -> Dictionary:
	for e in ENEMIES:
		if e["id"] == id:
			return e
	return ENEMIES[0]


static func enemy_tint(enemy: Dictionary) -> String:
	return String(enemy.get("tint", ""))


static func selection_time_for(enemy: Dictionary, rng: RandomNumberGenerator) -> float:
	var band: Array = SELECT_TIME_BY_TIER.get(String(enemy.get("tier", "weak")), SELECT_TIME_BY_TIER["weak"])
	return rng.randf_range(float(band[0]), float(band[1]))


static func world_for_encounter(n: int) -> Dictionary:
	var encounter := maxi(1, n)
	for world in WORLDS:
		if encounter >= int(world.get("min_encounter", 1)) and encounter <= int(world.get("max_encounter", 999)):
			return world
	return WORLDS[WORLDS.size() - 1]


static func enemies_for_encounter(n: int, rng: RandomNumberGenerator) -> Dictionary:
	if n % 10 == 0:
		return enemy_by_id("limitless")
	if n % 5 == 0:
		return enemy_by_id("colossus")
	var world := world_for_encounter(n)
	var pool: Array = world.get("pool", ["skeleton", "brigand"])
	var elite_pool: Array = world.get("elite_pool", [])
	var elite_from := int(world.get("min_encounter", 1)) + 2
	if not elite_pool.is_empty() and n >= elite_from and rng.randf() < 0.35:
		pool = elite_pool
	var id: String = String(pool[rng.randi_range(0, pool.size() - 1)])
	return enemy_by_id(id)


static func enemy_group_for_encounter(n: int, rng: RandomNumberGenerator) -> Array[Dictionary]:
	if n % 10 == 0:
		return [enemy_by_id("limitless").duplicate(true)]
	if n % 5 == 0:
		return [enemy_by_id("colossus").duplicate(true)]
	var world := world_for_encounter(n)
	var pool: Array = world.get("pool", ["skeleton", "brigand"])
	var elite_pool: Array = world.get("elite_pool", [])
	var elite_from := int(world.get("min_encounter", 1)) + 2
	var maximum := 1
	var minimum := 1
	if n == 1:
		minimum = 1
		maximum = 1
	elif n == 2:
		minimum = 1
		maximum = 2
	elif n <= 4:
		minimum = 2
		maximum = 2
	elif n <= 7:
		minimum = 2
		maximum = 3
	else:
		minimum = 2
		maximum = MAX_ENEMIES_PER_ENCOUNTER
	var group_size := rng.randi_range(minimum, maximum)
	var group: Array[Dictionary] = []
	if not elite_pool.is_empty() and n >= elite_from and rng.randf() < 0.35:
		var elite_id := String(elite_pool[rng.randi_range(0, elite_pool.size() - 1)])
		group.append(enemy_by_id(elite_id).duplicate(true))
		group_size = maxi(group_size, 2)
	while group.size() < group_size and group.size() < MAX_ENEMIES_PER_ENCOUNTER:
		var enemy_id := String(pool[rng.randi_range(0, pool.size() - 1)])
		group.append(enemy_by_id(enemy_id).duplicate(true))
	return group


static func attack_difficulty_range(player_level: int, mastery_max: int, attack_id: String) -> Vector2i:
	var low := 0
	var high := 1
	if player_level >= 8:
		low = 2
		high = 3
	elif player_level >= 5:
		low = 1
		high = 3
	elif player_level >= 3:
		high = 2
	var profile: Dictionary = PLAYER_ATTACKS.get(attack_id, PLAYER_ATTACKS["piercing_strike"])
	var shift := int(profile.get("difficulty_shift", 0))
	low = clampi(low + shift, 0, 3)
	high = clampi(high + shift, low, 3)
	var available_max := clampi(mastery_max, 0, 3)
	high = mini(high, available_max)
	if low > high:
		low = high
	return Vector2i(low, high)


static func attack_effectiveness_label(attack_id: String, enemy: Dictionary) -> String:
	var profile: Dictionary = PLAYER_ATTACKS.get(attack_id, PLAYER_ATTACKS["piercing_strike"])
	var damage_type := String(profile.get("type", "physical"))
	var weaknesses: Dictionary = enemy.get("weaknesses", {})
	if float(weaknesses.get(damage_type, 1.0)) > 1.01:
		return "Explotará su debilidad"
	var resistance := int(enemy.get("armor", 0)) if damage_type == "physical" else int(enemy.get("magic_resist", 0))
	var penetration := int(profile.get("penetration", 0))
	if resistance > penetration:
		return "El enemigo resiste este tipo"
	return "Sin ventaja de tipo"


static func player_attack(difficulty: int, equipped: Dictionary, attack_id: String = "") -> int:
	if attack_id != "":
		var profile: Dictionary = PLAYER_ATTACKS.get(attack_id, PLAYER_ATTACKS["piercing_strike"])
		var damage_type := String(profile.get("type", "physical"))
		var typed_base := float(BASELINE_DAMAGE[clampi(difficulty, 0, 3)]) * float(profile.get("power", 1.0))
		var typed_bonus := 0
		var typed_weapon: Dictionary = item(equipped.get("weapon", ""))
		if not typed_weapon.is_empty():
			if damage_type == "physical":
				typed_bonus += int(typed_weapon.get("damage", 0))
			else:
				typed_bonus += int(typed_weapon.get("spell", 0)) + int(floor(float(int(typed_weapon.get("damage", 0))) / 2.0))
		var typed_relic: Dictionary = item(equipped.get("relic", ""))
		if not typed_relic.is_empty():
			typed_bonus += int(typed_relic.get("damage", 0))
		return maxi(1, int(roundf(typed_base)) + typed_bonus)
	var base: int = BASELINE_DAMAGE[clampi(difficulty, 0, 3)]
	var bonus := 0
	var weapon: Dictionary = item(equipped.get("weapon", ""))
	if not weapon.is_empty():
		bonus += int(weapon.get("damage", 0))
		if difficulty >= 2:
			bonus += int(weapon.get("spell", 0))
	var relic: Dictionary = item(equipped.get("relic", ""))
	if not relic.is_empty():
		bonus += int(relic.get("damage", 0))
	return maxi(1, base + bonus)


static func damage_for_attack(raw_damage: int, attack_id: String, enemy: Dictionary) -> int:
	var profile: Dictionary = PLAYER_ATTACKS.get(attack_id, PLAYER_ATTACKS["piercing_strike"])
	var damage_type := String(profile.get("type", "physical"))
	var resistance := int(enemy.get("armor", 0)) if damage_type == "physical" else int(enemy.get("magic_resist", 0))
	var penetration := int(profile.get("penetration", 0))
	var mitigated := raw_damage - maxi(0, resistance - penetration)
	var weaknesses: Dictionary = enemy.get("weaknesses", {})
	var multiplier := float(weaknesses.get(damage_type, 1.0))
	return maxi(1, int(roundf(float(mitigated) * multiplier)))


static func apply_armor(damage: int, armor: int) -> int:
	return maxi(1, damage - maxi(0, armor))


static func self_damage(difficulty: int) -> int:
	var pct: float = FAIL_SELF_PCT[clampi(difficulty, 0, 3)]
	if pct <= 0.0:
		return 0
	var base: int = BASELINE_DAMAGE[clampi(difficulty, 0, 3)]
	return maxi(1, int(round(float(base) * pct)))


static func player_defense(equipped: Dictionary) -> int:
	var total := 0
	var armor: Dictionary = item(equipped.get("armor", ""))
	if not armor.is_empty():
		total += int(armor.get("defense", 0))
	var relic: Dictionary = item(equipped.get("relic", ""))
	if not relic.is_empty():
		total += int(relic.get("defense", 0))
	return total


static func max_hp_bonus(equipped: Dictionary) -> int:
	return _sum_stat(equipped, "max_hp")


static func damage_bonus(equipped: Dictionary) -> int:
	return _sum_stat(equipped, "damage")


static func _sum_stat(equipped: Dictionary, stat: String) -> int:
	var total := 0
	for slot in ["weapon", "armor", "relic"]:
		var it: Dictionary = item(equipped.get(slot, ""))
		if not it.is_empty():
			total += int(it.get(stat, 0))
	return total


static func enemy_attack(enemy: Dictionary, equipped: Dictionary, hp_ratio: float) -> int:
	var atk := int(enemy.get("attack", 1))
	if hp_ratio <= 0.5:
		atk += 2
	return maxi(1, atk - player_defense(equipped))


static func roll_loot(enemy: Dictionary, rng: RandomNumberGenerator, chance: float = 0.35, world_id: String = "") -> String:
	if rng.randf() > chance:
		return ""
	var tier: String = enemy.get("tier", "weak")
	var tier_pool: Array = LOOT_BY_TIER.get(tier, LOOT_BY_TIER["weak"])
	var world_pool: Array = WORLD_LOOT.get(world_id, [])
	if not world_pool.is_empty() and rng.randf() < 0.55:
		return world_pool[rng.randi_range(0, world_pool.size() - 1)]
	return tier_pool[rng.randi_range(0, tier_pool.size() - 1)]


static func xp_for(enemy: Dictionary) -> int:
	match String(enemy.get("tier", "weak")):
		"weak":
			return 5
		"ordinary":
			return 10
		"strong":
			return 18
		"elite":
			return 26
		"miniboss":
			return 50
		_:
			return 90
