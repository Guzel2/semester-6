class_name UserInterface
extends CanvasLayer

@export var main : Main
@export var ant_manager : AntManager

func _on_simulation_speed_value_changed(value):
	main.simulation_speed = value

func _on_show_scent_pressed():
	ant_manager.show_scent()

func _on_spawn_ant_pressed() -> void:
	if ant_manager.food_amount >= ant_manager.ant_food_requirement:
		ant_manager.spawn_ant()
		
		ant_manager.food_amount -= ant_manager.ant_food_requirement
