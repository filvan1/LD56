extends Control

signal win_for_real

@onready var win_audio = preload("res://sounds/fanfar.wav")
@onready var lose_audio = preload("res://sounds/you_died.wav")

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
	$MenuLayer/container/title.text = "[center]GAME OVER"
	$MenuLayer/container/buttons/ContinueButton.text = "RETRY"
	get_tree().paused = true
	show()
	$MenuLayer.show()
	$Background.show()
	$AudioStreamPlayer2D.stream = lose_audio
	$AudioStreamPlayer2D.play()

func _on_level_manager_encounter_finish(encounter:Encounter) -> void:
	if encounter.is_boss:
		win_for_real.emit()
		$MenuLayer/container/title.text = "[center]YOU WIN"
		$MenuLayer/container/buttons/ContinueButton.text = "PLAY AGAIN"
		show()
		$MenuLayer.show()
		$Background.show()
		$AudioStreamPlayer2D.stream = win_audio
		$AudioStreamPlayer2D.play()
			
	
