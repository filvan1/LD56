extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_area_2d_body_entered(body:Node2D) -> void:
	if is_instance_of(body, Player):
		print("MORE ANTS!")
	else:
		print(body)
