@tool
class_name LevelManager
extends Node2D

@export var regenerate: bool:
	set(value):
		if Engine.is_editor_hint():
			generate()

@export var player: Player

var level_grid_size = 5
var start_room: Vector2i

var active_room: Vector2i
var states: Dictionary = {}

func enter_room(room: Vector2i):
	active_room = room
	print("open: ", room_is_open(room))
	
func room_is_open(room: Vector2i):
	return room in states

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if not Engine.is_editor_hint():
		generate()
		player.teleport(get_start_position())
		
	
func generate():
	var room_factory = get_node("RoomFactory")
	
	var layout_generator = get_node("LayoutGenerator")
	var level_grid = layout_generator.generate_level()
	var index = 0
	var tiles
	
	var tilemap : TileMapLayer = get_node("TileMapLayer")
	print(level_grid)
	
	for row in level_grid:
		for room in row:
			if room != null:
				var room_coords = calculate_room_coords(index)
				if room.contains("A"):
					start_room = room_coords
				tiles = room_factory.generate(room)
				var base = room_tile_position(room_coords)
				
				for x in range(0, 8):
					for y in range(0, 8):
						var tile_index = tiles[x][y]
						if tile_index != null:
							tilemap.set_cell(base+ Vector2i(x,y), 0, Vector2i(tile_index % 10, tile_index / 10))
			index += 1
			
	print("start position: ", start_room)
	print(get_start_position())
	
	states = { start_room: true }

func calculate_room_coords(index) -> Vector2i:
	return Vector2i((index % level_grid_size), (index / level_grid_size))

func room_tile_position(room: Vector2i):
	return 8 * room
	
func get_start_position() -> Vector2:
	return Vector2(room_tile_position(start_room)) * 32 + Vector2(128, 128)
