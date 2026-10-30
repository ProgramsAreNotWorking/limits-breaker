class_name MathEngine
extends RefCounted

const TOPICS := ["direct", "onesided", "graph", "table", "factorization"]
const TOPIC_LABELS := {
	"direct": "Límites directos",
	"onesided": "Límites laterales",
	"graph": "Límites desde gráficas",
	"table": "Límites por tablas",
	"factorization": "Límites por factorización",
	"trig": "Trigonometría",
}
const DIFF_NAMES := ["Fácil", "Intermedio", "Avanzado", "Superdifícil"]

const TRIG_TABLE := [
	{"fn": "sin", "angle": 0, "exact": "0", "value": 0.0},
	{"fn": "sin", "angle": 30, "exact": "1/2", "value": 0.5},
	{"fn": "sin", "angle": 45, "exact": "√2/2", "value": 0.70710678},
	{"fn": "sin", "angle": 60, "exact": "√3/2", "value": 0.8660254},
	{"fn": "sin", "angle": 90, "exact": "1", "value": 1.0},
	{"fn": "cos", "angle": 0, "exact": "1", "value": 1.0},
	{"fn": "cos", "angle": 30, "exact": "√3/2", "value": 0.8660254},
	{"fn": "cos", "angle": 45, "exact": "√2/2", "value": 0.70710678},
	{"fn": "cos", "angle": 60, "exact": "1/2", "value": 0.5},
	{"fn": "cos", "angle": 90, "exact": "0", "value": 0.0},
	{"fn": "tan", "angle": 0, "exact": "0", "value": 0.0},
	{"fn": "tan", "angle": 30, "exact": "√3/3", "value": 0.57735027},
	{"fn": "tan", "angle": 45, "exact": "1", "value": 1.0},
	{"fn": "tan", "angle": 60, "exact": "√3", "value": 1.7320508},
]


class Problem extends RefCounted:
	var topic: String = "direct"
	var difficulty: int = 0
	var statement: String = ""
	var expression: String = ""
	var answer_kind: String = "number" # number | choice | dne | text | roots
	var answer_value: float = 0.0
	var answer_tolerance: float = 0.0001
	var answer_text: String = ""
	var accepted: PackedStringArray = PackedStringArray()
	var steps: PackedStringArray = PackedStringArray()
	var choices: PackedStringArray = PackedStringArray()
	var correct_choice: int = 0
	var table: Array = []
	var graph: Dictionary = {}
	var hint: String = ""

	func topic_label() -> String:
		return String(TOPIC_LABELS.get(topic, topic))

	func difficulty_label() -> String:
		return DIFF_NAMES[clampi(difficulty, 0, 3)]


static func pick(arr: Array, rng: RandomNumberGenerator):
	return arr[rng.randi_range(0, arr.size() - 1)]


static func rint(rng: RandomNumberGenerator, a: int, b: int) -> int:
	return rng.randi_range(a, b)


static func signed(n: int) -> String:
	return ("+%d" % n) if n >= 0 else ("-%d" % abs(n))


static func term_x(coef: int) -> String:
	if coef == 0:
		return ""
	if coef == 1:
		return "+ x"
	if coef == -1:
		return "- x"
	return ("+ %dx" % coef) if coef > 0 else ("- %dx" % abs(coef))


static func poly_str(a: int, b: int, c: int) -> String:
	var s := ""
	if a != 0:
		s = ("x²" if a == 1 else ("-x²" if a == -1 else "%dx²" % a))
	if b != 0:
		s += " " + term_x(b) if s != "" else term_x(b)
	if c != 0:
		s += (" + %d" % c) if c > 0 else (" - %d" % abs(c))
	if s == "":
		s = "0"
	return s


# ---------------------------------------------------------------- generación

static func generate(topic: String, difficulty: int, rng: RandomNumberGenerator) -> Problem:
	difficulty = clampi(difficulty, 0, 3)
	match topic:
		"direct":
			return _direct(difficulty, rng)
		"onesided":
			return _onesided(difficulty, rng)
		"graph":
			return _graph(difficulty, rng)
		"table":
			return _table(difficulty, rng)
		"factorization":
			return _factorization(difficulty, rng)
		"trig":
			return _trig(difficulty, rng)
		_:
			return _direct(0, rng)


static func _base(p: Problem, topic: String, diff: int) -> Problem:
	p.topic = topic
	p.difficulty = diff
	return p


static func _direct(diff: int, rng: RandomNumberGenerator) -> Problem:
	var p := _base(Problem.new(), "direct", diff)
	match diff:
		0:
			var a := rint(rng, -4, 4)
			var b := rint(rng, -4, 4)
			var c := rint(rng, -6, 6)
			p.statement = "Evalúa el límite por sustitución directa."
			p.expression = "lim x→%d  ( %s )" % [a, poly_str(1, b, c)]
			p.answer_value = float(a * a + b * a + c)
			p.steps = PackedStringArray([
				"El polinomio es continuo, así que sustituimos x = %d." % a,
				"(%d)² %s %d = %d" % [a, term_x(b), c, int(p.answer_value)],
				"El límite es %d." % int(p.answer_value),
			])
			p.hint = "Sustituye x por el valor al que tiende."
		1:
			var a := rint(rng, 1, 5)
			var k := rint(rng, 1, 5)
			if a + k == 0:
				k = 1
			var m := rint(rng, -4, 4)
			var b := rint(rng, -3, 3)
			var c := m * (a + k) - a * a - b * a
			p.statement = "El denominador no se anula en el punto: sustituye directamente."
			p.expression = "lim x→%d  ( %s ) / ( x %s )" % [a, poly_str(1, b, c), signed(k)]
			p.answer_value = float(m)
			p.steps = PackedStringArray([
				"Evaluamos numerador y denominador en x = %d." % a,
				"Denominador: %d + %d = %d ≠ 0." % [a, k, a + k],
				"Numerador: %d." % (m * (a + k)),
				"El cociente es %d." % m,
			])
			p.hint = "Comprueba primero que el denominador no sea cero."
		2:
			var s := rint(rng, 2, 4)
			var k := rint(rng, 1, 3)
			var a := s * s - k
			p.statement = "La raíz es continua en el punto. Sustituye y simplifica."
			p.expression = "lim x→%d  √( x %s )" % [a, signed(k)]
			p.answer_value = float(s)
			p.steps = PackedStringArray([
				"Sustituimos x = %d: √(%d %s) = √%d." % [a, a, signed(k), s * s],
				"√%d = %d." % [s * s, s],
			])
			p.hint = "Busca un cuadrado perfecto dentro de la raíz."
		3:
			var s := rint(rng, 2, 4)
			var k := rint(rng, 1, 3)
			var a := s * s - k
			p.statement = "Forma indeterminada 0/0. Multiplica por el conjugado."
			p.expression = "lim x→%d  ( √( x %s ) − %d ) / ( x − %d )" % [a, signed(k), s, a]
			p.answer_value = 1.0 / float(2 * s)
			p.steps = PackedStringArray([
				"Al sustituir aparece 0/0.",
				"Multiplica numerador y denominador por √(x %s) + %d." % [signed(k), s],
				"El numerador queda (x %s) − %d = x − %d." % [signed(k), s * s, a],
				"Se cancela (x − %d) y queda 1 / (√(x %s) + %d)." % [a, signed(k), s],
				"Al sustituir: 1 / (%d + %d) = 1/%d ≈ %.4f." % [s, s, 2 * s, p.answer_value],
			])
			p.hint = "El conjugado elimina la raíz del numerador."
	return p


static func _onesided(diff: int, rng: RandomNumberGenerator) -> Problem:
	var p := _base(Problem.new(), "onesided", diff)
	var a := rint(rng, 0, 5)
	var m1 := rint(rng, -3, 3)
	var b1 := rint(rng, -4, 4)
	var m2 := rint(rng, -3, 3)
	var b2 := rint(rng, -4, 4)
	if m1 == m2:
		m2 += 1
	var left_y := m1 * a + b1
	var right_y := m2 * a + b2
	var side := "−" if diff % 2 == 0 else "+"
	var branch := "izquierda" if side == "−" else "derecha"
	if diff == 3:
		if left_y == right_y:
			p.statement = "Observa la función por partes. ¿Cuál es el límite bilateral en x = %d?" % a
		else:
			p.statement = "Observa la función por partes. ¿Existe el límite bilateral en x = %d?" % a
		p.expression = "f(x) = { %s  si x < %d ;  %s  si x ≥ %d }" % [poly_str(0, m1, b1), a, poly_str(0, m2, b2), a]
		p.answer_kind = "dne"
		p.answer_value = left_y if left_y == right_y else NAN
		var conclusion: String
		if left_y == right_y:
			conclusion = "Los laterales coinciden, así que el límite bilateral vale %d." % left_y
		else:
			conclusion = "Los laterales no coinciden, así que el límite bilateral no existe."
		p.steps = PackedStringArray([
			"Límite por la izquierda: %s evaluado en x = %d → %d." % [poly_str(0, m1, b1), a, left_y],
			"Límite por la derecha: %s evaluado en x = %d → %d." % [poly_str(0, m2, b2), a, right_y],
			conclusion,
		])
		if left_y == right_y:
			p.answer_kind = "number"
			p.answer_value = float(left_y)
		p.hint = "Compara ambos laterales."
		return p
	p.statement = "Calcula el límite lateral por la %s en x = %d." % [branch, a]
	p.expression = "f(x) = { %s  si x < %d ;  %s  si x ≥ %d }" % [poly_str(0, m1, b1), a, poly_str(0, m2, b2), a]
	p.answer_value = float(left_y if side == "−" else right_y)
	p.steps = PackedStringArray([
		"Para el lateral por la %s usamos la rama %s." % [branch, "x < %d" % a if side == "−" else "x ≥ %d" % a],
		"Sustituimos x = %d en %s." % [a, poly_str(0, m1, b1) if side == "−" else poly_str(0, m2, b2)],
		"El resultado es %d." % int(p.answer_value),
	])
	p.hint = "Elige la rama correcta antes de sustituir."
	return p


static func _graph(diff: int, rng: RandomNumberGenerator) -> Problem:
	var p := _base(Problem.new(), "graph", diff)
	var a := rint(rng, -1, 3)
	var m1 := rint(rng, -2, 2)
	if m1 == 0:
		m1 = 1
	var b1 := rint(rng, -3, 3)
	var m2 := rint(rng, -2, 2)
	if m2 == 0:
		m2 = -1
	var b2 := rint(rng, -3, 3)
	if diff == 0:
		m2 = m1
		b2 = b1
	var left_y := m1 * a + b1
	var right_y := m2 * a + b2
	p.graph = {
		"a": a,
		"xmin": a - 3,
		"xmax": a + 3,
		"left": [m1, b1],
		"right": [m2, b2],
		"left_y": left_y,
		"right_y": right_y,
		"continuous": left_y == right_y,
	}
	var limit_formula := "lim x→%d  f(x)" % a
	match diff:
		0:
			p.statement = "La gráfica es continua en el punto marcado. Calcula el límite bilateral."
			p.answer_value = float(left_y)
		1:
			p.statement = "Calcula el límite por la izquierda en x = %d." % a
			p.answer_value = float(left_y)
			limit_formula += "   (lateral izquierdo)"
		2:
			p.statement = "Calcula el límite por la derecha en x = %d." % a
			p.answer_value = float(right_y)
			limit_formula += "   (lateral derecho)"
		_:
			if left_y == right_y:
				p.statement = "Calcula el límite bilateral en x = %d." % a
				p.answer_value = float(left_y)
			else:
				p.statement = "¿Existe el límite bilateral en x = %d?" % a
				p.answer_kind = "dne"
				p.answer_value = NAN
	p.expression = limit_formula
	if p.answer_kind == "dne":
		p.steps = PackedStringArray([
			"Por la izquierda la función tiende a %d." % left_y,
			"Por la derecha tiende a %d." % right_y,
			"Al no coincidir, el límite bilateral no existe.",
		])
	else:
		p.steps = PackedStringArray([
			"Seguimos la curva desde el lado indicado hasta acercarnos a x = %d." % a,
			"El valor al que se aproxima la altura es %d." % int(p.answer_value),
		])
	p.hint = "El valor de f en el punto no siempre coincide con el límite."
	return p


static func _table(diff: int, rng: RandomNumberGenerator) -> Problem:
	var p := _base(Problem.new(), "table", diff)
	var a := rint(rng, 1, 5)
	var rows: Array = []
	var limit_value := 0.0
	match diff:
		0:
			var m := rint(rng, -3, 3)
			var b := rint(rng, -5, 5)
			limit_value = float(m * a + b)
			for d: float in [0.1, 0.01, 0.001]:
				rows.append([a - d, snappedf(m * (a - d) + b, 0.0001)])
				rows.append([a + d, snappedf(m * (a + d) + b, 0.0001)])
		1:
			var b1 := rint(rng, -3, 3)
			var c1 := rint(rng, -5, 5)
			limit_value = float(a * a + b1 * a + c1)
			for d: float in [0.1, 0.01, 0.001]:
				rows.append([a - d, snappedf((a - d) * (a - d) + b1 * (a - d) + c1, 0.0001)])
				rows.append([a + d, snappedf((a + d) * (a + d) + b1 * (a + d) + c1, 0.0001)])
		2:
			limit_value = float(2 * a)
			for d: float in [0.1, 0.01, 0.001]:
				var xl := a - d
				var xr := a + d
				rows.append([xl, snappedf((xl * xl - a * a) / (xl - a), 0.0001)])
				rows.append([xr, snappedf((xr * xr - a * a) / (xr - a), 0.0001)])
		_:
			limit_value = float(3 * a * a)
			for d: float in [0.1, 0.01, 0.001]:
				var xl := a - d
				var xr := a + d
				rows.append([xl, snappedf((xl * xl * xl - a * a * a) / (xl - a), 0.0001)])
				rows.append([xr, snappedf((xr * xr * xr - a * a * a) / (xr - a), 0.0001)])
	p.table = rows
	p.statement = "Aproxima el límite usando la tabla de valores. Redondea a 4 decimales si hace falta."
	p.expression = "lim x→%d  f(x)" % a
	p.answer_value = limit_value
	p.steps = PackedStringArray([
		"Al acercarnos por ambos lados, los valores de f(x) se aproximan a un mismo número.",
		"Por la izquierda y por la derecha la tabla converge hacia %.4f." % limit_value,
		"La tabla sugiere que el límite es %.4f (evidencia numérica, no una prueba formal)." % limit_value,
	])
	p.hint = "Mira la columna de f(x) a ambos lados del punto."
	return p


static func _factorization(diff: int, rng: RandomNumberGenerator) -> Problem:
	var p := _base(Problem.new(), "factorization", diff)
	var a := rint(rng, 1, 5)
	match diff:
		0:
			p.statement = "Forma 0/0: factoriza la diferencia de cuadrados y simplifica."
			p.expression = "lim x→%d  ( x² − %d ) / ( x − %d )" % [a, a * a, a]
			p.answer_value = float(2 * a)
			p.steps = PackedStringArray([
				"Factoriza el numerador: x² − %d = (x − %d)(x + %d)." % [a * a, a, a],
				"Se cancela el factor (x − %d)." % a,
				"Queda lim x→%d (x + %d) = %d." % [a, a, 2 * a],
			])
		1:
			var r := rint(rng, -5, 5)
			if r == a:
				r += 1
			var b := -(a + r)
			var c := a * r
			p.statement = "Forma 0/0: factoriza el trinomio y simplifica."
			p.expression = "lim x→%d  ( %s ) / ( x − %d )" % [a, poly_str(1, b, c), a]
			p.answer_value = float(a - r)
			p.steps = PackedStringArray([
				"El numerador se factoriza como (x − %d)(x %s)." % [a, signed(-r)],
				"Se cancela (x − %d)." % a,
				"Queda lim x→%d (x %s) = %d." % [a, signed(-r), a - r],
			])
		2:
			p.statement = "Forma 0/0: usa la diferencia de cubos."
			p.expression = "lim x→%d  ( x³ − %d ) / ( x − %d )" % [a, a * a * a, a]
			p.answer_value = float(3 * a * a)
			p.steps = PackedStringArray([
				"x³ − %d = (x − %d)(x² + %dx + %d)." % [a * a * a, a, a, a * a],
				"Se cancela (x − %d)." % a,
				"Queda %d + %d + %d = %d." % [a * a, a * a, a * a, 3 * a * a],
			])
		_:
			if rng.randi() % 2 == 0:
				p.statement = "Límite lateral con valor absoluto. ¿Existe el límite bilateral?"
				p.expression = "lim x→%d  | x − %d | / ( x − %d )" % [a, a, a]
				p.answer_kind = "dne"
				p.answer_value = NAN
				p.steps = PackedStringArray([
					"Por la izquierda |x − %d| = −(x − %d), el cociente vale −1." % [a, a],
					"Por la derecha |x − %d| = (x − %d), el cociente vale +1." % [a, a],
					"Los laterales no coinciden: el límite bilateral no existe.",
				])
			else:
				p.statement = "Forma 0/0 con polinomios de distinto grado. Factoriza ambos."
				p.expression = "lim x→%d  ( x³ − %d ) / ( x² − %d )" % [a, a * a * a, a * a]
				p.answer_value = float(3 * a) / 2.0
				p.steps = PackedStringArray([
					"Numerador: (x − %d)(x² + %dx + %d)." % [a, a, a * a],
					"Denominador: (x − %d)(x + %d)." % [a, a],
					"Se cancela (x − %d) y queda (x² + %dx + %d)/(x + %d)." % [a, a, a * a, a],
					"Al sustituir: (%d)/(%d) = %.4f." % [3 * a * a, 2 * a, p.answer_value],
				])
	p.hint = "Si al sustituir aparece 0/0, factoriza y cancela."
	return p


static func _trig(diff: int, rng: RandomNumberGenerator) -> Problem:
	var p := _base(Problem.new(), "trig", diff)
	var entry: Dictionary = pick(TRIG_TABLE, rng)
	var correct: String = entry["exact"]
	p.statement = "El herrero exige precisión. Escribe el valor decimal aproximado a tres decimales (margen ±0,005)."
	p.expression = "%s(%d°)" % [entry["fn"], entry["angle"]]
	p.answer_kind = "number"
	p.answer_tolerance = 0.005
	p.answer_value = float(entry["value"])
	p.steps = PackedStringArray([
		"%s(%d°) es un valor notable del círculo trigonométrico." % [entry["fn"], entry["angle"]],
		"El valor exacto es %s." % correct,
	])
	p.hint = "Recuerda los valores notables de 0°, 30°, 45°, 60° y 90°."
	return p


static func angel_problem(difficulty: int, rng: RandomNumberGenerator) -> Problem:
	var p := _base(Problem.new(), "factorization", difficulty)
	var p_root := rint(rng, -9, 9)
	var q_root := rint(rng, -9, 9)
	while q_root == p_root:
		q_root = rint(rng, -9, 9)
	var b := -(p_root + q_root)
	var c := p_root * q_root
	var correct := "%s%s" % [_factor(p_root), _factor(q_root)]
	var wrong := [
		"%s%s" % [_factor(-p_root), _factor(-q_root)],
		"%s%s" % [_factor(p_root), _factor(-q_root)],
		"%s%s" % [_factor(-p_root), _factor(q_root)],
	]
	var options: Array = [correct]
	for w in wrong:
		if not options.has(w):
			options.append(w)
	while options.size() < 4:
		var filler := "%s%s" % [_factor(rint(rng, -9, 9)), _factor(rint(rng, -9, 9))]
		if not options.has(filler):
			options.append(filler)
	_shuffle(options, rng)
	p.choices = PackedStringArray(options)
	p.correct_choice = p.choices.find(correct)
	var root_low := mini(p_root, q_root)
	var root_high := maxi(p_root, q_root)
	p.statement = "Factoriza el trinomio. Escribe sus dos raíces de menor a mayor, separadas por una coma."
	p.expression = "x² %s x %s" % [_signed_term(b).replace(" ", ""), _const(c)]
	p.answer_kind = "roots"
	p.accepted = PackedStringArray([str(root_low), str(root_high)])
	p.answer_text = "%d, %d" % [root_low, root_high]
	p.steps = PackedStringArray([
		"Buscamos dos números que sumen %d y multipliquen %d." % [-b, c],
		"Son %d y %d." % [p_root, q_root],
		"Por eso x² %s %s = %s." % [_signed_term(b), _const(c), correct],
	])
	p.hint = "Dos números que sumen −b y multipliquen c."
	return p


static func _factor(root: int) -> String:
	if root == 0:
		return "(x)"
	if root > 0:
		return "(x − %d)" % root
	return "(x + %d)" % abs(root)


static func _signed_term(n: int) -> String:
	return ("+ %d" % n) if n >= 0 else ("− %d" % abs(n))


static func _const(n: int) -> String:
	return ("+ %d" % n) if n > 0 else ("− %d" % abs(n)) if n < 0 else ""


static func _shuffle(arr: Array, rng: RandomNumberGenerator) -> void:
	for i in range(arr.size() - 1, 0, -1):
		var j := rng.randi_range(0, i)
		var tmp = arr[i]
		arr[i] = arr[j]
		arr[j] = tmp


# ---------------------------------------------------------------- corrección

static func normalize(raw: String) -> String:
	var s := raw.strip_edges().to_lower()
	s = s.replace("−", "-").replace("–", "-").replace(" ", "")
	s = s.replace(",", ".")
	s = s.replace("sqrt", "√")
	return s


static func parse_number(raw: String) -> float:
	var s := normalize(raw)
	if s == "":
		return NAN
	if "/" in s:
		var parts := s.split("/", false, 1)
		if parts.size() == 2 and parts[0].is_valid_float() and parts[1].is_valid_float():
			var den := float(parts[1])
			if is_zero_approx(den):
				return NAN
			return float(parts[0]) / den
		return NAN
	if s.is_valid_float():
		return float(s)
	return NAN


static func is_dne(raw: String) -> bool:
	var s := normalize(raw)
	return s in ["noexiste", "no", "dne", "undefined", "indefinido", "nodefinido", "noexisteellímite", "noexisteel limite"]


static func grade(p: Problem, raw: String) -> bool:
	match p.answer_kind:
		"choice":
			return false # se evalúa por índice
		"dne":
			return is_dne(raw)
		"roots":
			var cleaned := raw.strip_edges().replace("−", "-").replace(" ", "")
			var parts := cleaned.split(",", false)
			if parts.size() != 2:
				parts = cleaned.split(";", false)
			if parts.size() != 2 or not parts[0].is_valid_int() or not parts[1].is_valid_int():
				return false
			var low := mini(int(parts[0]), int(parts[1]))
			var high := maxi(int(parts[0]), int(parts[1]))
			return low == int(p.accepted[0]) and high == int(p.accepted[1])
		"text":
			var s := normalize(raw)
			for a in p.accepted:
				if normalize(a) == s:
					return true
			return false
		_:
			var v := parse_number(raw)
			if is_nan(v):
				return false
			return absf(v - p.answer_value) <= maxf(p.answer_tolerance, absf(p.answer_value) * 0.000001)


static func grade_choice(p: Problem, index: int) -> bool:
	return index == p.correct_choice


static func format_answer(p: Problem) -> String:
	match p.answer_kind:
		"dne":
			return "No existe"
		"choice":
			return p.choices[p.correct_choice] if p.correct_choice >= 0 and p.correct_choice < p.choices.size() else "?"
		"roots":
			return p.answer_text
		_:
			if is_equal_approx(p.answer_value, roundf(p.answer_value)):
				return str(int(roundf(p.answer_value)))
			return String.num(p.answer_value, 4)
