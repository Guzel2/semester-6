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
@export var lose_screen : LoseScreen
@export var main_menu : MainMenu
@export var bought_holder : BoughtHolder
@export var equipt_holder : EquiptHolder

var previous_simulation_speed = 1

signal start_of_day
signal end_of_day

var day_count = -1:
	set(value):
		day_count = value
		day_display.update_number(day_count + 1)

var fullscreen = false

var go_to_main_menu_next = false

#options
var use_obstacles = true
var obstacle_buyable = true

var automatic_ant_spawning = true

var reroll_option = true
var automatic_evolution = true

#bonus:
var custom_food_placing = false


func _input(event: InputEvent) -> void:
	if event.is_action_released('f11'):
		fullscreen = !fullscreen
		
		if fullscreen:
			DisplayServer.window_set_mode(3, 0)
		else:
			DisplayServer.window_set_mode(0, 0)

func _ready():
	simulation_speed = 0

func update_simulation_speed():
	shadow_manager.simulation_speed = simulation_speed
	home_scent_manager.simulation_speed = simulation_speed
	food_scent_manager.simulation_speed = simulation_speed
	danger_scent_manager.simulation_speed = simulation_speed
	ant_manager.simulation_speed = simulation_speed

func new_run():
	day_count = -1
	food_manager.new_run()
	home_scent_manager.new_run()
	food_scent_manager.new_run()
	danger_scent_manager.new_run()
	ant_manager.new_run()
	bought_holder.new_run()
	equipt_holder.new_run()
	quest_display.suffix = "/50 due by Day 5"
	
	simulation_speed = 1
	end_day()

func go_to_main_menu():
	main_menu.enter()

func start_day():
	simulation_speed = previous_simulation_speed
	shadow_manager.start_day()
	
	emit_signal("start_of_day")

func end_day():
	day_count += 1
	
	if day_count % 5 == 0 and day_count > 0:
		check_quest()
	else:
		go_to_shop()

func go_to_shop():
	camera.transition_to_shop(true)
	simulation_speed = 0
	
	emit_signal("end_of_day")

func check_quest():
	var quest_level = day_count / 5
	
	var continue_game = false
	
	match quest_level:
		1:
			if ant_manager.quest_progress > 50:
				continue_game = true
				quest_display.suffix = "/100 due by Day 10"
			else:
				lose_game()
		2:
			if ant_manager.quest_progress > 100:
				continue_game = true
				quest_display.suffix = "/250 due by Day 15 to win"
			else:
				lose_game()
		3:
			if ant_manager.quest_progress > 250:
				print("you won yay")
				win_game()
			else:
				lose_game()
	
	ant_manager.quest_progress = 0
	
	if continue_game:
		go_to_shop()

func lose_game():
	lose_screen.animation_player.play("fade_in")

func win_game():
	win_screen.animation_player.play("fade_in")

func _on_shadow_manager_end_of_day():
	end_day()

func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "fade_out":
		start_day()

func _on_start_next_day_pressed() -> void:
	shadow_manager.timer = 0
	shadow_manager._process(.01)

func _on_win_screen_main_menu() -> void:
	go_to_main_menu()

func _on_lose_screen_main_menu() -> void:
	go_to_main_menu()

func _on_win_screen_continue_game() -> void:
	go_to_shop()

func _on_lose_screen_new_run() -> void:
	new_run()
