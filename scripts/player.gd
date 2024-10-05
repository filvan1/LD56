extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	velocity = Vector2.ZERO
	velocity = Input.get_vector("move_left", "move_right", "move_up", "move_down")
		
	if velocity.length_squared() > 0.0001:
		velocity = velocity / velocity.length() * 50.0
		
	move_and_slide()
	
	var effective_velocity = get_real_velocity()
	if effective_velocity.length_squared() > 1.0:
		rotation = atan2(effective_velocity.y, effective_velocity.x)
		sprite.play("walk")
	else:
		sprite.play("idle")
		
