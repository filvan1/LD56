@tool
extends Sprite2D

@export var player: Node2D

@export var debug_max = 100
@export var debug_health = 100
@export var debug_ammo = 100

var current_encounter: Encounter

var width: int

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	width = $ammo.region_rect.size.x
	if not Engine.is_editor_hint():
		visible = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		$ammo.region_rect.size.x = debug_ammo / debug_max * width
		$health.region_rect.size.x = debug_health / debug_max * width
	else:
		if current_encounter and (current_encounter.is_boss or current_encounter.show_healthbar):
			visible = true
			var max = current_encounter.get_max_health()
			var ammo = current_encounter.get_health()
			var health = ammo
			#var max = player.get_max_health() as float
			#var health = player.get_health() as float
			#var ammo = player.get_ammo() as float
			
			$ammo.region_rect.size.x = ammo / max * width
			$health.region_rect.size.x = health / max * width
		else:
			visible = false
			


func _on_level_manager_encounter_start(encounter: Encounter) -> void:
	current_encounter = encounter


func _on_level_manager_encounter_finish(encounter: Encounter) -> void:
	current_encounter = null
