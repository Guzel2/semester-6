class_name AntManager
extends AntBase

@export var home_scent_manager : ScentManager
@export var food_scent_manager : ScentManager
@export var danger_scent_manager : ScentManager
@export var food_manager : FoodManager

@export var ant_scene : PackedScene
@export var home_position : Vector2 = Vector2(500, 250)
@export var home_size : float = 40

#temp solution
@export var home_visual : Sprite2D

@export var simulation_speed = 1.0:
	get:
		return simulation_speed
	set(value):
		simulation_speed = value
		update_simulation_speed()

@export var ant_food_requirement = 10
var food_amount = 60

var ant_spawn_interval = 4.0
var ant_spawn_time = .0

func _ready():
	home_visual.position = home_position
	home_visual.scale *= home_size

func _process(delta):
	delta *= simulation_speed
	
	if food_amount > ant_food_requirement:
		ant_spawn_time += delta
		if ant_spawn_time > ant_spawn_interval:
			ant_spawn_time -= ant_spawn_interval
			food_amount -= ant_food_requirement
			spawn_ant()

func update_simulation_speed():
	var ants = get_children()
	for ant in ants:
		if ant == home_visual:
			continue
		
		ant.simulation_speed = simulation_speed
	
	if home_scent_manager:
		home_scent_manager.simulation_speed = simulation_speed
	if food_scent_manager:
		food_scent_manager.simulation_speed = simulation_speed
	if danger_scent_manager:
		danger_scent_manager.simulation_speed = simulation_speed

func add_food_amount(amount: float):
	food_amount += amount

func spawn_ant():
	var ant = ant_scene.instantiate() as Ant
	ant.home_position = home_position
	ant.home_size = home_size
	
	ant.position = home_position
	
	ant.ant_manager = self
	
	ant.simulation_speed = simulation_speed
	
	add_child(ant)

func get_scent(pos: Vector2, type: EnumManager.scent_types) -> Scent:
	match type:
		EnumManager.scent_types.home:
			return home_scent_manager.get_scent(pos)
		EnumManager.scent_types.food:
			return food_scent_manager.get_scent(pos)
		EnumManager.scent_types.danger:
			return danger_scent_manager.get_scent(pos)
		_:
			return home_scent_manager.get_scent(pos)

func add_scent(pos: Vector2, type: EnumManager.scent_types):
	match type:
		EnumManager.scent_types.home:
			return home_scent_manager.add_scent(pos, type)
		EnumManager.scent_types.food:
			return food_scent_manager.add_scent(pos, type)
		EnumManager.scent_types.danger:
			return danger_scent_manager.add_scent(pos, type)
		_:
			return home_scent_manager.add_scent(pos, type)

func get_food(pos: Vector2) -> Food:
	return food_manager.get_food(pos)

func consume_food(pos: Vector2, value: float) -> float:
	return food_manager.consume_food(pos, value)
