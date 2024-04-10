class_name AntManager
extends AntBase

@export var scent_manager : ScentManager

func get_scent(pos: Vector2) -> Scent:
	return scent_manager.get_scent(pos)

func add_scent(pos: Vector2, type: EnumManager.scent_types):
	scent_manager.add_scent(pos, type)

