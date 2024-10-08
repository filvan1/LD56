@tool
extends Node

const GRID_SIZE = 5  # 5x5 grid
const ROOM_COUNT = 11

var grid = []

var entrance = Vector2()
var exit = Vector2()

func generate_level():
	# Initialize an empty grid
	grid = []
	for x in range(GRID_SIZE):
		var row = []
		for y in range(GRID_SIZE):
			row.append(null)  # Empty string, no room yet
		grid.append(row)
	
	# Place entrance room along the edge of the grid
	place_entrance()

	# Generate the rest of the rooms
	var room_positions = [entrance]
	while room_positions.size() < ROOM_COUNT:
		var current_room = room_positions[randi() % room_positions.size()]
		var new_room = find_empty_neighbor(current_room)
		if new_room != null:
			room_positions.append(new_room)
			grid[new_room[0]][new_room[1]] = ""
	
	# Connect all rooms
	for room in room_positions:
		if room_positions.has(room + Vector2(-1,0)):
			grid[room[0]][room[1]] += ("N")
		if room_positions.has(room + Vector2(0,1)):
			grid[room[0]][room[1]] += ("E")	
		if room_positions.has(room + Vector2(1,0)):
			grid[room[0]][room[1]] += ("S")
		if room_positions.has(room + Vector2(0,-1)):
			grid[room[0]][room[1]] += ("W")
	
	# Mark entrance
	grid[entrance.x][entrance.y] += "-A"
	
	# Place boss room
	var boss_hallway = find_farthest_room(entrance, room_positions)
	
	var boss_position = find_empty_neighbor(boss_hallway)
		
	if boss_position == null:
		boss_position = find_random_null_room()
		var temp_room = find_neighbor(boss_position)
		while(temp_room == null):
			boss_position = find_random_null_room()
			temp_room = find_neighbor(boss_position)
		boss_hallway = temp_room
	var direction = boss_position - boss_hallway
	grid[boss_position.x][boss_position.y] = ""
	if direction == Vector2(-1, 0):
		grid[boss_hallway.x][boss_hallway.y] += "N"
		grid[boss_position.x][boss_position.y] += "S"
	if direction == Vector2(1, 0):
		grid[boss_hallway.x][boss_hallway.y] += "S"
		grid[boss_position.x][boss_position.y] += "N"
	if direction == Vector2(0, -1):
		grid[boss_hallway.x][boss_hallway.y] += "W"
		grid[boss_position.x][boss_position.y] += "E"
	if direction == Vector2(0, 1):
		grid[boss_hallway.x][boss_hallway.y] += "E"
		grid[boss_position.x][boss_position.y] += "W"
	grid[boss_position.x][boss_position.y] += "-B"  # Mark the boss room
		
	
	# replace null values with empty string
	grid = replace_null_values(grid)
	
	# Place treasure rooms
	
	var possible_treasure_rooms = []
	var treasure_rooms = []
	for room in room_positions:
		if room != entrance && room != exit:
			possible_treasure_rooms.append(room)
	
	possible_treasure_rooms.sort_custom(func(a, b): return len(grid[a[0]][a[1]]) < len(grid[b[0]][b[1]]))
	treasure_rooms.append_array(possible_treasure_rooms.slice(0,3))

	for room in treasure_rooms:
		grid[room[0]][room[1]] += "-T"
		
	print_grid()
	return grid

# Randomly place the first room (entrance) along the edge of the grid
func place_entrance():
	var edge = randi() % 4  # Choose a random edge (0 = top, 1 = bottom, 2 = left, 3 = right)
	
	if edge == 0:  # Top edge
		entrance = Vector2(randi() % GRID_SIZE, 0)
	elif edge == 1:  # Bottom edge
		entrance = Vector2(randi() % GRID_SIZE, GRID_SIZE - 1)
	elif edge == 2:  # Left edge
		entrance = Vector2(0, randi() % GRID_SIZE)
	else:  # Right edge
		entrance = Vector2(GRID_SIZE - 1, randi() % GRID_SIZE)
	
	grid[entrance.x][entrance.y] = ""

# Find a valid neighboring spot for a new room
func find_empty_neighbor(pos):
	var directions = [Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0)]
	directions.shuffle()

	for dir in directions:
		var new_pos = pos + dir
		if is_valid_position(new_pos) and grid[new_pos.x][new_pos.y] == null:
			return new_pos
	return null
	
func find_neighbor(pos):
	
	var directions = [Vector2(0, -1), Vector2(0, 1), Vector2(-1, 0), Vector2(1, 0)]
	directions.shuffle()

	for dir in directions:
		var new_pos = pos + dir
		if is_valid_position(new_pos) and grid[new_pos.x][new_pos.y] != null:
			return new_pos
	return null

func find_random_null_room():
	
	var x_position = randi() % GRID_SIZE
	var y_position = randi() % GRID_SIZE
	var room = grid[x_position][y_position]
	
	while(room != null):
		x_position = randi() % GRID_SIZE
		y_position = randi() % GRID_SIZE
		room = grid[x_position][y_position]
	
	return Vector2(x_position, y_position)

# Check if the position is within grid bounds
func is_valid_position(pos):
	return pos.x >= 0 and pos.x < GRID_SIZE and pos.y >= 0 and pos.y < GRID_SIZE

# Find the room farthest from the entrance using Manhattan distance
func find_farthest_room(start, room_positions):
	var farthest_room = start
	var max_distance = 0
	for room in room_positions:
		var distance = abs(start.x - room.x) + abs(start.y - room.y)
		if distance > max_distance && len(grid[room.x][room.y]) < 4:
			max_distance = distance
			farthest_room = room
	return farthest_room

func get_room(position):
	return grid[position[0]][position[1]]

# Count the current number of paths in the level
func count_paths(room_positions):
	var paths = 0
	for room in room_positions:
		paths += len(grid[room[0]][room[1]])
	return paths-4

# Utility to print the grid to the console for debugging
func print_grid():
	for row in grid:
		print(row)
		
func replace_null_values(array2d):
	for i in range(GRID_SIZE):
		for j in range(GRID_SIZE):
			if array2d[i][j] == null:
				array2d[i][j] = ""
	return array2d
