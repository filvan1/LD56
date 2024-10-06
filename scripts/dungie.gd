class_name Dungie extends "enemy.gd"

signal on_crash

@onready var sprite = $AnimatedSprite2D
@onready var patrol_point = $PatrolPoint

@export var patrol_speed = 30.0
@export var charge_speed = 60.0

func _ready() -> void:
	velocity = Vector2(-patrol_speed, 0)
	CurrentState = EnemyState.IDLE
	NextState = EnemyState.IDLE

func _physics_process(delta: float) -> void:
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
		position += (get_room_center() - global_position).normalized() * 10
		on_crash.emit()
		NextState = EnemyState.IDLE
	else:
		var v = get_real_velocity()
		if v.length() > 1.0:
		
			rotation = atan2(v.y, v.x)
			sprite.play("roll")
			sprite.speed_scale = velocity.length() / 50.0 * 2
			NextState = EnemyState.ATTACKING
			$AudioPlayer.pitch_scale = velocity.length() / 100.0 * 2
		else:
			sprite.speed_scale = 1.0
			sprite.play("idle")

func change_state():
	if CurrentState != NextState:
		CurrentState = NextState
		match(CurrentState):
			EnemyState.ATTACKING:
				$AudioPlayer.play()
			EnemyState.IDLE:
				$AudioPlayer.stop()
				$AudioPlayer.pitch_scale = 0.01

func _process(delta: float) -> void:
	#super._process(delta)
	pass
	
func _lethal() -> bool:
	return true
