class_name Rolypoly extends "enemy.gd"

signal on_crash

enum IdleStates {NONE, CURLING}
enum AttackingStates {NONE, WINDUP, ROLLING}

@onready var sprite = $AnimatedSprite2D

@export var patrol_speed = 30.0
@export var charge_speed = 60.0

@export var roll_cooldown = 1.5
@export var roll_time = 5.0

var timer = 0
var current_attack_state = AttackingStates.NONE
var current_idle_state = IdleStates.NONE

func _ready() -> void:
	velocity = Vector2(-patrol_speed, 0)
	CurrentState = EnemyState.IDLE
	NextState = EnemyState.IDLE
	sprite.play("idle")
	aggro_range = 128.0

func _physics_process(delta: float) -> void:	
	if alive:
		
		sprite.speed_scale = 1
		timer += delta
		change_state()
		match(CurrentState):
			EnemyState.IDLE:
				match(current_idle_state):
					IdleStates.NONE:
						velocity = Vector2.ZERO
						if timer > roll_cooldown:
							sprite.play("curl")
							timer = 0
							current_idle_state = IdleStates.CURLING
					IdleStates.CURLING:
						velocity = Vector2.ZERO
						if timer > 2.0:
							current_attack_state = AttackingStates.WINDUP
							current_idle_state = IdleStates.NONE
							timer = 0
							NextState = EnemyState.ATTACKING
			
			EnemyState.ATTACKING:
				match(current_attack_state):
					AttackingStates.WINDUP:
						rotate_towards_point(player.get_control_position(), delta * 2.0)
						velocity = Vector2(-5.0, 0).rotated(rotation)
						move_and_slide()

						if(timer > 1.0):
							current_attack_state = AttackingStates.ROLLING
							sprite.play("roll")
							timer = 0
							velocity = Vector2(60.0, 0).rotated(rotation)
							$GPUParticles2D.emitting = true

					AttackingStates.ROLLING:
						var collision = move_and_collide(velocity * delta)
						if collision:
							on_crash.emit()
							#$/root/World/Camera.shake()
							velocity = velocity.bounce(collision.get_normal())
							$BonkAudioPlayer.play()
							#sprite.play("idle")
						else:
							#if (player.get_control_position() - global_position).length() < aggro_range:
							#	NextState = EnemyState.ATTACKING
							#	$RunAudioPlayer.pitch_scale = velocity.length() / 100.0 * 2
							rotation = atan2(velocity.y, velocity.x)
						
						if timer > roll_time:
							$GPUParticles2D.emitting = false
							sprite.play_backwards("curl")
							timer = 0
							NextState = EnemyState.IDLE
							current_attack_state = AttackingStates.NONE
		
		

func change_state():
	if CurrentState != NextState:
		CurrentState = NextState

func _process(delta: float) -> void:	
	super._process(delta)
	
		
	
func _lethal() -> bool:
	return current_attack_state == AttackingStates.ROLLING

func _on_died() -> void:
	sprite.play("die")
	$GPUParticles2D.emitting = false

