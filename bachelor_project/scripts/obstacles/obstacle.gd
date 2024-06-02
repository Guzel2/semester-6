class_name Obstacle
extends Polygon2D

@export var area : ObstacleArea
@export var collision_polygon : CollisionPolygon2D

func _ready():
	visible = false
	
	collision_polygon.polygon = polygon
