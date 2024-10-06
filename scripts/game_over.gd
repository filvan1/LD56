extends Control

func load_level(level_path):
	# Load a level scene
	var level = load(level_path)
	# Replace the current scene with the loaded level scene
	get_tree().change_scene_to_packed(level)

func _on_quit_button_pressed() -> void:
	get_tree().paused = false
	load_level("res://scenes/main_menu.tscn")

func _on_continue_button_pressed() -> void:
	get_tree().paused = false
	load_level("res://scenes/main.tscn")

func _on_player_die() -> void:
	get_tree().paused = true
	show()
	$MenuLayer.show()
	$Background.show()
