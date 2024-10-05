extends Node2D

var max_speed: float = 35.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _spawn_ants(n: int):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Ants.tracking_target = $Control.position
	
func _physics_process(delta: float) -> void:
	$Control.velocity = Vector2.ZERO
	$Control.velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		
	if $Control.velocity.length_squared() > 0.0001:
		$Control.velocity = $Control.velocity / $Control.velocity.length() * max_speed
		
	$Control.move_and_slide()
