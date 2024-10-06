class_name Dungie extends "enemy.gd"

signal on_crash

@onready var sprite = $AnimatedSprite2D
@onready var patrol_point = $PatrolPoint

@export var patrol_speed = 30.0
@export var charge_speed = 60.0

@export var crash_cooldown = 1.5

var time_since_crash = crash_cooldown + 1

func _ready() -> void:
	velocity = Vector2(-patrol_speed, 0)
	CurrentState = EnemyState.IDLE
	NextState = EnemyState.IDLE
	aggro_range = 100.0

func _physics_process(delta: float) -> void:
	sprite.speed_scale = 1
	
	var time_before = time_since_crash
	time_since_crash += delta
	if time_before < crash_cooldown and time_since_crash >= crash_cooldown:
			position += (get_room_center() - global_position).normalized() * 10
	
	if alive and time_since_crash > crash_cooldown:
		change_state()
		if (player.get_control_position() - global_position).length() < 128:
			velocity += (player.get_control_position() - global_position) * delta * 0.15
			velocity += velocity.normalized() * 10 * delta
			velocity = velocity.limit_length(charge_speed)
		else:
			velocity += (get_room_center() - global_position) * delta * 0.15
			velocity = velocity.limit_length(patrol_speed)
		
		
		if move_and_slide():
			velocity = Vector2.ZERO
			on_crash.emit()
			$BonkAudioPlayer.play()
			time_since_crash = 0
			NextState = EnemyState.IDLE
			sprite.play("idle")
		else:
			var v = get_real_velocity()
			if v.length() > 1.0:
				if (player.get_control_position() - global_position).length() < aggro_range:
					print("aggro")
			
					rotation = atan2(v.y, v.x)
					sprite.play("roll")
					sprite.speed_scale = velocity.length() / 50.0 * 2
					NextState = EnemyState.ATTACKING
					$RunAudioPlayer.pitch_scale = velocity.length() / 100.0 * 2
			else:
				sprite.speed_scale = 1.0
				sprite.play("idle")

func change_state():
	if CurrentState != NextState:
		CurrentState = NextState
		match(CurrentState):
			EnemyState.ATTACKING:
				$RunAudioPlayer.play()
			EnemyState.IDLE:
				$RunAudioPlayer.stop()
				$RunAudioPlayer.pitch_scale = 0.01

func _process(delta: float) -> void:
	$Concussion.rotation = -rotation
	$Concussion.global_position = $BodyArea/CollisionShape2D.global_position + Vector2(0, -10)
	
	super._process(delta)
	
	var concussed = alive and time_since_crash < crash_cooldown
	$Concussion.visible = concussed
	if concussed:
		$RunAudioPlayer.stop()
		$GPUParticles2D.emitting = false
		$GPUParticles2D2.emitting = false
	elif alive:
		$GPUParticles2D.emitting = true
		$GPUParticles2D2.emitting = true
		
	
func _lethal() -> bool:
	return true

func _on_died() -> void:
	sprite.play("die")
	$Shadow.stop()
	$GPUParticles2D.emitting = false
	$GPUParticles2D2.emitting = false
	$RunAudioPlayer.stop()

func _on_animated_sprite_2d_animation_finished() -> void:
	if not alive:
		sprite.play("dead")
