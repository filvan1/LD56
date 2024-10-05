class_name AntProjectile
extends StaticBody2D

var origin: Vector2
var target: Vector2
var t: float = 0.0

@export var trajectory: Curve

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	t += delta
	
	if t > 1.0:
		_land()
	else:
		position = origin + (target - origin) * t
		position.y -= trajectory.sample(t)
		rotation += delta

func _land():
	pass
