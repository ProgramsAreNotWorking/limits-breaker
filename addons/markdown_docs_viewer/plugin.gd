@tool
extends EditorPlugin
## Adds a "Docs" main screen next to 2D / 3D / Script.

const DocsPanel := preload("md_panel.gd")
const I18n := preload("md_i18n.gd")

var _panel: Control


func _enter_tree() -> void:
	_panel = DocsPanel.new()
	EditorInterface.get_editor_main_screen().add_child(_panel)
	_make_visible(false)


func _exit_tree() -> void:
	if is_instance_valid(_panel):
		_panel.queue_free()


func _has_main_screen() -> bool:
	return true


func _make_visible(visible: bool) -> void:
	if is_instance_valid(_panel):
		_panel.visible = visible


func _get_plugin_name() -> String:
	return I18n.t("docs")


func _get_plugin_icon() -> Texture2D:
	var editor_theme := EditorInterface.get_editor_theme()
	for icon_name in ["TextFile", "File"]:
		if editor_theme.has_icon(icon_name, "EditorIcons"):
			return editor_theme.get_icon(icon_name, "EditorIcons")
	return null
