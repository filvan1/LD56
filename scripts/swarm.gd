@tool
extends Node2D

@export var avoidance: float = 1.0
@export var alignment: float = 1.0
@export var cohesion: float = 1.0
@export var tracking: float = 1.0
@export var random: float = 1.0

@export var avoidance_range: float = 10.0
@export var visual_range: float = 50.0

@export var show_ranges: bool = false

var tracking_target: Vector2 = Vector2.ZERO
var center_of_mass: Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _draw():
	if show_ranges:
		draw_circle(tracking_target, avoidance_range, Color.RED, false)
		draw_circle(tracking_target, visual_range, Color.YELLOW, false)
	
func _process(delta: float):
	if show_ranges:
		queue_redraw()
		
func get_swarming_ants():
	return get_children().filter(func(a): return a.alive and a.state == Ant.AntState.SWARMING)
	
func get_alive_ants():
	return get_children().filter(func(a): return a.alive)

func get_ant_count():
	return get_child_count()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if not Engine.is_editor_hint():
		center_of_mass = Vector2.ZERO
		var swarming_ants = get_swarming_ants()
		
		for a: Ant in swarming_ants:
			center_of_mass += a.position / swarming_ants.size()
			
			var avoidance_vector = Vector2.ZERO
			var alignment_vector = Vector2.ZERO
			var cohesion_vector = Vector2.ZERO
			
			var total_alignment_weight = 0
			var total_cohesion_weight = 0
			
			for b: Ant in get_children():
				if a == b or not b.alive:
					continue
					
				var v = b.position - a.position
				
				if v.length() < avoidance_range:
					avoidance_vector -= v
					
				if v.length() < visual_range:
					# If another ant is within our visual range and they're homing, they've
					# now reached the swarm.
					if b.state == Ant.AntState.HOMING:
						b.state = Ant.AntState.SWARMING
						
					if b.state == Ant.AntState.SWARMING:
						total_alignment_weight += 1
						total_cohesion_weight += 1
						alignment_vector += b.velocity
						cohesion_vector += b.position
					
			if total_alignment_weight > 0:
				alignment_vector = alignment_vector / total_alignment_weight - a.velocity
			if total_cohesion_weight > 0:
				cohesion_vector = cohesion_vector / total_cohesion_weight - a.position
				
			var tracking_vector = tracking_target - a.position
			
			var random_vector = Vector2.from_angle(randf_range(0, 2*PI))
			
			a.new_velocity = a.velocity + (avoidance_vector * avoidance + alignment_vector * alignment + cohesion_vector * cohesion + tracking_vector * tracking + random_vector * random) * delta

		for a: Ant in get_children():
			if a.alive and a.state == Ant.AntState.HOMING:
				# Simply move towards swarm CoM
				a.new_velocity = center_of_mass - a.position
