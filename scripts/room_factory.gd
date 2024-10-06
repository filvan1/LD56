@tool
extends Node2D

var room_size = 8  # 8x8 tiles per room
var tile_size = 32  # Each tile is 32x32 pixels
var grid_width = 5  # Number of rooms across

var TILE_CORNER_NW = [1]
var TILE_WALL_N = [2, 3]
var TILE_WALL_N_OPEN_L = [4]
var TILE_WALL_N_OPEN_R = [5]
var TILE_CORNER_NE = [6]
var TILE_WALL_E = [7, 8]
var TILE_WALL_E_OPEN_U = [9]
var TILE_WALL_E_OPEN_D = [10]
var TILE_CORNER_SE = [11]
var TILE_WALL_S = [12, 13]
var TILE_WALL_S_OPEN_R = [14]
var TILE_WALL_S_OPEN_L = [15]
var TILE_CORNER_SW = [16]
var TILE_WALL_W = [17, 18]
var TILE_WALL_W_OPEN_D = [19]
var TILE_WALL_W_OPEN_U = [20]
var TILE_INTERSECTION_NW = [21]
var TILE_INTERSECTION_NE = [22]
var TILE_INTERSECTION_SW = [23]
var TILE_INTERSECTION_SE = [24]
var TILE_FLOOR = [25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 38]
var TILE_PATH_TOP = [39, 40, 41, 42]
var TILE_PATH_BOT = [43, 44, 45, 46]
var TILE_PATH_LEFT = [47, 48, 49, 50]
var TILE_PATH_RIGHT = [51, 52, 53, 54]
var TILE_PATH_END_HORIZONTAL_NE = [55, 56]
var TILE_PATH_END_HORIZONTAL_SE = [57, 58]
var TILE_PATH_END_VERTICAL_SW = [59, 60]
var TILE_PATH_END_VERTICAL_SE = [61, 62]
var TILE_PATH_END_HORIZONTAL_NW = [63, 64]
var TILE_PATH_END_HORIZONTAL_SW = [65, 66]
var TILE_PATH_END_VERTICAL_NW = [67, 68]
var TILE_PATH_END_VERTICAL_NE = [69, 70]
var TILE_TURN_NE_SE = [71, 72]
var TILE_TURN_NE_NW = [73, 74]
var TILE_TURN_NE_NE = [75, 76]
var TILE_TURN_SE_NE = [77, 78]
var TILE_TURN_SE_SW = [79, 80]
var TILE_TURN_SE_SE = [81, 82]
var TILE_TURN_SW_NW = [83, 84]
var TILE_TURN_SW_SE = [85, 86]
var TILE_TURN_SW_SW = [87, 88]
var TILE_TURN_NW_NW = [89, 90]
var TILE_TURN_NW_NE = [91, 92]
var TILE_TURN_NW_SW = [93, 94]

var grid = []

const GRID_SIZE = 8

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	for x in range(GRID_SIZE):
		var row = []
		for y in range(GRID_SIZE):
			row.append(null)
		grid.append(row)

func generate(exits):
	
	build_walls(exits)
	build_floor(exits)

	return grid

func build_walls(exits):
	
	#build corners
	grid[0][0] = get_tile(TILE_CORNER_NW)
	grid[GRID_SIZE - 1][0] = get_tile(TILE_CORNER_NE)
	grid[0][GRID_SIZE -1] = get_tile(TILE_CORNER_SW)
	grid[GRID_SIZE -1][GRID_SIZE -1] = get_tile(TILE_CORNER_SE)
	
	#build walls
	for x in range(1, GRID_SIZE-1):
		grid[x][0] = get_tile(TILE_WALL_N)
	if exits.contains("N"):
		grid[3][0] = get_tile(TILE_WALL_N_OPEN_L)
		grid[4][0] = get_tile(TILE_WALL_N_OPEN_R)
		
	for y in range(1, GRID_SIZE-1):
		grid[GRID_SIZE-1][y] = get_tile(TILE_WALL_E)
	if exits.contains("E"):
		grid[GRID_SIZE-1][3] = get_tile(TILE_WALL_E_OPEN_U)
		grid[GRID_SIZE-1][4] = get_tile(TILE_WALL_E_OPEN_D)
		
	for x in range(1, GRID_SIZE-1):
		grid[x][GRID_SIZE-1] = get_tile(TILE_WALL_S)
	if exits.contains("S"):
		grid[3][GRID_SIZE-1] = get_tile(TILE_WALL_S_OPEN_R)
		grid[4][GRID_SIZE-1] = get_tile(TILE_WALL_S_OPEN_L)
		
	for y in range(1, GRID_SIZE-1):
		grid[0][y] = get_tile(TILE_WALL_W)
	if exits.contains("W"):
		grid[0][3] = get_tile(TILE_WALL_W_OPEN_U)
		grid[0][4] = get_tile(TILE_WALL_W_OPEN_D)
	
	
func build_floor(exits):
	
	# first, build complete floor
	for x in range(1, GRID_SIZE-1):
		for y in range(1, GRID_SIZE-1):
			grid[x][y] = get_tile(TILE_FLOOR)
	
	# construct paths
	if exits.contains("N"):
		for y in range(1,3):	
			grid[3][y] = get_tile(TILE_PATH_LEFT)
			grid[4][y] = get_tile(TILE_PATH_RIGHT)
		grid[3][3] = get_tile(TILE_PATH_END_VERTICAL_SW)
		grid[4][3] = get_tile(TILE_PATH_END_VERTICAL_SE)
	
	if exits.contains("E"):
		for x in range(5,7):	
			grid[x][3] = get_tile(TILE_PATH_TOP)
			grid[x][4] = get_tile(TILE_PATH_BOT)
		grid[4][3] = get_tile(TILE_PATH_END_HORIZONTAL_NW)
		grid[4][4] = get_tile(TILE_PATH_END_HORIZONTAL_SW)
	
	if exits.contains("S"):
		for y in range(5,7):	
			grid[3][y] = get_tile(TILE_PATH_LEFT)
			grid[4][y] = get_tile(TILE_PATH_RIGHT)
		grid[3][4] = get_tile(TILE_PATH_END_VERTICAL_NW)
		grid[4][4] = get_tile(TILE_PATH_END_VERTICAL_NE)
	
	if exits.contains("W"):
		for x in range(1,3):	
			grid[x][3] = get_tile(TILE_PATH_TOP)
			grid[x][4] = get_tile(TILE_PATH_BOT)
		grid[3][3] = get_tile(TILE_PATH_END_HORIZONTAL_NE)
		grid[3][4] = get_tile(TILE_PATH_END_HORIZONTAL_SE)
			
	# construct center for all 2 exit turning rooms
	if exits.contains("N") && exits.contains("E"):
		grid[3][3] = get_tile(TILE_TURN_NE_NW)
		grid[4][3] = get_tile(TILE_TURN_NE_NE)
		grid[4][4] = get_tile(TILE_TURN_NE_SE)
		
	if exits.contains("E") && exits.contains("S"):
		grid[3][4] = get_tile(TILE_TURN_SE_SW)
		grid[4][3] = get_tile(TILE_TURN_SE_NE)
		grid[4][4] = get_tile(TILE_TURN_SE_SE)
		
	if exits.contains("S") && exits.contains("W"):
		grid[3][3] = get_tile(TILE_TURN_SW_NW)
		grid[3][4] = get_tile(TILE_TURN_SW_SW)
		grid[4][4] = get_tile(TILE_TURN_SW_SE)
		
	if exits.contains("W") && exits.contains("N"):
		grid[3][3] = get_tile(TILE_TURN_NW_NW)
		grid[3][4] = get_tile(TILE_TURN_NW_SW)
		grid[4][3] = get_tile(TILE_TURN_NW_NE)
		
	# construct straight line rows	
	if exits.contains("N") && exits.contains("S"):
		grid[3][3] = get_tile(TILE_PATH_LEFT)
		grid[3][4] = get_tile(TILE_PATH_LEFT)
		grid[4][3] = get_tile(TILE_PATH_RIGHT)
		grid[4][4] = get_tile(TILE_PATH_RIGHT)
		
	if exits.contains("E") && exits.contains("W"):
		grid[3][3] = get_tile(TILE_PATH_TOP)
		grid[3][4] = get_tile(TILE_PATH_BOT)
		grid[4][3] = get_tile(TILE_PATH_TOP)
		grid[4][4] = get_tile(TILE_PATH_BOT)	
	# construct center for all 3 exit rooms
	if exits.contains("N") && exits.contains("E") && exits.contains("S"):
		grid[3][3] = get_tile(TILE_PATH_LEFT)
		grid[3][4] = get_tile(TILE_PATH_LEFT)
		grid[4][3] = get_tile(TILE_INTERSECTION_NE)
		grid[4][4] = get_tile(TILE_INTERSECTION_SE)
		
	if exits.contains("E") && exits.contains("S") && exits.contains("W"):
		grid[3][3] = get_tile(TILE_PATH_TOP)
		grid[3][4] = get_tile(TILE_INTERSECTION_SW)
		grid[4][3] = get_tile(TILE_PATH_TOP)
		grid[4][4] = get_tile(TILE_INTERSECTION_SE)
		
	if exits.contains("S") && exits.contains("W") && exits.contains("N"):
		grid[3][3] = get_tile(TILE_INTERSECTION_NW)
		grid[3][4] = get_tile(TILE_INTERSECTION_SW)
		grid[4][3] = get_tile(TILE_PATH_RIGHT)
		grid[4][4] = get_tile(TILE_PATH_RIGHT)
		
	if exits.contains("W") && exits.contains("N") && exits.contains("E"):
		grid[3][3] = get_tile(TILE_INTERSECTION_NW)
		grid[3][4] = get_tile(TILE_PATH_BOT)
		grid[4][3] = get_tile(TILE_INTERSECTION_NE)
		grid[4][4] = get_tile(TILE_PATH_BOT)
	
	# finally, the case for 4 exits
	if exits.contains("N") && exits.contains("E") && exits.contains("S") && exits.contains("W"):
		grid[3][3] = get_tile(TILE_INTERSECTION_NW)
		grid[3][4] = get_tile(TILE_INTERSECTION_SW)
		grid[4][3] = get_tile(TILE_INTERSECTION_NE)
		grid[4][4] = get_tile(TILE_INTERSECTION_SE)
	
	
func get_tile(tilename):
	return tilename[randi() % tilename.size()]
	
