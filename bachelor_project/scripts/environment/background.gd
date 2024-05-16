class_name Background
extends CanvasLayer

@export var camera : Camera
@export var color_rect : ColorRect

func _process(delta: float) -> void:
	color_rect.material.set_shader_parameter("zoom", camera.zoom.x)
	var camera_pos = camera.get_target_position()
	color_rect.material.set_shader_parameter("offset", camera_pos / Vector2(500, 300))
	
	
	#color_rect.material.set_shader_parameter("offset", (camera.position + (Vector2(500, 300) / 2) / (Vector2(500, 300) / camera.zoom)))
