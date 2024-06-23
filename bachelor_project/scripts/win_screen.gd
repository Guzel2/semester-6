class_name WinScreen
extends CanvasLayer

@export var animation_player : AnimationPlayer

signal continue_game

func _on_continue_pressed() -> void:
	emit_signal("continue_game")

func _on_visibility_changed() -> void:
	print("visib: ", visible)
