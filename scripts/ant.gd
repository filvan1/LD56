class_name Ant
extends CharacterBody2D

@onready var sprite = $AnimatedSprite2D
@export var trajectory: Curve

enum AntState { SWARMING, YEETING, HOMING }

var state = AntState.SWARMING

var new_velocity: Vector2 = Vector2.ZERO
var max_speed: float = 40.0

var origin: Vector2
var target: Vector2
var t: float = 0.0

var alive = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if state == AntState.YEETING:
		t += delta
		
		if t > 1.0:
			_land()
		else:
			position = origin + (target - origin) * t
			position.y -= trajectory.sample(t)
			rotation += delta

func _land():
	state = AntState.HOMING
	
func yeet(to: Vector2):
	origin = position
	target = to
	t = 0
	state = AntState.YEETING
	
func _physics_process(delta: float) -> void:
	if state == AntState.SWARMING or state == AntState.HOMING:
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
			
