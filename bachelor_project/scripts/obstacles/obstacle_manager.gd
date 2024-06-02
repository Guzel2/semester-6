class_name ObstacleManager
extends Node2D

var path = "res://scenes/obstacles/path.tscn"

func add_obstacle(type : String, rot : float, pos : Vector2):
	var _path = path.replace("path", type)
	
	var scene = load(_path).instantiate()
	scene.position = pos
	scene.rotation = rot
	
	add_child(scene)
