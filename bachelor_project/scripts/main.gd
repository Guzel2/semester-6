class_name Main
extends Node2D


@export var simulation_speed = 1.0:
	get:
		return simulation_speed
	set(value):
		simulation_speed = value
		update_simulation_speed()


@export var shadow_manager : ShadowManager
@export var home_scent_manager : ScentManager
@export var food_scent_manager : ScentManager
@export var danger_scent_manager : ScentManager
@export var food_manager : FoodManager
@export var ant_manager : AntManager
@export var camera : Camera

func update_simulation_speed():
	ant_manager.simulation_speed = simulation_speed
	home_scent_manager.simulation_speed = simulation_speed
	food_scent_manager.simulation_speed = simulation_speed
	danger_scent_manager.simulation_speed = simulation_speed
	shadow_manager.simulation_speed = simulation_speed

func start_day():
	pass

func end_day():
	pass
