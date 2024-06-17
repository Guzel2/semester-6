class_name FoodManager
extends Node2D

@export var cell_size : int = 10
@export var grid_size : int = 100

@export var debug_food : bool = true

@export var food_visual_scene : PackedScene

var food_list = []
var food_debug_list = []
var food_visual_list = []

func _ready() -> void:
	for x in grid_size:
		var line = []
		for y in grid_size:
			line.append(null)
		food_list.append(line)
	
	for x in grid_size:
		var line = []
		for y in grid_size:
			line.append(null)
		food_visual_list.append(line)
	
	if debug_food:
		for x in grid_size:
			var line = []
			for y in grid_size:
				line.append(null)
			food_debug_list.append(line)
	
	#for x in range(25, 30):
	#	for y in range(55, 65):
	#		add_food(Vector2i(x, y))
	
	#for x in range(5, 30):
	#	for y in range(10, 15):
	#		if x % 2 == 0:
	#			continue
	#		if y % 2 == 0:
	#			continue
			
	#		add_food(Vector2i(x, y))
	
	#for x in range(75, 85):
	#	for y in range(40, 50):
	#		add_food(Vector2i(x, y))

func get_food(pos: Vector2) -> Food:
	var local_pos = global_pos_to_local_pos(pos)
	
	if (local_pos.x < 0 or local_pos.x >= grid_size) or (local_pos.y < 0 or local_pos.y >= grid_size):
		push_warning("Ant out of grid at: ", pos)
		return
	
	return food_list[local_pos.x][local_pos.y]

func consume_food(pos: Vector2, value: float) -> float:
	var local_pos = global_pos_to_local_pos(pos)
	
	if (local_pos.x < 0 or local_pos.x > grid_size) or (local_pos.y < 0 or local_pos.y > grid_size):
		push_warning("Ant out of grid at: ", pos)
		return 0
	
	var food = food_list[local_pos.x][local_pos.y] as Food
	if !food:
		return 0
	var return_value = food.consume_food(value)
	
	if food_visual_list[local_pos.x][local_pos.y] != null:
		food_visual_list[local_pos.x][local_pos.y].remaining_food -= return_value
	
	if debug_food:
		food_debug_list[local_pos.x][local_pos.y].remaining_food -= return_value
	
	if return_value < value:
		remove_food(local_pos.x, local_pos.y, food)
	
	return return_value

func add_food(pos: Vector2i):
	var new_food = Food.new()
	food_list[pos.x][pos.y] = new_food
	
	if debug_food:
		add_debug_food(pos)

func add_debug_food(pos: Vector2i):
	var scene = food_visual_scene.instantiate() as FoodDebug
	scene.position = pos * cell_size
	scene.scale *= cell_size
	
	add_child(scene)
	
	food_debug_list[pos.x][pos.y] = scene

func global_pos_to_local_pos(pos: Vector2) -> Vector2i:
	pos /= cell_size
	return pos

func remove_food(x: int, y: int, food: Food):
	food.remove_food()
	food_list[x][y] = null
	
	food_visual_list[x][y].queue_free()
	food_visual_list[x][y] = null
	
	if y - 1 > 0 and food_visual_list[x][y - 1] != null:
		food_visual_list[x][y - 1].down = false
	if y + 1 < grid_size-1 and food_visual_list[x][y + 1] != null:
		food_visual_list[x][y + 1].up = false
	if x - 1 > 0 and food_visual_list[x - 1][y] != null:
		food_visual_list[x - 1][y].right = false
	if x + 1 < grid_size-1 and food_visual_list[x + 1][y] != null:
		food_visual_list[x + 1][y].left = false

func add_food_info(info : FoodInfo):
	for x in info.positions.size():
		var pos = info.positions[x]
		add_food(pos)
		
		var food = info.scenes[x] as FoodPiece
		food.reparent(self)
		
		food_visual_list[pos.x][pos.y] = food
		
		if pos + Vector2(0, -1) in info.positions:
			food.up = true
		if pos + Vector2(0, 1) in info.positions:
			food.down = true
		if pos + Vector2(-1, 0) in info.positions:
			food.left = true
		if pos + Vector2(1, 0) in info.positions:
			food.right = true
