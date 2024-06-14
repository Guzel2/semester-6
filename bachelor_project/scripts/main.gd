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

var previous_simulation_speed = 1

signal start_off_day
signal end_off_day

func _ready():
	end_day()

func update_simulation_speed():
	shadow_manager.simulation_speed = simulation_speed
	home_scent_manager.simulation_speed = simulation_speed
	food_scent_manager.simulation_speed = simulation_speed
	danger_scent_manager.simulation_speed = simulation_speed
	ant_manager.simulation_speed = simulation_speed

func start_day():
	simulation_speed = previous_simulation_speed
	shadow_manager.start_day()
	
	emit_signal("start_off_day")

func end_day():
	camera.transition_to_shop(true)
	simulation_speed = 0
	
	emit_signal("end_off_day")

func _on_shadow_manager_end_of_day():
	end_day()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out":
		start_day()

func _on_start_next_day_pressed() -> void:
	shadow_manager.timer = 0
	shadow_manager._process(.01)
