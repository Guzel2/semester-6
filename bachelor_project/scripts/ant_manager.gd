class_name AntManager
extends AntBase

@export var scent_manager : ScentManager
@export var food_manager : FoodManager

func get_scent(pos: Vector2) -> Scent:
	return scent_manager.get_scent(pos)

func add_scent(pos: Vector2, type: EnumManager.scent_types):
	scent_manager.add_scent(pos, type)

func get_food(pos: Vector2) -> Food:
	return food_manager.get_food(pos)

func consume_food(pos: Vector2, value: float) -> float:
	return food_manager.consume_food(pos, value)
