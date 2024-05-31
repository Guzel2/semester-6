class_name Obstacle
extends Area2D

func _on_body_entered(body):
	var ant = body.get_parent() as Ant
	
	
