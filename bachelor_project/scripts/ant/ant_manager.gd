class_name AntManager
extends AntBase

@export var home_scent_manager : ScentManager
@export var food_scent_manager : ScentManager
@export var danger_scent_manager : ScentManager
@export var food_manager : FoodManager
@export var shadow_manager : ShadowManager

@export var ant_display : NumberDisplay
@export var food_display : NumberDisplay
@export var quest_display : NumberDisplay

@export var shop_ant_display : NumberDisplay

@export var ant_scene : PackedScene
@export var home_position : Vector2 = Vector2(1500, 1500)
@export var home_size : float = 40

#temp solution
@export var home_visual : Sprite2D

@export var simulation_speed = 1.0:
	get:
		return simulation_speed
	set(value):
		simulation_speed = value
		update_simulation_speed()

@export var ant_food_requirement = 5
var food_amount = 30:
	get:
		return food_amount
	set(value):
		var difference = value - food_amount
		if difference > 0:
			total_food += difference
		
		food_amount = value
		food_display.update_number(food_amount)

var total_food = 0:
	get:
		return total_food
	set(value):
		var difference = value - total_food
		total_food = value
		
		quest_progress += difference

var quest_progress = 0:
	set(value):
		quest_progress = value
		quest_display.update_number(quest_progress)

var ant_spawn_interval = 4.0
var ant_spawn_time = .0

var items = []

var ant_count = 0:
	get:
		return ant_count
	set(value):
		ant_count = value
		shop_ant_display.update_number(ant_count)

func _ready():
	home_visual.position = home_position
	home_visual.rotation = randf_range(0, 2 * PI)
	food_amount = food_amount

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

func add_food_amount(amount: float):
	food_amount += amount

func spawn_ant():
	var ant = ant_scene.instantiate() as Ant
	ant.home_position = home_position
	ant.home_size = home_size
	
	ant.position = home_position
	
	ant.ant_manager = self
	
	ant.simulation_speed = simulation_speed
	
	ant.set_items(items)
	
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

func show_scent():
	home_scent_manager.show_scent()
	food_scent_manager.show_scent()
	danger_scent_manager.show_scent()

func _on_equipt_holder_equipt_items(new_items: Array) -> void:
	items = new_items

func start_day():
	await get_tree().create_timer(1).timeout
	
	for ant in ant_count:
		spawn_ant()

func end_day():
	ant_count = 0
	for ant in get_children():
		if ant == home_visual:
			continue
		
		ant_count += 1
		ant.queue_free()

func _on_main_start_of_day():
	start_day()

func _on_main_end_of_day():
	end_day()

func _on_child_entered_tree(node: Node) -> void:
	ant_display.update_number(get_child_count() - 1)

func _on_child_exiting_tree(node: Node) -> void:
	ant_display.update_number(get_child_count() - 2)
