class_name Main
extends Node2D

@export var simulation_speed = 1.0:
	get:
		return simulation_speed
	set(value):
		previous_simulation_speed = simulation_speed
		simulation_speed = value
		update_simulation_speed()

@export var shadow_manager : ShadowManager
@export var home_scent_manager : ScentManager
@export var food_scent_manager : ScentManager
@export var danger_scent_manager : ScentManager
@export var food_manager : FoodManager
@export var ant_manager : AntManager
@export var camera : Camera

var previous_simulation_speed = 0

func update_simulation_speed():
	shadow_manager.simulation_speed = simulation_speed
	home_scent_manager.simulation_speed = simulation_speed
	food_scent_manager.simulation_speed = simulation_speed
	danger_scent_manager.simulation_speed = simulation_speed
	ant_manager.simulation_speed = simulation_speed

func start_day():
	simulation_speed = previous_simulation_speed
	camera.transition_to_shop(false)
	shadow_manager.start_day()

func end_day():
	camera.transition_to_shop(true)
	simulation_speed = 0

func _on_shadow_manager_end_of_day():
	end_day()

func _on_start_next_day_pressed():
	start_day()
