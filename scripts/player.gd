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
	
	if Input.is_action_pressed("ui_up"):
		velocity.y -= 1.0
	if Input.is_action_pressed("ui_down"):
		velocity.y += 1.0
	if Input.is_action_pressed("ui_left"):
		velocity.x -= 1.0
	if Input.is_action_pressed("ui_right"):
		velocity.x += 1.0
		
	if velocity.length_squared() > 0.0001:
		velocity = velocity / velocity.length() * 50.0
		
	move_and_slide()
	
	if velocity.length_squared() > 0.0001:
		rotation = atan2(velocity.y, velocity.x)
		sprite.play("walk")
	else:
		sprite.play("idle")
