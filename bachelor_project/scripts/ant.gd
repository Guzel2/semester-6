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

var dir: Vector2 = Vector2(0, -1)
var speed = 60

var scent_spawn_timer = 0
var scent_spawn_interval = 1.2

var food_amount = 0
var max_food_amount = 10
var harvesting_amount = 1

var max_stamina = 10.0
var return_stamina = max_stamina * .6
var stamina = max_stamina

var exploring_time = 0
var exploring_adjustment_interval = .5
var exploring_randomness = 25

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
	pass
