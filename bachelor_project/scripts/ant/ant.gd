class_name Ant
extends AntBase

@export var simulation_speed : float = 1.0

@export var ant_manager : AntManager
@export var obstacle_timer : Timer

@export var accessory_scene : PackedScene

var home_position : Vector2 = Vector2(15, 150)
var home_size : float = 30

var state : ant_state = ant_state.exploring:
	get:
		return state
	set(value):
		if state != value:
			state = value
			updated_state()

var dir: Vector2 = Vector2(1, 0):
	get:
		return dir
	set(value):
		dir = value.normalized()
		rotation = dir.angle()

var speed = 60.0

var scent_spawn_timer = 0
var scent_spawn_interval = .2

var home_scan_timer = 0
var home_scan_interval = .2

var food_amount = 0
var max_food_amount = 10
var harvesting_amount = 1.0

var max_stamina = 20.0
var return_stamina = max_stamina * .6
var stamina = max_stamina

var exploring_time = 0
var exploring_adjustment_interval = .5
var exploring_randomness = 15

var food_scan_timer = 0
var food_scan_interval = .2

var food_scan_positions = []

var food_potential_scan_positions = [
	Vector2(5, 0),
	Vector2(0, -10),
	Vector2(0, 10),
	
	Vector2(15, 0),
	Vector2(10, -10),
	Vector2(10, 10),
	
	Vector2(5, 20),
	Vector2(5, -20),
	
	Vector2(25, 0),
	Vector2(20, -10),
	Vector2(20, 10),
	
	Vector2(0, 30),
	Vector2(0, -30),
	
	Vector2(15, -20),
	Vector2(15, 20),
	
	Vector2(35, 0),
	Vector2(30, -10),
	Vector2(30, 10),
	
	Vector2(-5, 40),
	Vector2(-5, -40),
	
	Vector2(10, 30),
	Vector2(10, -30),
	
	Vector2(15, -20),
	Vector2(15, 20),
	
	Vector2(5, 40),
	Vector2(5, -40),
	
	Vector2(20, 30),
	Vector2(20, -30),
	
	Vector2(15, 40),
	Vector2(15, -40),
]

var food_scan_position_count = 6
var food_scan_distance = 20

var scan_positions = []

var potential_scan_positions = [
	Vector2(15, 0),
	Vector2(10, -10),
	Vector2(10, 10),
	
	Vector2(25, 0),
	Vector2(20, -10),
	Vector2(20, 10),
	
	Vector2(5, 20),
	Vector2(5, -20),
	
	Vector2(35, 0),
	Vector2(30, -10),
	Vector2(30, 10),
	
	Vector2(15, -20),
	Vector2(15, 20),
	
	Vector2(45, 0),
	Vector2(40, -10),
	Vector2(40, 10),
	
	Vector2(25, -20),
	Vector2(25, 20),
	
	Vector2(35, -20),
	Vector2(35, 20),
]

var scan_position_count = 4

var last_collider : ObstacleArea
var collision_timer = 0
var collision_interval = .2

func updated_state():
	match state:
		ant_state.exploring:
			dir = Vector2(randf_range(-1, 1), randf_range(-1, 1))
		
		ant_state.harvesting:
			pass
			
		ant_state.returning:
			if !scan_360_scents(EnumManager.scent_types.home):
				dir = -dir

func _ready() -> void:
	if !scan_360_scents(EnumManager.scent_types.food):
		set_random_dir()
	
	scan_positions = potential_scan_positions.slice(0, scan_position_count)
	food_scan_positions = food_potential_scan_positions.slice(0, food_scan_position_count)

func _process(delta: float) -> void:
	delta *= simulation_speed
	
	stamina -= delta
	
	if stamina < return_stamina:
		if state != ant_state.returning:
			state = ant_state.returning
	
	if stamina < 0:
		queue_free()
	
	scent_spawn_timer += delta
	if scent_spawn_timer >= scent_spawn_interval:
		scent_spawn_timer = 0
		add_scent()
		
		match state:
			ant_state.exploring:
				scan_scents(EnumManager.scent_types.food)
			ant_state.returning:
				scan_scents(EnumManager.scent_types.home)
	
	match state:
		ant_state.exploring:
			position += dir * delta * speed
			exploring_time += delta
			if exploring_time >= exploring_adjustment_interval:
				exploring_time = 0
				dir = dir.rotated(deg_to_rad(randf_range(-exploring_randomness, exploring_randomness)))
			
			food_scan_timer += delta
			if food_scan_timer >= food_scan_interval:
				food_scan_timer = 0
				scan_food()
			
		ant_state.harvesting:
			if consume_food(delta) < delta:
				state = ant_state.exploring
			
		ant_state.returning:
			position += dir * delta * speed
			
			home_scan_timer += delta
			if home_scan_timer > home_scan_interval:
				home_scan_timer -= home_scan_interval
				
				var length = (position - home_position).length()
				if length < home_size:
					state = ant_state.exploring
					stamina = max_stamina
					ant_manager.add_food_amount(food_amount)
					food_amount = 0
					if !scan_360_scents(EnumManager.scent_types.food):
						set_random_dir()
	
	if collision_timer > 0:
		collision_timer -= delta * simulation_speed
		
		if collision_timer <= 0:
			check_collision()

func set_items(items : Array):
	for item in items:
		item = item as Item
		
		if !item:
			continue
		
		if item.item < EnumManager.obstacle_count:
			continue
		
		var accessory = accessory_scene.instantiate()
		accessory.animation = item.item_string
		
		accessory.modulate.a = .4 + (float(item.level + 1) / EnumManager.max_item_level) * .6
		
		for level in (item.level + 1):
			apply_item_effect(item.item)
		
		add_child(accessory)

func apply_item_effect(item : int):
	match item:
		EnumManager.item_list.antenna:
			scan_position_count += 2
		
		EnumManager.item_list.eyes:
			food_scan_position_count += 3
		
		EnumManager.item_list.scent_gland:
			scent_spawn_interval *= .95
		
		EnumManager.item_list.gaster:
			max_food_amount *= 1.1
		
		EnumManager.item_list.mandibles:
			harvesting_amount *= 1.05
		
		EnumManager.item_list.legs:
			speed *= 1.1

func set_random_dir():
	dir = Vector2(1, 0).rotated(randf() * 2 * PI)

func add_scent():
	var type
	match state:
		ant_state.exploring:
			type = EnumManager.scent_types.home
		
		ant_state.harvesting:
			type = EnumManager.scent_types.food
			
		ant_state.returning:
			if food_amount > 0:
				type = EnumManager.scent_types.food
			else:
				type = EnumManager.scent_types.danger
	
	ant_manager.add_scent(position, type)

func scan_scents(type: EnumManager.scent_types):
	var new_pos = Vector2(0, 0)
	var total_scents = 0
	
	for pos in scan_positions:
		var global_pos = pos.rotated(rotation)
		global_pos += position
		var scent = ant_manager.get_scent(global_pos, type)
		
		if scent:
			new_pos += pos
			total_scents += 1
	
	if total_scents <= 0:
		return
	
	new_pos /= total_scents
	dir = new_pos.rotated(dir.angle())

func scan_360_scents(type: EnumManager.scent_types) -> bool:
	var scan_count = 16
	for x in scan_count:
		var scan_dir = Vector2(25, 0).rotated(x * (PI / (scan_count / 2)))
		var scan_pos = scan_dir + position
		var scent = ant_manager.get_scent(scan_pos, type)
		
		if scent:
			dir = scan_dir
			return true
	
	#idk if I should do this? kinda makes ants nmove better
	for x in scan_count:
		var scan_dir = Vector2(35, 0).rotated(x * (PI / (scan_count / 2)))
		var scan_pos = scan_dir + position
		var scent = ant_manager.get_scent(scan_pos, type)
		
		if scent:
			dir = scan_dir
			return true
	
	return false

func scan_food():
	var found_foods = []
	
	for pos in food_scan_positions:
		var global_pos = pos.rotated(rotation)
		global_pos += position
		var food = ant_manager.get_food(global_pos)
		
		if food:
			found_foods.append(pos)
	
	if found_foods.is_empty():
		return
	
	var new_dir = found_foods[0].rotated(dir.angle())
	
	if found_foods.size() > 1:
		found_foods.shuffle()
		
		found_foods.sort_custom(sort_length)
		
		new_dir = found_foods[0].rotated(dir.angle())
	
	dir = new_dir
	
	if new_dir.length() < food_scan_distance:
		state = ant_state.harvesting

func sort_length(a : Vector2, b : Vector2):
	if a.length() < b.length():
		return true
	return false


func consume_food(delta) -> float:
	var scan_pos = position + dir * food_scan_distance
	var consumed_food = ant_manager.consume_food(scan_pos, delta)
	food_amount += consumed_food
	return consumed_food

func detect_obstacle(obstacle : ObstacleArea):
	if last_collider:
		check_collision()
	
	last_collider = obstacle
	collision_timer = collision_interval
	
	var dir_to_obstacle = position - obstacle.center_point
	
	var angle = dir.angle_to(dir_to_obstacle)
	
	dir = dir.rotated(angle / 3)

func check_collision():
	var old_collider = last_collider
	last_collider = null
	old_collider.check_collisions(self)
