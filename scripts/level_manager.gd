extends Node2D

var room_data = []
var start_position
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var room_factory = get_node("RoomFactory")
	
	var layout_generator = get_node("LayoutGenerator")
	var level_grid = layout_generator.get_layout()
	var index = 0
	
	
	for row in level_grid:
		for room in row:
			if room != null:
				if room.contains("A"):
					start_position = calculate_offset(index)
				room_factory.generate(room, calculate_offset(index))
			index +=1
	print("start position: ")
	print(start_position)
	


func calculate_offset(index):
	return Vector2(128 * (index % 5), -128 * (index / 5))
	
