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
@export var day_display : NumberDisplay
@export var quest_display : NumberDisplay
@export var win_screen : WinScreen


var previous_simulation_speed = 1

signal start_off_day
signal end_off_day

var day_count = -1:
	set(value):
		day_count = value
		day_display.update_number(day_count + 1)
		
		if day_count % 5 == 0:
			check_quest()

var fullscreen = false

func _input(event: InputEvent) -> void:
	if event.is_action_released('f11'):
		fullscreen = !fullscreen
		
		if fullscreen:
			DisplayServer.window_set_mode(3, 0)
		else:
			DisplayServer.window_set_mode(0, 0)

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
	if day_count >= 0:
		win_game()
	
	day_count += 1
	camera.transition_to_shop(true)
	simulation_speed = 0
	
	emit_signal("end_off_day")

func check_quest():
	var quest_level = day_count / 5
	
	match quest_level:
		1:
			if ant_manager.quest_progress > 30:
				print("next quest yay")
				quest_display.suffix = "/60 due by Day 10"
			else:
				lose_game()
		2:
			if ant_manager.quest_progress > 60:
				print("next quest yay")
				quest_display.suffix = "/100 due by Day 15 to win"
			else:
				lose_game()
		3:
			if ant_manager.quest_progress > 100:
				print("you won yay")
				win_game()
			else:
				lose_game()
	
	ant_manager.quest_progress = 0

func lose_game():
	print("you lose")

func win_game():
	print("win game")
	
	win_screen.animation_player.play("fade_in")
	
	await win_screen.continue_game

func _on_shadow_manager_end_of_day():
	end_day()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out":
		start_day()

func _on_start_next_day_pressed() -> void:
	shadow_manager.timer = 0
	shadow_manager._process(.01)
