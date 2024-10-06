extends Node2D

var room_data = []
var level_grid_size = 5
var start_position: Vector2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	var room_factory = get_node("RoomFactory")
	
	var layout_generator = get_node("LayoutGenerator")
	var level_grid = layout_generator.get_layout()
	var index = 0
	var tiles
	
	var tilemap : TileMapLayer = get_node("TileMapLayer")
	
	for row in level_grid:
		for room in row:
			if room != null:
				if room.contains("A"):
					start_position = calculate_offset(index) * 8
				tiles = room_factory.generate(room)
				var base = calculate_offset(index)
				
				for x in range(0, 8):
					for y in range(0, 8):
						var tile_index = tiles[x][y]
						print(tile_index)
						if tile_index != null:
							tilemap.set_cell(base+ Vector2i(x,y), 0, Vector2i(tile_index % 10, tile_index / 10))
			index += 1
	print("start position: ")
	print(start_position)
	


func calculate_offset(index):
	return Vector2i(8 * (index % level_grid_size), 8 * (index / level_grid_size))
	
func get_start_position():
	return start_position + Vector2(128, 128)
