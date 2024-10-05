class_name Enemy extends Node2D

enum EnemyState {NONE, IDLE, MOVING, ATTACKING}
@export var CurrentState = EnemyState.NONE
@export var NextState = EnemyState.NONE
var counter = 0.0
var activity_time = 2.0
var rand = RandomNumberGenerator.new()
var aggro_range = 0.0
@export var player: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func set_activity_time(tim: float):
	activity_time = tim

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
	

func get_bezier_position(start_pos: Vector2, control_pos: Vector2, end_pos: Vector2, t: float) -> Vector2:
	return (1 - t) * ((1 - t) * start_pos + t * control_pos) + t * ((1 - t) * control_pos + t * end_pos)


func get_bezier_tangent( p0: Vector2, p1: Vector2, p2: Vector2, t: float) -> Vector2:
	return 2 * (1 - t) * (p1 - p0) + 2 * t * (p2 - p1)


func move_along_bezier(start_pos: Vector2, control_pos: Vector2, end_pos: Vector2, t: float) -> void:
	global_position = get_bezier_position(start_pos, control_pos, end_pos, t)
	rotation = get_bezier_tangent(start_pos, control_pos, end_pos, t).angle()

func rotate_towards_point(target_position: Vector2, t: float) -> float:
	var target_direction = (target_position - global_position).normalized()
	var target_angle = target_direction.angle()

	rotation = rotate_toward(rotation, target_angle, t)

	return absf(angle_difference(rotation, target_angle))
