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

var active_room: Room
var rooms: Dictionary = {}

const RoomNode = preload("res://scenes/room.tscn")

signal encounter_start(encounter: Encounter)
signal encounter_finish(encounter: Encounter)

func enter_room(room: Vector2i, teleport: bool):
	if active_room != null:
		active_room.on_leave()
	active_room = get_room(room)
	active_room.on_enter()
	print("open: ", room_is_open(room))

func get_room(at: Vector2i) -> Room:
	return rooms[at]
	
func room_is_open(room: Vector2i):
	return get_room(room).is_open

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
	for child in $Rooms.get_children():
		$Rooms.remove_child(child)
		
	rooms = {}
	
	for row in level_grid:
		for room in row:
			if room != null:
				var room_coords = calculate_room_coords(index)
				var room_node = RoomNode.instantiate()
				room_node.coords = room_coords
				room_node.position = get_room_center(room_coords)
				room_node.player = player
				room_node.level = self
				room_node.layout = room
				rooms[room_coords] = room_node
				
				if room.contains("A"):
					start_room = room_coords
					room_node.open()
					room_node.cleared = true
					room_node.encounter_scene = preload("res://scenes/encounters/start_encounter.tscn")
					
				$Rooms.add_child(room_node)
					
				tiles = room_factory.generate(room)
				var base = room_tile_position(room_coords)
				
				for x in range(0, 8):
					for y in range(0, 8):
						var tile_index = tiles[x][y]
						if tile_index != null:
							tilemap.set_cell(base+ Vector2i(x,y), 0, Vector2i(tile_index % 10, tile_index / 10))
			index += 1
			
	# Open all start room neighbors.
	
	
	#print($Rooms.get_children())
	print("start position: ", start_room)
	print(get_start_position())

func calculate_room_coords(index) -> Vector2i:
	return Vector2i((index % level_grid_size), (index / level_grid_size))

func room_tile_position(room: Vector2i):
	return 8 * room
	
func get_room_center(room: Vector2i):
	return Vector2(room_tile_position(room)) * 32 + Vector2(128, 128)
	
func get_start_position() -> Vector2:
	return get_room_center(start_room)

func _on_camera_camera_land() -> void:
	active_room.on_camera_land()
