@tool
extends RefCounted
## Converts inline Markdown (`code`, **bold**, *italic*, ~~strike~~, [link](url)) to RichTextLabel BBCode.

static var _re_code := RegEx.create_from_string(r"(`+)(.+?)\1")
static var _re_link := RegEx.create_from_string(r"!?\[([^\]]+)\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)")
static var _re_autolink := RegEx.create_from_string(r"<(https?://[^>\s]+)>")
static var _re_comment := RegEx.create_from_string(r"<!--.*?-->")
static var _re_bold := RegEx.create_from_string(r"\*\*(?=\S)(.+?)(?<=\S)\*\*")
static var _re_italic := RegEx.create_from_string(r"(?<![\w*])\*(?=\S)(.+?)(?<=\S)\*(?![\w*])")
static var _re_strike := RegEx.create_from_string(r"~~(?=\S)(.+?)(?<=\S)~~")


static func to_bbcode(md: String, s) -> String:
	md = _re_comment.sub(md, "", true)
	md = _re_autolink.sub(md, "[$1]($1)", true)
	var out := ""
	var pos := 0
	for m in _re_code.search_all(md):
		out += _links(md.substr(pos, m.get_start() - pos), s)
		out += "[bgcolor=#%s][color=#%s][code] %s [/code][/color][/bgcolor]" % [
			s.inline_code_bg.to_html(), s.inline_code_fg.to_html(), escape(m.get_string(2).strip_edges())]
		pos = m.get_end()
	return out + _links(md.substr(pos), s)


## Strips markup and keeps plain text, used for the outline.
static func plain(md: String) -> String:
	var t := _re_link.sub(md, "$1", true)
	for mark in ["`", "**", "~~"]:
		t = t.replace(mark, "")
	return t.strip_edges()


## Builds GitHub-compatible heading anchors, e.g. "1.2 res:// and user://" -> "12-res-and-user".
## Non-ASCII letters (CJK etc.) are kept; punctuation and symbols are dropped.
static func slugify(md: String) -> String:
	var out := ""
	for ch in plain(md).to_lower():
		var c := ch.unicode_at(0)
		if ch == " ":
			out += "-"
		elif ch == "-" or ch == "_" or (c >= 48 and c <= 57) or (c >= 97 and c <= 122):
			out += ch
		elif c > 127 and not _is_symbol(c):
			out += ch
	return out


## Escapes BBCode brackets. "[" goes through a placeholder so replacing "]" doesn't touch "[lb]".
static func escape(text: String) -> String:
	var placeholder := char(1)
	return text.replace("[", placeholder).replace("]", "[rb]").replace(placeholder, "[lb]")


static func _links(text: String, s) -> String:
	var out := ""
	var pos := 0
	for m in _re_link.search_all(text):
		out += _emph(escape(text.substr(pos, m.get_start() - pos)))
		out += "[url=%s][color=#%s]%s[/color][/url]" % [
			m.get_string(2), s.accent.to_html(), _emph(escape(m.get_string(1)))]
		pos = m.get_end()
	return out + _emph(escape(text.substr(pos)))


static func _emph(text: String) -> String:
	text = _re_bold.sub(text, "[b]$1[/b]", true)
	text = _re_italic.sub(text, "[i]$1[/i]", true)
	return _re_strike.sub(text, "[s]$1[/s]", true)


## Punctuation, symbols and emoji are left out of anchors.
static func _is_symbol(c: int) -> bool:
	return c == 0xA0 or (c >= 0x2000 and c <= 0x2BFF) or (c >= 0x3000 and c <= 0x303F) \
		or (c >= 0xFE30 and c <= 0xFE4F) or (c >= 0xFF00 and c <= 0xFF0F) \
		or (c >= 0xFF1A and c <= 0xFF20) or (c >= 0xFF3B and c <= 0xFF40) \
		or (c >= 0xFF5B and c <= 0xFF65) or c >= 0x1F000
