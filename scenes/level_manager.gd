extends Node2D

var room_data = []
var start_position
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var room_factory = get_node("RoomFactory")
	
	var layout_generator = get_node("LayoutGenerator")
	var level_grid = layout_generator.get_layout()
	var index = 0
	
	
	for room in level_grid:
		if room != null:
			
			room_factory.generate(room, index)
		index +=1
			
		
	
