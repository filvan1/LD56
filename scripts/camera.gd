extends Node2D

@export var shake_duration = 0.5
@export var curve_x: Curve
@export var curve_y: Curve
@export var shake_scale = 10.0

var t = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func shake():
	t = 0.0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	t += delta / shake_duration
	if t > 1.0:
		$Camera.position = Vector2.ZERO
	else:
		$Camera.position = shake_scale * Vector2(curve_x.sample(t), curve_y.sample(t))
