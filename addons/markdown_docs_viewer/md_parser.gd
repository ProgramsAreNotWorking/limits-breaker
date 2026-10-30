@tool
extends RefCounted
## Splits Markdown text into blocks (heading, paragraph, code, table, list, quote, rule).
## Each block is a Dictionary with a "type" key; md_renderer.gd turns them into nodes.

static var _re_heading := RegEx.create_from_string(r"^\s{0,3}(#{1,6})\s+(.*?)\s*#*\s*$")
static var _re_hr := RegEx.create_from_string(r"^\s{0,3}([-*_])(\s*\1){2,}\s*$")
static var _re_list := RegEx.create_from_string(r"^(\s*)([-*+]|\d+[.)])\s+(.*)$")
static var _re_table_sep := RegEx.create_from_string(r"^\s*\|?\s*:?-+:?\s*(\|\s*:?-+:?\s*)*\|?\s*$")


static func parse(src: String) -> Array[Dictionary]:
	var lines := src.replace("\r\n", "\n").replace("\t", "    ").split("\n")
	var blocks: Array[Dictionary] = []
	var i := 0
	var n := lines.size()
	while i < n:
		var line: String = lines[i]
		var stripped := line.strip_edges()
		if stripped.is_empty():
			i += 1
		elif stripped.begins_with("<!--"):
			# HTML comments may span several lines; skip the whole thing.
			while i < n and not lines[i].contains("-->"):
				i += 1
			i += 1
		elif stripped.begins_with("```") or stripped.begins_with("~~~"):
			var fence := stripped.substr(0, 3)
			var code: PackedStringArray = []
			i += 1
			while i < n and not lines[i].strip_edges().begins_with(fence):
				code.append(lines[i])
				i += 1
			i += 1
			blocks.append({type = "code", lang = stripped.substr(3).strip_edges().to_lower(), code = "\n".join(code)})
		elif _re_heading.search(line):
			var m := _re_heading.search(line)
			blocks.append({type = "heading", level = m.get_string(1).length(), text = m.get_string(2)})
			i += 1
		elif _re_hr.search(line):
			blocks.append({type = "hr"})
			i += 1
		elif stripped.begins_with("|") and i + 1 < n and _re_table_sep.search(lines[i + 1]):
			i = _parse_table(lines, i, blocks)
		elif stripped.begins_with(">"):
			var inner: PackedStringArray = []
			while i < n and lines[i].strip_edges().begins_with(">"):
				inner.append(lines[i].strip_edges().trim_prefix(">").trim_prefix(" "))
				i += 1
			blocks.append({type = "quote", blocks = parse("\n".join(inner))})
		elif _re_list.search(line):
			i = _parse_list(lines, i, blocks)
		else:
			i = _parse_paragraph(lines, i, blocks)
	return blocks


static func _parse_table(lines: PackedStringArray, i: int, blocks: Array[Dictionary]) -> int:
	var header := _split_row(lines[i])
	var aligns: Array[String] = []
	for cell in _split_row(lines[i + 1]):
		if cell.begins_with(":") and cell.ends_with(":"):
			aligns.append("center")
		elif cell.ends_with(":"):
			aligns.append("right")
		else:
			aligns.append("left")
	var rows: Array[PackedStringArray] = []
	i += 2
	while i < lines.size() and lines[i].strip_edges().begins_with("|"):
		var row := _split_row(lines[i])
		row.resize(header.size())  # Pad or truncate rows to the header's column count.
		rows.append(row)
		i += 1
	blocks.append({type = "table", header = header, aligns = aligns, rows = rows})
	return i


static func _split_row(line: String) -> PackedStringArray:
	var s := line.strip_edges().trim_prefix("|").trim_suffix("|")
	var cells: PackedStringArray = []
	for cell in s.split("|"):
		cells.append(cell.strip_edges())
	return cells


static func _parse_list(lines: PackedStringArray, i: int, blocks: Array[Dictionary]) -> int:
	var items: Array[Dictionary] = []
	var stack: Array[int] = []  # Indent width per nesting level.
	while i < lines.size():
		var m := _re_list.search(lines[i])
		if m == null:
			var stripped := lines[i].strip_edges()
			if stripped.is_empty():
				# A blank line continues the list only if another item follows.
				if i + 1 < lines.size() and _re_list.search(lines[i + 1]):
					i += 1
					continue
				break
			if items.is_empty() or not lines[i].begins_with("  ") or _starts_block(lines[i]):
				break
			var last: Dictionary = items.back()
			last.text += " " + stripped  # Indented continuation line joins the previous item.
			i += 1
			continue
		var indent := m.get_string(1).length()
		while not stack.is_empty() and stack.back() > indent:
			stack.pop_back()
		if stack.is_empty() or stack.back() < indent:
			stack.append(indent)
		var marker := m.get_string(2)
		var text := m.get_string(3)
		var task := -1  # -1 plain item, 0 unchecked, 1 checked.
		if text.begins_with("[ ] ") or text == "[ ]":
			task = 0
			text = text.substr(3).strip_edges()
		elif text.to_lower().begins_with("[x] ") or text.to_lower() == "[x]":
			task = 1
			text = text.substr(3).strip_edges()
		items.append({level = stack.size() - 1, ordered = marker[0].is_valid_int(), marker = marker, task = task, text = text})
		i += 1
	blocks.append({type = "list", items = items})
	return i


static func _parse_paragraph(lines: PackedStringArray, i: int, blocks: Array[Dictionary]) -> int:
	var text := ""
	while i < lines.size():
		var line := lines[i]
		var stripped := line.strip_edges()
		if stripped.is_empty() or (not text.is_empty() and _starts_block(line)):
			break
		if text.is_empty():
			text = stripped
		elif text.ends_with("\n"):
			text += stripped
		elif text.unicode_at(text.length() - 1) > 127 and stripped.unicode_at(0) > 127:
			text += stripped  # No space when joining CJK lines.
		else:
			text += " " + stripped
		if line.ends_with("  ") or line.ends_with("\\"):
			text = text.trim_suffix("\\") + "\n"  # Hard line break.
		i += 1
	blocks.append({type = "para", text = text.strip_edges()})
	return i


static func _starts_block(line: String) -> bool:
	var s := line.strip_edges()
	return s.begins_with("#") or s.begins_with("```") or s.begins_with("~~~") or s.begins_with(">") \
		or s.begins_with("|") or _re_hr.search(line) != null or _re_list.search(line) != null
