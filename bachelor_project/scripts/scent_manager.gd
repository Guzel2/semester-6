class_name ScentManager
extends Node2D

@export var cell_size : int = 10
@export var grid_size : int = 100

@export var scent_visual_scene : PackedScene

var scent_list = []

var visualize_scent = true

func _ready() -> void:
	for x in grid_size:
		var line = []
		for y in grid_size:
			line.append(null)
		scent_list.append(line)

func get_scent(pos: Vector2) -> Scent:
	var local_pos = global_pos_to_local_pos(pos)
	
	if (local_pos.x < 0 or local_pos.x > grid_size) or (local_pos.y < 0 or local_pos.y > grid_size):
		push_warning("Ant out of grid at: ", pos)
		return null
	
	return scent_list[local_pos.x][local_pos.y]

func get_scent_local(pos: Vector2i) -> Scent:
	if (pos.x < 0 or pos.x > grid_size) or (pos.y < 0 or pos.y > grid_size):
		push_warning("Ant out of grid at: ", pos)
		return null
	
	return scent_list[pos.x][pos.y]

func add_scent(pos: Vector2, type: EnumManager.scent_types):
	var local_pos = global_pos_to_local_pos(pos)
	
	var existing_scent = get_scent_local(local_pos)
	
	if existing_scent:
		if existing_scent.type == type:
			existing_scent.increase_scent()
			return
	
	var new_scent = Scent.new()
	new_scent.type = type
	scent_list[local_pos.x][local_pos.y] = new_scent
	
	if visualize_scent:
		spawn_scent_visual(local_pos, type)

func spawn_scent_visual(pos: Vector2, type: EnumManager.scent_types):
	var scene = scent_visual_scene.instantiate() as ScentVisual
	scene.position = pos * cell_size
	scene.scale *= cell_size
	
	match type:
		EnumManager.scent_types.home:
			scene.modulate = Color.from_hsv(.90, .5, .75)
		EnumManager.scent_types.food:
			scene.modulate = Color.from_hsv(.35, .6, .7)
		EnumManager.scent_types.danger:
			scene.modulate = Color.from_hsv(.05, .7, .5)
	
	add_child(scene)

func global_pos_to_local_pos(pos: Vector2) -> Vector2i:
	pos /= cell_size
	return pos

func _process(delta: float) -> void:
	for x in grid_size:
		for y in grid_size:
			process_scent(x, y, delta)

func process_scent(x: int, y: int, delta: float):
	var scent = scent_list[x][y] as Scent
	if !scent:
		return
	
	var remaining_time = scent.process(delta)
	if remaining_time > 0:
		return
	
	remove_scent(x, y, scent)

func remove_scent(x: int, y: int, scent: Scent):
	scent.remove_scent()
	scent_list[x][y] = null
