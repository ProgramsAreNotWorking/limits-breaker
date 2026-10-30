@tool
extends RefCounted
## UI strings. Chinese is used when the editor language is Chinese, English otherwise.

const STRINGS := {
	docs = ["Docs", "文档"],
	outline = ["Outline", "大纲"],
	copy = ["Copy", "复制"],
	copied = ["Copied", "已复制"],
	zoom_out = ["Zoom out (Ctrl + Wheel)", "缩小（Ctrl + 滚轮）"],
	zoom_reset = ["Reset zoom", "重置缩放"],
	zoom_in = ["Zoom in (Ctrl + Wheel)", "放大（Ctrl + 滚轮）"],
	reload = ["Reload", "刷新"],
	open_external = ["Open in default app", "用系统默认程序打开"],
	not_found = ["Document not found: %s", "文档不存在：%s"],
}

static var _zh := -1


static func t(key: String) -> String:
	if _zh < 0:
		# The editor UI locale, which can differ from the OS locale.
		_zh = 1 if TranslationServer.get_tool_locale().begins_with("zh") else 0
	return STRINGS[key][_zh]
