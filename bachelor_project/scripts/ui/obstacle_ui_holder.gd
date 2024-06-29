class_name ObstacleUIHolder
extends HBoxContainer

@export var obstacle_scene : PackedScene

@export var camera : Camera
@export var obstacle_manager : ObstacleManager

var previous_positions = {}

signal remaining_obstacles(items : Array)

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

func add_obstacle(item : EnumManager.item_list):
	var obstacle = obstacle_scene.instantiate() as ObstacleButton
	obstacle.holder = self
	obstacle.item = item
	add_child(obstacle)

func lock_scroll_wheel(lock : bool):
	camera.lock_scroll_wheel(lock)

func _on_bought_holder_remaining_obstacles(items : Array):
	for item in items:
		add_obstacle(item)

func _on_main_end_of_day():
	var obstacles = []
	
	for obstacle in get_children():
		obstacle = obstacle as ObstacleButton
		if obstacle.item < EnumManager.obstacle_count:
			obstacles.append(obstacle.item)
			
			obstacle.queue_free()
	
	emit_signal("remaining_obstacles", obstacles)
