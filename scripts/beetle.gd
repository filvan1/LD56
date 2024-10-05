class_name Beetle extends "enemy.gd"

enum AttackingStates {NONE, WINDUP, CHARGING}
enum MoveStates {NONE, TURNING, WALKING}

var current_attack_state = AttackingStates.NONE
var windup_time = 2.0
var charge_time = 0.5
var attack_counter = 0.0
var attack_start_pos = Vector2(0,0)
var attack_target_pos = Vector2(0,0)
var t = 0
var step = 1

var idle_limit = 1.0

var current_move_state = MoveStates.NONE
var move_counter = 0.0
var p0 = global_position
var p1 = p0 + Vector2(5.0, 0.0).rotated(rotation)
var p2 = p0 + Vector2(0, 5.0).rotated(rotation)
var move_dir = rand.randi_range(-1, 1)

func _ready() -> void:
	aggro_range = 200.0
	activity_time = 1.0
	CurrentState = EnemyState.IDLE

func _process(delta: float) -> void:

	match(CurrentState):
		EnemyState.NONE: pass
		# Moving state
		EnemyState.MOVING:
			match(current_move_state):
				MoveStates.TURNING:
					move_counter += delta
					
					
					if(move_counter < 1.0):
						rotation = rotate_toward(rotation, rotation + 90 * move_dir, delta)
						#rotate_towards_point(player.global_position, delta)
					elif(move_counter > 1.5):
						p0 = global_position
						print("done turning")
						p1 = p0 + Vector2(20.0, 0.0).rotated(rotation)
						p2 = p0 + Vector2(20.0, move_dir * 20.0).rotated(rotation)
						current_move_state = MoveStates.WALKING
						move_counter = 0.0
				MoveStates.WALKING:
					
					move_counter += delta
					
					if(move_counter < 1.0):
						move_along_bezier(p0, p1, p2, move_counter)
					elif(move_counter > 2.0):
						
						print("done walking")
						current_move_state = MoveStates.NONE
						CurrentState = EnemyState.IDLE
						move_counter = 0.0				
		# Attacking state
		EnemyState.ATTACKING:
			match(current_attack_state):
				AttackingStates.WINDUP:
					attack_counter += delta
					if(attack_counter < windup_time):
						rotate_towards_point(player.global_position, delta * 2.0)
						global_position = get_bezier_position(attack_start_pos, attack_start_pos - (player.global_position - global_position).normalized(), attack_start_pos - 2.0 * (player.global_position - global_position).normalized(), attack_counter / windup_time)
					else:
						attack_counter = 0
						attack_start_pos = global_position
						attack_target_pos = global_position + (player.global_position - global_position).normalized() * 50.0
						current_attack_state = AttackingStates.CHARGING
				
				AttackingStates.CHARGING:
					attack_counter += delta
					move_along_bezier(attack_start_pos, attack_target_pos, attack_target_pos, attack_counter)
					if(attack_counter > 1.0):
						attack_counter = 0
						current_attack_state = AttackingStates.NONE
						CurrentState = EnemyState.IDLE
			

	t += delta / activity_time
	# change state if idle
	if (CurrentState == EnemyState.IDLE):
		if(t > idle_limit):
			match(CurrentState):
				EnemyState.MOVING:
					if((player.global_position - global_position).length() < aggro_range):
						NextState = EnemyState.ATTACKING
						print("attacking")
					else:
						NextState = EnemyState.IDLE
						print("idle")
					
	
				EnemyState.IDLE:
					if((player.global_position - global_position).length() < aggro_range):
						NextState = EnemyState.ATTACKING
						current_attack_state = AttackingStates.WINDUP
						attack_start_pos = global_position
						print("attacking")
					
					else:
						NextState = EnemyState.MOVING
						current_move_state = MoveStates.TURNING
						
						move_dir = rand.randi_range(-1, 1)
						print("moving")
					
						
			
		CurrentState = NextState
	
	