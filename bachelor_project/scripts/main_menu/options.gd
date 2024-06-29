class_name Options
extends VBoxContainer

@export var main : Main

@export var obstacles : CheckBox
@export var obstacles_buyable : CheckBox
@export var manual_ant_spawning : CheckBox
@export var reroll_option : CheckBox
@export var automatic_evolution : CheckBox


func _on_obstacles_toggled(toggled_on : bool) -> void:
	obstacles_buyable.visible = toggled_on
	obstacles_buyable.button_pressed = false

func _on_obstacles_buyable_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.

func _on_manual_ant_spawning_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.

func _on_reroll_option_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.

func _on_manual_evolution_toggled(toggled_on: bool) -> void:
	pass # Replace with function body.
