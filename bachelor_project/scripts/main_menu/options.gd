class_name Options
extends VBoxContainer

@export var main : Main

@export var obstacles : CheckBox
@export var obstacles_buyable : CheckBox
@export var manual_ant_spawning : CheckBox
@export var reroll_option : CheckBox
@export var manual_evolution : CheckBox

func load_options():
	obstacles.button_pressed = main.use_obstacles
	obstacles_buyable.button_pressed = main.obstacle_buyable
	manual_ant_spawning.button_pressed = main.manual_ant_spawning
	reroll_option.button_pressed = main.reroll_option
	manual_evolution.button_pressed = main.manual_evolution

func set_options():
	main.use_obstacles = obstacles.button_pressed
	main.obstacle_buyable = obstacles_buyable.button_pressed
	main.manual_ant_spawning = manual_ant_spawning.button_pressed
	main.reroll_option = reroll_option.button_pressed
	main.manual_evolution = manual_evolution.button_pressed

func _on_obstacles_toggled(toggled_on : bool) -> void:
	obstacles_buyable.visible = toggled_on
	obstacles_buyable.button_pressed = false
