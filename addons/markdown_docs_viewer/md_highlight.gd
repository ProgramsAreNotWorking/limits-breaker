@tool
extends RefCounted
## Syntax highlighting for code blocks. Colors come from the editor settings so they match the Script editor.

const Inline := preload("md_inline.gd")

const KEYWORDS := ["func", "var", "const", "extends", "class_name", "class", "signal", "static", "enum",
	"super", "is", "as", "in", "and", "or", "not", "self", "true", "false", "null", "void", "preload", "load"]
const FLOW := ["if", "elif", "else", "for", "while", "match", "return", "break", "continue", "pass", "await"]
const SCRIPT_LANGS := ["gdscript", "gd", "python", "py", "csharp", "cs", "c#", "js", "javascript", "ts", "json", "shader", "glsl"]
const CONFIG_LANGS := ["ini", "cfg", "toml", "godot", "tscn", "tres"]

var text_color: Color
var _c := {}

static var _re_script := RegEx.create_from_string(
	r"(?m)(?<comment>#.*$|//.*$)|(?<string>\"(?:\\.|[^\"\\])*\"|'(?:\\.|[^'\\])*')|(?<anno>@\w+)|(?<number>\b\d+(?:\.\d+)?\b)|(?<word>[A-Za-z_]\w*)")
static var _re_config := RegEx.create_from_string(
	r"(?m)(?<comment>[;#].*$)|(?<section>^\s*\[[^\]\n]*\])|(?<key>^\s*[\w/.\-]+(?=\s*=))|(?<string>\"(?:\\.|[^\"\\])*\")|(?<number>\b\d+(?:\.\d+)?\b)")
static var _re_plain := RegEx.create_from_string(r"(?m)(?<comment>#.*$)")


func _init(fallback_text: Color) -> void:
	text_color = _setting("text_color", fallback_text)
	_c = {
		comment = _setting("comment_color", Color("#8b95a3")),
		string = _setting("string_color", Color("#ffeda1")),
		number = _setting("number_color", Color("#a1ffe0")),
		keyword = _setting("keyword_color", Color("#ff7085")),
		flow = _setting("control_flow_keyword_color", Color("#ff8ccc")),
		type = _setting("engine_type_color", Color("#8fffdb")),
		function = _setting("function_color", Color("#57b3ff")),
		anno = _setting("gdscript/annotation_color", Color("#ffb373")),
		member = _setting("member_variable_color", Color("#bce0ff")),
		section = _setting("keyword_color", Color("#ff7085")),
	}


func highlight(code: String, lang: String) -> String:
	var re := _re_plain
	if lang in SCRIPT_LANGS:
		re = _re_script
	elif lang in CONFIG_LANGS:
		re = _re_config
	var out := ""
	var pos := 0
	for m in re.search_all(code):
		out += Inline.escape(code.substr(pos, m.get_start() - pos))
		var token := m.get_string()
		out += _paint(token, _kind(m, code))
		pos = m.get_end()
	return out + Inline.escape(code.substr(pos))


func _kind(m: RegExMatch, code: String) -> String:
	for kind in ["comment", "string", "anno", "number", "section", "key"]:
		if m.names.has(kind) and m.get_start(kind) >= 0:
			return "member" if kind == "key" else kind
	var word := m.get_string("word") if m.names.has("word") else ""
	if word.is_empty():
		return ""
	if word in FLOW:
		return "flow"
	if word in KEYWORDS:
		return "keyword"
	if code.substr(m.get_end(), 1) == "(":
		return "function"
	if word[0] == word[0].to_upper() and word[0] != "_":
		return "type"
	return ""


func _paint(token: String, kind: String) -> String:
	if kind.is_empty():
		return Inline.escape(token)
	return "[color=#%s]%s[/color]" % [(_c[kind] as Color).to_html(), Inline.escape(token)]


func _setting(name: String, fallback: Color) -> Color:
	var key := "text_editor/theme/highlighting/" + name
	var es := EditorInterface.get_editor_settings()
	return es.get_setting(key) if es.has_setting(key) else fallback
