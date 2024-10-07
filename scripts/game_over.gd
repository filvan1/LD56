extends Control

signal win_for_real

@onready var win_audio = preload("res://sounds/fanfar.wav")
@onready var lose_audio = preload("res://sounds/you_died.wav")

func _ready() -> void:
	hide()
	$MenuLayer.hide()
	$Background.hide()

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
	$AudioStreamPlayer.stream = lose_audio
	$AudioStreamPlayer.play()

func _on_level_manager_encounter_finish(encounter:Encounter) -> void:
	if encounter.is_boss:
		win_for_real.emit()
		show()
		$MenuLayer.show()
		$Background.show()
		$AudioStreamPlayer.stream = win_audio
		$AudioStreamPlayer.play()
			
	
