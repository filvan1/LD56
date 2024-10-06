class_name Dungie extends "enemy.gd"

signal on_crash

@onready var sprite = $AnimatedSprite2D
@onready var patrol_point = $PatrolPoint

@export var patrol_speed = 30.0
@export var charge_speed = 60.0

func _ready() -> void:
	velocity = Vector2(-patrol_speed, 0)

func _physics_process(delta: float) -> void:
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

	var v = get_real_velocity()
	if v.length() > 1.0:
		rotation = atan2(v.y, v.x)
		sprite.play("roll")
		sprite.speed_scale = velocity.length() / 50.0 * 2
	else:
		sprite.speed_scale = 1.0
		sprite.play("idle")

func _process(delta: float) -> void:
	#super._process(delta)
	pass
	
func _lethal() -> bool:
	return true
