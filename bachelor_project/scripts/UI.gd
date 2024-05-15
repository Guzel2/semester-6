class_name UI
extends Node2D

@export var ant_manager : AntManager

func _on_simulation_speed_value_changed(value):
	ant_manager.simulation_speed = value

func _on_button_pressed():
	ant_manager.spawn_ant()

func _on_show_scent_pressed():
	ant_manager.show_scent()
