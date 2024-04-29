class_name AntManager
extends AntBase

@export var home_scent_manager : ScentManager
@export var food_scent_manager : ScentManager
@export var danger_scent_manager : ScentManager
@export var food_manager : FoodManager

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
