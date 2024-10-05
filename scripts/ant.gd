class_name Ant
extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D

var new_velocity: Vector2 = Vector2.ZERO
var max_speed: float = 40.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	var speed = new_velocity.length()
	velocity = new_velocity
	if speed > max_speed:
		velocity = new_velocity / speed * max_speed
	
	move_and_slide()
	
	velocity = get_real_velocity()
	if velocity.length_squared() > 1.0:
		rotation = atan2(velocity.y, velocity.x)
		sprite.play("walk")
	else:
		sprite.play("idle")
		
