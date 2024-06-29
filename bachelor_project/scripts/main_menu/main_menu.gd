class_name MainMenu
extends CanvasLayer

@export var main : Main
@export var animation_player : AnimationPlayer

func enter():
	animation_player.play("fade_in")

func _on_new_run_pressed() -> void:
	main.new_run()
	animation_player.play("fade_out")

func _on_quit_pressed() -> void:
	get_tree().quit()
