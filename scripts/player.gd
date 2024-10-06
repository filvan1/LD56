class_name Player
extends Node2D

var max_speed: float = 35.0

@export var shoot_cooldown = 0.5
@export var shoot_range = 20.0

@onready var aim_indicator = $AimIndicator
@onready var swarm: Swarm = $Ants

var cooldown_remaining: float = 0
var current_room_coords = Vector2i.ZERO

signal enter_room(coords: Vector2i)
signal pause_game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _spawn_ants(n: int):
	pass
	
func get_max_health():
	return swarm.get_ant_count()

func get_health():
	return swarm.get_alive_ants().size()
	
func get_ammo():
	return swarm.get_swarming_ants().size()
	
func get_room_coords():
	return Vector2i(($Control.global_position / Vector2(256, 256)).floor())
	
func get_control_position():
	return $Control.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	cooldown_remaining -= delta
	
	$Ants.tracking_target = $Ants.center_of_mass + Input.get_vector("move_left", "move_right", "move_up", "move_down") * 40
	#$Control.position
	
	var aim = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if aim.length() > 0.5:
		aim = $Ants.center_of_mass + aim * shoot_range
		aim_indicator.position = aim
		aim_indicator.visible = true
		
		if cooldown_remaining < 0:
			_fire(aim)
	else:
		aim_indicator.visible = false
		
	var room_coords = get_room_coords()
	if room_coords != self.current_room_coords:
		self.current_room_coords = room_coords
		enter_room.emit(room_coords)

	if Input.is_action_just_pressed("pause"):
		pause_game.emit()
		
		
func _fire(aim: Vector2):
	var candidates = swarm.get_swarming_ants()
	if candidates.size() == 0:
		return
		
	cooldown_remaining = shoot_cooldown
	
	# Choose random ant
	var ant = candidates.pick_random()
	ant.yeet(aim)
	
func _physics_process(delta: float) -> void:
	$Control.position = $Ants.center_of_mass
	#$Control.velocity = Vector2.ZERO
	#$Control.velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		
	#if $Control.velocity.length_squared() > 0.0001:
	#	$Control.velocity = $Control.velocity / $Control.velocity.length() * max_speed
		
	#$Control.move_and_slide()
