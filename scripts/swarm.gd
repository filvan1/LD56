@tool
extends Node2D

@export var avoidance: float = 1.0
@export var alignment: float = 1.0
@export var cohesion: float = 1.0

@export var avoidance_range: float = 10.0
@export var visual_range: float = 50.0

var tracking_target: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _draw():
	draw_circle(tracking_target, avoidance_range, Color.RED, false)
	draw_circle(tracking_target, visual_range, Color.YELLOW, false)
	
func _process(delta: float):
	queue_redraw()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		for a: Ant in get_children():
			var avoidance_vector = Vector2.ZERO
			var alignment_vector = Vector2.ZERO
			var cohesion_vector = Vector2.ZERO
			
			var visible_neighbors = 0
			
			for b: Ant in get_children():
				if a == b:
					continue
					
				var v = b.position - a.position
				
				if v.length() < avoidance_range:
					avoidance_vector -= v
					
				if v.length() < visual_range:
					visible_neighbors += 1
					alignment_vector += b.velocity
					cohesion_vector += b.position
					
			alignment_vector = alignment_vector / visible_neighbors - a.position
			cohesion_vector = cohesion_vector / visible_neighbors - a.position
			a.new_velocity = a.velocity + (avoidance_vector * avoidance + alignment_vector * alignment + cohesion_vector * cohesion) * delta
