extends Node2D

@export var shake_duration = 0.5
@export var shake_x: Curve
@export var shake_y: Curve
@export var shake_scale = 8.0

@export var scroll_duration = 1.0
@export var scroll_curve: Curve

var shake_t = 1.0
var scroll_t = 1.0

var scroll_from = Vector2.ZERO
var scroll_to = Vector2.ZERO

const ROOM_SIZE = Vector2(256, 256)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func shake():
	shake_t = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	shake_t += delta / shake_duration
	if shake_t > 1.0:
		$Camera.position = Vector2.ZERO
	else:
		$Camera.position = shake_scale * Vector2(shake_x.sample(shake_t), shake_y.sample(shake_t))
		
	scroll_t += delta / scroll_duration
	if scroll_t > 1.0:
		position = scroll_to + ROOM_SIZE / 2
	else:
		position = scroll_from + (scroll_to - scroll_from) * scroll_curve.sample(scroll_t) + ROOM_SIZE / 2


func _on_player_enter_room(coords: Vector2i, teleport: bool) -> void:
	scroll_to = Vector2(coords) * ROOM_SIZE
	if not teleport:
		scroll_from = position - ROOM_SIZE / 2
		scroll_t = 0.0
