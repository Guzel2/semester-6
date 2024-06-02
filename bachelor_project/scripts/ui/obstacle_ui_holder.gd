class_name ObstacleUIHolder
extends VBoxContainer

@export var obstacle_scene : PackedScene

@export var camera : Camera
@export var obstacle_manager : ObstacleManager

var previous_positions = {}

func _ready():
	for x in 50:
		add_obstacle()

func _on_pre_sort_children() -> void:
	previous_positions.clear()
	for obstacle in get_children():
		obstacle = obstacle as ObstacleButton
		
		if obstacle:
			previous_positions[obstacle] = obstacle.position

func _on_sort_children():
	for obstacle in get_children():
		obstacle = obstacle as ObstacleButton
		
		obstacle.move_from_to(previous_positions[obstacle], obstacle.position)

func add_obstacle():
	var obstacle = obstacle_scene.instantiate() as ObstacleButton
	obstacle.holder = self
	add_child(obstacle)

func lock_scroll_wheel(lock : bool):
	camera.lock_scroll_wheel(lock)

