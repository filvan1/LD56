class_name Encounter
extends Node

@export var is_boss = false

signal complete

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_health():
	var health = 0
	for child in get_children():
		if is_instance_of(child, Enemy):
			health += child.get_health()
	return health
	
func get_max_health():
	var max = 0
	for child in get_children():
		if is_instance_of(child, Enemy):
			max += child.get_max_health()
	return max
	
func is_complete():
	var all_dead = true
	for child in get_children():
		if is_instance_of(child, Enemy):
			if child.alive:
				all_dead = false
	#print("all_dead ", all_dead)
	return all_dead
