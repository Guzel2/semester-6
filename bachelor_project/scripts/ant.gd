class_name Ant
extends AntBase

@export var ant_manager : AntManager

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

var speed = 60

var scent_spawn_timer = 0
var scent_spawn_interval = .2

var food_amount = 0
var max_food_amount = 10
var harvesting_amount = 1

var max_stamina = 10.0
var return_stamina = max_stamina * .6
var stamina = max_stamina

var exploring_time = 0
var exploring_adjustment_interval = .5
var exploring_randomness = 25

var scan_positions = [
	Vector2(10, -10),
	Vector2(20, -10),
	
	Vector2(15, 0),
	Vector2(25, 0),
	
	Vector2(10, 10),
	Vector2(20, 10),
]

func updated_state():
	match state:
		ant_state.exploring:
			dir = Vector2(randf_range(-1, 1), randf_range(-1, 1))
		
		ant_state.harvesting:
			pass
			
		ant_state.returning:
			dir = -dir

func _process(delta: float) -> void:
	stamina -= delta
	
	if stamina < return_stamina:
		if state != ant_state.returning:
			state = ant_state.returning
	
	scent_spawn_timer += delta
	if scent_spawn_timer >= scent_spawn_interval:
		scent_spawn_timer = 0
		add_scent()
		scan_scents()
	
	position += dir * delta * speed
	
	match state:
		ant_state.exploring:
			exploring_time += delta
			if exploring_time >= exploring_adjustment_interval:
				exploring_time = 0
				dir = dir.rotated(deg_to_rad(randf_range(-exploring_randomness, exploring_randomness)))
		
		ant_state.harvesting:
			pass
			
		ant_state.returning:
			pass

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

func scan_scents():
	var found_scents = []
	
	for pos in scan_positions:
		pos = pos.rotated(rotation)
		pos += position
		var scent = ant_manager.get_scent(pos)
		if scent:
			found_scents.append(change_scent_into_int(scent))
		else:
			found_scents.append(0)
	
	var new_pos = Vector2(0, 0)
	var total_scents = 0
	
	for i in found_scents.size():
		var modifier = found_scents[i]
		if modifier == 0:
			continue
		
		if modifier < 0:
			#do this for now
			continue
		
		new_pos += scan_positions[i] * modifier
		total_scents += modifier
	
	if total_scents <= 0:
		return
	
	new_pos /= total_scents
	dir = new_pos.rotated(dir.angle())

func change_scent_into_int(scent: Scent) -> int:
	match state:
		ant_state.exploring:
			if scent.type == EnumManager.scent_types.home:
				return 0
			
			var modifier = 1
			if scent.type == EnumManager.scent_types.danger:
				modifier = -1
			
			return (scent.intensity + 1) * modifier
		
		ant_state.harvesting:
			return 0
			
		ant_state.returning:
			if scent.type != EnumManager.scent_types.home:
				return 0
			return scent.intensity + 1
	
	return 0
