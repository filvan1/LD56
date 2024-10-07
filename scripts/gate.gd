class_name Gate
extends Node2D

var locked = false

@export var open_curve: Curve

enum State { OPEN, OPENING, CLOSED, CLOSING }
var state = State.CLOSED
var t = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$StaticBody2D/CollisionShape2D.disabled = true
	$Sprite.position.x = open_curve.sample(1)
	state = State.OPEN

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	t += delta
	
	if state == State.OPEN:
		pass
	elif state == State.CLOSED:
		pass
	elif state == State.OPENING:
		if t >= 1:
			state = State.OPEN
			$StaticBody2D/CollisionShape2D.disabled = true
		$Sprite.position.x = open_curve.sample(t)
	elif state == State.CLOSING:
		if t >= 2:
			state = State.CLOSED
		$Sprite.position.x = open_curve.sample(1 - t)

func unlock():
	if state == State.OPEN:
		return
	t = 0
	state = State.OPENING
	
func unlock_immediately():
	state = State.OPEN
	$StaticBody2D/CollisionShape2D.disabled = true
	$Sprite.position.x = open_curve.sample(1)
	
func lock():
	$StaticBody2D/CollisionShape2D.disabled = false
	if state == State.CLOSED:
		return
	t = 0
	state = State.CLOSING
