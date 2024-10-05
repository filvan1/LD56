extends CharacterBody2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _spawn_ants(n: int):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	get_parent().get_node("Ants").tracking_target = position
	
func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO
	velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		
	if velocity.length_squared() > 0.0001:
		velocity = velocity / velocity.length() * 50.0
		
	move_and_slide()
	
	var effective_velocity = get_real_velocity()
