class_name ScentVisual
extends Sprite2D

var intensity = 0
var max_lifetime = 15.0
var lifetime = max_lifetime

func _process(delta: float) -> void:
	lifetime -= delta
	
	modulate.a = (lifetime / max_lifetime) / 2
	
	if lifetime < 0:
		queue_free()
