class_name Room
extends Node2D

const NORMAL_ENCOUNTERS = [
	preload("res://scenes/encounters/beetle_encounter.tscn"),
	preload("res://scenes/encounters/double_beetle_encounter.tscn"),
	preload("res://scenes/encounters/rolypoly_encounter.tscn"),
]

const TREASURE_ENCOUNTERS = [
	preload("res://scenes/encounters/treasure_encounter_damage.tscn"),
	preload("res://scenes/encounters/treasure_encounter_firerate.tscn"),
	preload("res://scenes/encounters/treasure_encounter_speed.tscn"),
]
	
const BOSS_ENCOUNTERS = [
	preload("res://scenes/encounters/dungie_encounter.tscn"),
]

var coords: Vector2i = Vector2i.ZERO
var is_open: bool = false
var player: Player
var level: LevelManager
var visited = false
var cleared = false
var layout: String

@export var encounter_scene: PackedScene
var encounter: Encounter

func on_leave():
	print("left ", coords)
	for child in get_children():
		if is_instance_of(child, Gate):
			child.unlock_immediately()
			child.visible = false
	
func on_enter():
	visited = true
	print("entered ", coords)
	process_mode = PROCESS_MODE_INHERIT

func open():
	is_open = true
	
func _on_complete():
	level.encounter_finish.emit(encounter)
	cleared = true
	open()
	
	for child in get_children():
		if is_instance_of(child, Gate):
			child.unlock()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	
	process_mode = PROCESS_MODE_DISABLED
	
	if encounter_scene == null:
		if layout.contains("B"):
			encounter_scene = BOSS_ENCOUNTERS.pick_random()
		elif layout.contains("T"):
			encounter_scene = TREASURE_ENCOUNTERS.pick_random()
		else:
			encounter_scene = NORMAL_ENCOUNTERS.pick_random()

	encounter = encounter_scene.instantiate()
	encounter.is_boss = layout.contains("B")
		
	add_child(encounter)

	for child in encounter.get_children():
		if is_instance_of(child, Enemy):
			child.player = player
			
	if not Engine.is_editor_hint():
		process_mode = PROCESS_MODE_DISABLED
		
		if not layout.contains("E"):
			remove_child($East)
		if not layout.contains("N"):
			remove_child($North)
		if not layout.contains("W"):
			remove_child($West)
		if not layout.contains("S"):
			remove_child($South)
			
		for child in get_children():
			if is_instance_of(child, Gate):
				child.visible = false
				if cleared:
					child.unlock_immediately()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		if not cleared:
			if encounter.is_complete():
				_on_complete()

func on_camera_land():
	print(coords)
	if not cleared:
		for child in get_children():
			if is_instance_of(child, Gate):
				child.lock()
				child.visible = true
		level.encounter_start.emit(encounter)
