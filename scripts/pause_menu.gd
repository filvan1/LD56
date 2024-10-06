extends Control

func load_level(level_path):
	# Load a level scene
	var level = load(level_path)
	# Replace the current scene with the loaded level scene
	get_tree().change_scene_to_packed(level)

func _on_volume_slider_value_changed(value:float) -> void:
	AudioServer.set_bus_volume_db(0, linear_to_db(value))


func _on_quit_button_pressed() -> void:
	hide()
	$MenuLayer.hide()
	$Background.hide()
	get_tree().paused = false
	load_level("res://scenes/main_menu.tscn")


func _on_continue_button_pressed() -> void:
	hide()
	$MenuLayer.hide()
	$Background.hide()
	get_tree().paused = false

func _on_player_pause_game() -> void:
	get_tree().paused = true
	show()
	$MenuLayer.show()
	$Background.show()
