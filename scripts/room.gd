@tool
class_name Room
extends Node2D

const DUNGIE_ENCOUNTER = preload("res://scenes/encounters/dungie_encounter.tscn")
const BEETLE_ENCOUNTER = preload("res://scenes/encounters/beetle_encounter.tscn")
const NORMAL_ENCOUNTERS = [DUNGIE_ENCOUNTER, BEETLE_ENCOUNTER]

var coords: Vector2i = Vector2i.ZERO
var is_open: bool = false
var player: Player
var level: LevelManager
var visited = false
var cleared = false
var layout: String

@export var encounter: PackedScene
var node: Node2D

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
	
func _on_clear():
	cleared = true
	open()
	
	for child in get_children():
		if is_instance_of(child, Gate):
			child.unlock()

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	process_mode = PROCESS_MODE_DISABLED
	
	if encounter == null:
		encounter = NORMAL_ENCOUNTERS.pick_random()
	node = encounter.instantiate()
	add_child(node)

	for child in node.get_children():
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not Engine.is_editor_hint():
		if not cleared:
			var all_dead = true
			for child in node.get_children():
				if is_instance_of(child, Enemy):
					if child.alive:
						all_dead = false
			#print("all_dead ", all_dead)
			if all_dead:
				_on_clear()

func on_camera_land():
	print(coords)
	if not cleared:
		for child in get_children():
			if is_instance_of(child, Gate):
				child.lock()
				child.visible = true
