extends Control

func load_level(level_path):
	# Load a level scene
	var level = load(level_path)
	# Replace the current scene with the loaded level scene
	get_tree().change_scene_to_packed(level)

func _on_play_button_pressed() -> void:
	load_level("res://scenes/main.tscn")



func _on_volume_slider_value_changed(value:float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))
