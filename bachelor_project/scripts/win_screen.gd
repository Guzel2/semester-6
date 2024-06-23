class_name WinScreen
extends CanvasLayer

@export var animation_player : AnimationPlayer

signal continue_game
signal main_menu

func _ready() -> void:
	visible = false

func _on_continue_pressed() -> void:
	emit_signal("continue_game")
	animation_player.play("fade_out")

func _on_main_menu_pressed() -> void:
	emit_signal("main_menu")
	animation_player.play("fade_out")
