class_name Ant
extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D

@export var min_speed: float = 10.0
@export var max_speed: float = 80.0

var new_velocity: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _physics_process(delta: float) -> void:
	var speed = new_velocity.length()
	if speed > max_speed:
		velocity = new_velocity / speed * max_speed
	elif speed < min_speed and speed > 0.1:
		velocity = new_velocity / speed * min_speed
	
	move_and_slide()
	
	velocity = get_real_velocity()
	if velocity.length_squared() > 1.0:
		rotation = atan2(velocity.y, velocity.x)
		sprite.play("walk")
	else:
		sprite.play("idle")
