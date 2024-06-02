class_name ObstacleArea
extends Area2D

@export var polygon : Obstacle

var center_point : Vector2 = Vector2(0, 0)

func _ready():
	for point in polygon.polygon:
		center_point += point
	
	center_point /= polygon.polygon.size()
	center_point += global_position

func _on_body_entered(body):
	var ant = body as Ant
	
	ant.detect_obstacle(self)

func check_collisions(ant : Ant):
	for body in get_overlapping_bodies():
		if body == ant:
			ant.detect_obstacle(self)
