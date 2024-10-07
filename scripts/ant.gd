class_name Ant
extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@export var trajectory: Curve

enum AntState { SWARMING, YEETING, HOMING, STUNNED, MURDERING}

var state = AntState.SWARMING

var new_velocity: Vector2 = Vector2.ZERO
var max_speed: float = 40.0

var origin: Vector2
var target: Vector2
var t: float = 0.0

var alive = true

var current_enemy: Enemy
var murder_target_position: Vector2
var murder_target_position_offset: Vector2
var murder_target_rotation_offset: float
var murder_timer = 0.0
var current_tick_number = 0
const max_damage_ticks = 5
const tick_time = 0.5
const fling_strength = 50.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$CollisionShape2D.disabled = (state == AntState.HOMING or state == AntState.MURDERING or not alive)
		
	if get_parent().get_swarming_ants().size() == 0 and self.alive and self.state == AntState.HOMING:
		# This means that we've yoten the last swarming ant but this one is still alive and homing.
		# Make this one the swarm.
		self.state = AntState.SWARMING

func _land():
	$LandAudioPlayer.play()
	state = AntState.HOMING
	
func die():
	alive = false
	
func yeet(to: Vector2):
	origin = position
	target = to
	t = 0
	state = AntState.YEETING
	
func _physics_process(delta: float) -> void:
	if not alive:
		return

	if state == AntState.MURDERING:
		murder_timer += delta
		global_position = current_enemy.global_position + murder_target_position_offset.rotated(current_enemy.rotation - murder_target_rotation_offset)
		
		if murder_timer > tick_time:
			current_enemy._take_damage(10.0)
			current_tick_number += 1
			murder_timer = 0
			$ParticleEmitter.restart()
			$ClickAudioPlayer.play()
			
		
		if current_tick_number >= max_damage_ticks:
			
			$ParticleEmitter.emitting = false
			state = AntState.HOMING
			murder_timer = 0
			current_tick_number = 0
			
	if state == AntState.YEETING or state == AntState.MURDERING:
		z_index = 100
	else:
		z_index = 0

	if state == AntState.SWARMING or state == AntState.HOMING:
		var speed = new_velocity.length()
		velocity = new_velocity
		if speed > max_speed:
			velocity = new_velocity / speed * max_speed
		
		move_and_slide()
		
		velocity = get_real_velocity()
		if velocity.length_squared() > 1.0:
			rotation = atan2(velocity.y, velocity.x)
			sprite.play("walk")
		else:
			sprite.play("idle")
			
			
	if state == AntState.YEETING:
		t += delta
		
		if t > 1.0:
			_land()
		else:
			var dst = (origin + (target - origin) * t)
			dst.y -= trajectory.sample(t)
			
			velocity = (dst - position) / delta
			rotation += delta
			if move_and_slide():
				_land()
	
	if state == AntState.STUNNED:
		t += delta
		
		if t > 1.0:
			_land()
		else:
			var dst = (origin + (target - origin) * t)
			dst.y -= trajectory.sample(t)
			
			velocity = (dst - position) / delta
			rotation += delta
			move_and_slide()

			
func stop_murder():
	print("murder done")
	current_enemy.died.disconnect(stop_murder)
	current_enemy.disengage.disconnect(fling_away)
	current_enemy = null
	state = AntState.HOMING

func fling_away():
	current_enemy.died.disconnect(stop_murder)
	current_enemy.disengage.disconnect(fling_away)
	current_enemy = null
	origin = position
	target = position + fling_strength * Vector2(randf(), randf())
	t = 0
	state = AntState.STUNNED

func on_hit(enemy: Enemy):
	current_enemy = enemy
	current_enemy.died.connect(stop_murder)
	current_enemy.disengage.connect(fling_away)
	
	$ClickAudioPlayer.play()
	
	murder_target_position_offset = global_position - enemy.global_position
	murder_target_rotation_offset = enemy.rotation
	
	state = AntState.MURDERING
