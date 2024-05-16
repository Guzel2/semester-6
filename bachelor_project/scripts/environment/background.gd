class_name Background
extends CanvasLayer

@export var camera : Camera
@export var color_rect : ColorRect

var sun_dir = Vector3(-1, 0, -1)

func _process(delta: float) -> void:
	color_rect.material.set_shader_parameter("zoom", camera.zoom.x)
	var camera_pos = camera.get_target_position()
	color_rect.material.set_shader_parameter("offset", camera_pos / Vector2(500, 300))
	
	#color_rect.material.set_shader_parameter("offset", (camera.position + (Vector2(500, 300) / 2) / (Vector2(500, 300) / camera.zoom)))
	
	var mouse_pos = get_local_mouse_position().normalized()
	sun_dir.x = mouse_pos.x
	sun_dir.y = mouse_pos.y
	
	color_rect.material.set_shader_parameter("sun_dir", sun_dir)

func get_local_mouse_position() -> Vector2:
	return camera.get_local_mouse_position()
