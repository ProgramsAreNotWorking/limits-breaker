extends SceneTree

func _initialize() -> void:
	for method in ClassDB.class_get_method_list("AudioStreamWAV"):
		print(method.get("name", ""))
	quit()
