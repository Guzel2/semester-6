class_name LoseScreen
extends CanvasLayer

@export var animation_player : AnimationPlayer

signal new_run
signal main_menu

func _ready() -> void:
	visible = false

func _on_new_run_pressed() -> void:
	emit_signal("new_run")
	animation_player.play("fade_out")

func _on_main_menu_pressed() -> void:
	emit_signal("main_menu")
	animation_player.play("fade_out")
