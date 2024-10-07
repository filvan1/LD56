class_name Beetle extends "enemy.gd"

enum AttackingStates {NONE, WINDUP, CHARGING, BITING}
enum MoveStates {NONE, TURNING, WALKING}

@onready var sprite = $AnimatedSprite2D
@onready var dash_particles_l = $DashParticlesL
@onready var dash_particles_r = $DashParticlesR

var current_attack_state = AttackingStates.NONE
var windup_time = 2.0
var charge_time = 0.5
var attack_counter = 0.0
var attack_start_pos = Vector2(0,0)
var attack_target_pos = Vector2(0,0)
var target_angle_diff = 0.0
var t = 0
var step = 1

var idle_limit = 1.0

var current_move_state = MoveStates.NONE
var move_counter = 0.0
var p0 = global_position
var p1 = p0 + Vector2(5.0, 0.0).rotated(rotation)
var p2 = p0 + Vector2(0, 5.0).rotated(rotation)
var move_dir = rand.randi_range(-1, 1)

signal on_charge

func _ready() -> void:
	aggro_range = 100.0
	activity_time = 1.0
	CurrentState = EnemyState.IDLE
	NextState = EnemyState.IDLE
	sprite.play("idle")
	sprite.speed_scale = 0.5

func _physics_process(delta: float) -> void:
	if not alive:
		return
	match(CurrentState):
		EnemyState.NONE: pass
		# Moving state
		EnemyState.MOVING:
			match(current_move_state):
				MoveStates.TURNING:
					move_counter += delta
					var target_dir = rotation - 90 * move_dir
					
					if(move_counter < 1.0):
						rotation = rotate_toward(rotation, target_dir, delta * 2.0)
					elif(move_counter > 1.5):
						p0 = global_position
						p1 = p0 + Vector2(20.0, 0.0).rotated(rotation)
						p2 = p0 + Vector2(20.0, move_dir * 20.0).rotated(rotation)
						current_move_state = MoveStates.WALKING
						move_counter = 0.0
				MoveStates.WALKING:
					
					move_counter += delta
					velocity = Vector2(10.0, 0).rotated(rotation)
					move_and_slide()
					if(move_counter > 2.0):
						current_move_state = MoveStates.NONE
						CurrentState = EnemyState.IDLE
						move_counter = 0.0

		# Attacking state
		EnemyState.ATTACKING:
			match(current_attack_state):
				AttackingStates.WINDUP:
					sprite.speed_scale = 0.5
					attack_counter += delta
					target_angle_diff = rotate_towards_point(player.get_control_position(), delta * 2.0)
					var target_dir = (player.get_control_position() - global_position).normalized()
					
					velocity = -Vector2(5.0, 0).rotated(target_dir.angle())
					move_and_slide()
					if(target_angle_diff < 0.01 && attack_counter > 3.0):
						attack_counter = 0
						attack_start_pos = global_position
						attack_target_pos = global_position + (player.get_control_position() - global_position).normalized() * 50.0
						current_attack_state = AttackingStates.CHARGING
						
						$DashStreamPlayer.play()
						disengage.emit()
						on_charge.emit()
						$/root/World/Camera.shake()
						dash_particles_l.emitting = true
						dash_particles_r.emitting = true
						
				
				AttackingStates.CHARGING:
						
					sprite.speed_scale = 2
					attack_counter += delta
					velocity = Vector2(80.0, 0).rotated(rotation)
					move_and_slide()
					#get_bezier_position(attack_start_pos, attack_target_pos, attack_target_pos, attack_counter)

					if(attack_counter > 0.5):
						attack_counter = 0
						current_attack_state = AttackingStates.BITING
						$BiteStreamPlayer.play()
						sprite.play("attack")
					
				AttackingStates.BITING:
					sprite.speed_scale = 2
					attack_counter += delta
					#get_bezier_position(attack_start_pos, attack_target_pos, attack_target_pos, attack_counter)
					if(attack_counter > 1.0):
						sprite.play("idle")
						
						sprite.speed_scale = 0.5
						attack_counter = 0
						current_attack_state = AttackingStates.NONE
						CurrentState = EnemyState.IDLE
			

	t += delta / activity_time
	# change state if idle
	if (CurrentState == EnemyState.IDLE):
		if(t > idle_limit):
			match(CurrentState):
				EnemyState.MOVING:
					if((player.get_control_position() - global_position).length() < aggro_range):
						NextState = EnemyState.ATTACKING
						
						sprite.play("move")
					else:
						NextState = EnemyState.IDLE
						sprite.play("idle")
					
	
				EnemyState.IDLE:
					if((player.get_control_position() - global_position).length() < aggro_range):
						NextState = EnemyState.ATTACKING
						current_attack_state = AttackingStates.WINDUP
						attack_start_pos = global_position
						sprite.play("move")
					
					else:
						NextState = EnemyState.MOVING
						current_move_state = MoveStates.TURNING
						
						move_dir = rand.randi_range(-1, 1)
						sprite.play("move")
					
						
			
		CurrentState = NextState



func _process(delta: float) -> void:
	if not alive:
		return
		
	super._process(delta)

	
	
func _lethal() -> bool:
	return current_attack_state == AttackingStates.BITING

func _on_died() -> void:
	sprite.play("die")
	print("ded")
	$BiteStreamPlayer.stop()
