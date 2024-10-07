extends Area2D

signal picked

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_area_2d_body_entered(body:Node2D) -> void:
	var other_owner = body.owner
	if is_instance_of(other_owner, Player):
		other_owner.shoot_cooldown -= 0.1
		$CollisionShape2D.disabled = true
		picked.emit()
		hide()

	
func _on_picked() -> void:
	$CollisionShape2D.disabled = true
	hide()
