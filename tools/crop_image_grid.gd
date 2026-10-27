extends SceneTree
## Recorta una imagen en una cuadrícula regular y guarda cada celda como PNG.
## Uso: godot --headless --path . --script res://tools/crop_image_grid.gd -- INPUT OUTPUT_DIR ROWS COLS name1,name2,...


func _initialize() -> void:
	var args := OS.get_cmdline_user_args()
	if args.size() != 5:
		push_error("Uso: crop_image_grid.gd INPUT OUTPUT_DIR ROWS COLS name1,name2,...")
		quit(2)
		return

	var input_path := _project_path(String(args[0]))
	var output_dir := _project_path(String(args[1]))
	var rows := int(args[2])
	var columns := int(args[3])
	var names := String(args[4]).split(",", false)
	if rows < 1 or columns < 1 or names.size() != rows * columns:
		push_error("La cuadrícula y el número de nombres no coinciden.")
		quit(2)
		return

	var source := Image.new()
	var load_error := source.load(input_path)
	if load_error != OK:
		push_error("No se pudo leer %s (error %d)." % [input_path, load_error])
		quit(1)
		return
	if source.get_width() < columns or source.get_height() < rows:
		push_error("La imagen es demasiado pequeña para esa cuadrícula.")
		quit(1)
		return

	var dir_error := DirAccess.make_dir_recursive_absolute(output_dir)
	if dir_error != OK:
		push_error("No se pudo crear %s (error %d)." % [output_dir, dir_error])
		quit(1)
		return

	for index in range(names.size()):
		var name := names[index].strip_edges()
		var name_parts := name.split("/", false)
		var name_is_valid := not name_parts.is_empty()
		for part in name_parts:
			if part in [".", ".."] or not part.is_valid_filename():
				name_is_valid = false
		if not name_is_valid:
			push_error("Nombre de celda inválido: %s" % name)
			quit(2)
			return
		var column := index % columns
		var row := index / columns
		var x0 := roundi(float(source.get_width() * column) / float(columns))
		var x1 := roundi(float(source.get_width() * (column + 1)) / float(columns))
		var y0 := roundi(float(source.get_height() * row) / float(rows))
		var y1 := roundi(float(source.get_height() * (row + 1)) / float(rows))
		var region := source.get_region(Rect2i(x0, y0, x1 - x0, y1 - y0))
		var target := output_dir.path_join(name + ".png")
		var target_dir_error := DirAccess.make_dir_recursive_absolute(target.get_base_dir())
		if target_dir_error != OK:
			push_error("No se pudo crear la carpeta de %s (error %d)." % [target, target_dir_error])
			quit(1)
			return
		var save_error := region.save_png(target)
		if save_error != OK:
			push_error("No se pudo escribir %s (error %d)." % [target, save_error])
			quit(1)
			return
		print("%s: %d x %d" % [target, region.get_width(), region.get_height()])
	quit(0)


func _project_path(path: String) -> String:
	if path.begins_with("res://") or path.begins_with("user://") or path.is_absolute_path():
		return ProjectSettings.globalize_path(path)
	return ProjectSettings.globalize_path("res://" + path)
