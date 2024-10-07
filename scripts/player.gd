class_name Player
extends Node2D

var max_speed: float = 35.0

@export var shoot_cooldown = 0.5
@export var shoot_range = 20.0

@export var windup_time = 0.5
@export var aim_grace_period = 1.0

@onready var aim_indicator = $AimIndicator
@onready var swarm: Swarm = $Ants

var time_since_fire: float = 1000
var time_since_aim: float = aim_grace_period + 1
var current_room_coords = Vector2i.ZERO
var is_aiming = false
var teleporting = false

const initial_ants = 20

signal enter_room(coords: Vector2i, teleport: bool)
signal die
signal pause_game

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_spawn_ants(initial_ants, global_position)# Replace with function body.

func _spawn_ants(n: int, spawn_position = $Control.global_position):
	for i in n:
		swarm.spawn_ant(spawn_position)
	
func get_max_health():
	return swarm.get_ant_count()

func get_health():
	return swarm.get_alive_ants().size()
	
func get_ammo():
	return swarm.get_swarming_ants().size()

func damage_upgrade(value: float):
	swarm.add_ant_damage(value)
	
func get_room_coords():
	return Vector2i(($Control.global_position / Vector2(256, 256)).floor())
	
func get_control_position():
	return $Control.global_position
	
func teleport(position: Vector2):
	teleporting = true
	global_position = position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time_since_fire += delta
	
	if get_health() == 0:
		die.emit()

	$Ants.tracking_target = $Ants.center_of_mass + Input.get_vector("move_left", "move_right", "move_up", "move_down") * 40
	#$Control.position
	
	var aim = Input.get_vector("aim_left", "aim_right", "aim_up", "aim_down")
	if aim.length() > 0.5:
		if not is_aiming:
			time_since_aim = 0
		else:
			time_since_aim += delta
		is_aiming = true
		
		aim = $Ants.center_of_mass + aim * shoot_range
		aim_indicator.position = aim
		aim_indicator.visible = true
		
		if time_since_aim > windup_time and time_since_fire > shoot_cooldown:
			_fire(aim)
	else:
		if is_aiming:
			time_since_aim = 0
		else:
			time_since_aim += delta
		is_aiming = false
		
		if time_since_aim > aim_grace_period:
			aim_indicator.visible = false
		
	var room_coords = get_room_coords()
	if room_coords != self.current_room_coords:
		self.current_room_coords = room_coords
		enter_room.emit(room_coords, teleporting)
		teleporting = false

	if Input.is_action_just_pressed("pause"):
		pause_game.emit()
		
		
func _fire(aim: Vector2):
	$Control/YeetAudioSource.pitch_scale = 1.0 + randf_range(-.3, .3)
	$Control/YeetAudioSource.play()
	var candidates = swarm.get_swarming_ants()
	if candidates.size() <= 1:
		return
		
	time_since_fire = 0
	
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
