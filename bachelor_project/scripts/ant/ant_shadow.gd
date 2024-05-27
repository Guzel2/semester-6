class_name AntShadow
extends Sprite2D

@export var ant : Ant

var sun_dir : Vector3 = Vector3(0, 0, -1)

func _process(delta: float) -> void:
	sun_dir = ant.ant_manager.shadow_manager.sun_dir
	
	var rot = Vector2(-sun_dir.x, sun_dir.y).rotated(global_rotation).rotated(PI / 4).angle()
	
	material.set_shader_parameter("rotation", rot)
	material.set_shader_parameter("scale", 3.25 + sun_dir.z * 2)
