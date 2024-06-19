class_name ScentManager
extends Node2D

var cell_size : int = 10
var grid_size : int = 300

@export var simulation_speed : float = 1.0
@export var visualize_scent = true

@export var scent_visual_scene : PackedScene

var scent_list = []

var scents_to_process = []

func _ready() -> void:
	if name == "danger_scent_manager":
		set_process(false)
	
	for x in grid_size:
		var line = []
		for y in grid_size:
			line.append(null)
		scent_list.append(line)

func reset_scents():
	for x in grid_size:
		for y in grid_size:
			scent_list[x][y] = null
	
	add_scent(Vector2(0, 0), EnumManager.scent_types.home)
	add_scent(Vector2(grid_size, 0), EnumManager.scent_types.home)
	add_scent(Vector2(0, grid_size * cell_size - 1), EnumManager.scent_types.home)
	add_scent(Vector2(grid_size * cell_size - 1, grid_size * cell_size - 1), EnumManager.scent_types.home)

func get_scent(pos: Vector2) -> Scent:
	var local_pos = global_pos_to_local_pos(pos)
	
	if (local_pos.x < 0 or local_pos.x >= grid_size) or (local_pos.y < 0 or local_pos.y >= grid_size):
		push_warning("Ant out of grid at: ", pos)
		return null
	
	return scent_list[local_pos.x][local_pos.y]

func get_scent_local(pos: Vector2i) -> Scent:
	if (pos.x < 0 or pos.x >= grid_size) or (pos.y < 0 or pos.y >= grid_size):
		push_warning("Ant out of grid at: ", pos)
		return null
	
	return scent_list[pos.x][pos.y]

func add_scent(pos: Vector2, type: EnumManager.scent_types):
	var local_pos = global_pos_to_local_pos(pos)
	
	if (local_pos.x < 0 or local_pos.x >= grid_size) or (local_pos.y < 0 or local_pos.y >= grid_size):
		push_warning("Ant out of grid at: ", local_pos)
		return null
	
	var existing_scent = get_scent_local(local_pos)
	
	if existing_scent:
		if existing_scent.type == type:
			existing_scent.increase_scent()
			
			if visualize_scent:
				spawn_scent_visual(local_pos, type)
			return
	
	var new_scent = Scent.new()
	new_scent.type = type
	scent_list[local_pos.x][local_pos.y] = new_scent
	scents_to_process.append(Vector2i(local_pos.x, local_pos.y))
	
	if visualize_scent:
		spawn_scent_visual(local_pos, type)

func spawn_scent_visual(pos: Vector2, type: EnumManager.scent_types):
	var scene = scent_visual_scene.instantiate() as ScentVisual
	scene.position = pos * cell_size
	scene.scale *= cell_size
	scene.simulation_speed = simulation_speed
	
	match type:
		EnumManager.scent_types.home:
			scene.modulate = Color.from_hsv(.90, .5, .75)
		EnumManager.scent_types.food:
			scene.modulate = Color.from_hsv(.35, .6, .7)
		EnumManager.scent_types.danger:
			scene.modulate = Color.from_hsv(.05, .7, .5)
	
	add_child(scene)

func spawn_temp_scent_visual(pos: Vector2, type: EnumManager.scent_types):
	var scene = scent_visual_scene.instantiate() as ScentVisual
	scene.position = pos * cell_size
	scene.scale *= cell_size
	scene.simulation_speed = 15
	
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
	delta *= simulation_speed
	
	for scent in scents_to_process:
		process_scent(scent.x, scent.y, delta)
	
	#for x in grid_size:
	#	for y in grid_size:
	#		process_scent(x, y, delta)

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
	var index = 0
	for vector in scents_to_process:
		if vector.x != x || vector.y != y:
			index += 1
			continue
		scents_to_process.remove_at(index)

func show_scent():
	for x in grid_size:
		for y in grid_size:
			var scent = scent_list[x][y] as Scent
			
			if !scent:
				continue
			
			spawn_temp_scent_visual(Vector2(x, y), scent.type)

func _on_main_end_off_day() -> void:
	reset_scents()
