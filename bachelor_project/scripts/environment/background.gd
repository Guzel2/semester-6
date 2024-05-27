class_name Background
extends CanvasLayer

@export var shadow_manager : ShadowManager
@export var camera : Camera
@export var color_rect : ColorRect

var sun_dir = Vector3(-1, 0, -100)

func _process(delta: float) -> void:
	color_rect.material.set_shader_parameter("zoom", camera.zoom.x)
	var camera_pos = camera.get_target_position()
	color_rect.material.set_shader_parameter("offset", camera_pos / Vector2(500, 300))
	
	#color_rect.material.set_shader_parameter("offset", (camera.position + (Vector2(500, 300) / 2) / (Vector2(500, 300) / camera.zoom)))
	
	sun_dir = shadow_manager.sun_dir
	
	color_rect.material.set_shader_parameter("sun_dir", sun_dir.normalized())
