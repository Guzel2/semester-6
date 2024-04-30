class_name ScentVisual
extends Sprite2D

@export var simulation_speed = 1.0

var intensity = 0
var max_lifetime = 15.0
var lifetime = max_lifetime

func _process(delta: float) -> void:
	delta *= simulation_speed
	
	lifetime -= delta
	
	modulate.a = (lifetime / max_lifetime) / 2
	
	if lifetime < 0:
		queue_free()
