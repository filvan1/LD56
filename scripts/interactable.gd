extends Area2D

signal picked

enum InteractableType {ANTS, FIRE, SPEED, DAMAGE}

@export var interactable_type: InteractableType = InteractableType.ANTS

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_body_entered(body:Node2D) -> void:
	var other_owner = body.owner
	if is_instance_of(other_owner, Player):
		match(interactable_type):
			InteractableType.ANTS:
				other_owner._spawn_ants(5)
			InteractableType.FIRE:
				other_owner.shoot_cooldown -= 0.1
			InteractableType.DAMAGE:
				other_owner.damage_upgrade(10.0)
			InteractableType.SPEED:
				print("SPEED")

		$CollisionShape2D.call_deferred("set_disabled", false)
		picked.emit()
		hide()

	
func _on_picked() -> void:
	$CollisionShape2D.call_deferred("set_disabled", false)
	hide()

