extends Node2D

@export var cell_size : int = 10
@export var grid_size : int = 100

@export var food_visual_scene : PackedScene

var food_list = []

func _ready() -> void:
	for x in grid_size:
		var line = []
		for y in grid_size:
			line.append(null)
		food_list.append(line)

func consume_food(pos: Vector2i, value: float) -> float:
	var local_pos = global_pos_to_local_pos(pos)
	
	if (local_pos.x < 0 or local_pos.x > grid_size) or (local_pos.y < 0 or local_pos.y > grid_size):
		push_warning("Ant out of grid at: ", pos)
		return 0
	
	var food = food_list[local_pos.x][local_pos.y] as Food
	var return_value = food.consume_food(value)
	
	if return_value < value:
		remove_food(local_pos.x, local_pos.y, food)
	
	return return_value

func add_food(pos: Vector2i, value: float) -> float:
	var local_pos = global_pos_to_local_pos(pos)
	
	if (local_pos.x < 0 or local_pos.x > grid_size) or (local_pos.y < 0 or local_pos.y > grid_size):
		push_warning("Ant out of grid at: ", pos)
		return 0
	
	var food = food_list[local_pos.x][local_pos.y] as Food
	var return_value = food.add_food(value)
	
	if return_value < value:
		remove_food(local_pos.x, local_pos.y, food)
	
	return return_value

func global_pos_to_local_pos(pos: Vector2) -> Vector2i:
	pos /= cell_size
	return pos

func update_food_visual():
	pass

func remove_food(x: int, y: int, food: Food):
	food.remove_food()
	food_list[x][y] = null
