class_name UI
extends Node2D

@export var ant_manager : AntManager

func _on_simulation_speed_value_changed(value):
	ant_manager.simulation_speed = value
