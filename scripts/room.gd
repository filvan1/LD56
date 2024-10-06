@tool
class_name Room
extends Node2D

const DUNGIE_ENCOUNTER = preload("res://scenes/encounters/dungie_encounter.tscn")
const NORMAL_ENCOUNTERS = [DUNGIE_ENCOUNTER]

var coords: Vector2i = Vector2i.ZERO
var is_open: bool = false
var player: Player
var level: LevelManager
var visited = false
var cleared = false
var layout: String

func on_leave():
	print("left ", coords)
	
func on_enter():
	visited = true
	print("entered ", coords)
	process_mode = PROCESS_MODE_INHERIT
	
func on_ready():
	process_mode = PROCESS_MODE_DISABLED

func open():
	is_open = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var encounter = NORMAL_ENCOUNTERS.pick_random()
	var node = encounter.instantiate()
	add_child(node)
	
	for child in node.get_children():
		if is_instance_of(child, Enemy):
			child.player = player

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
