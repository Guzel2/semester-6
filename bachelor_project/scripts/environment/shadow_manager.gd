class_name ShadowManager
extends Node2D

@export var camera : Camera

var sun_dir = Vector3(0, 0, -1)
var old_mouse_pos : Vector2 = Vector2(0, 0)

var sun_positions = [Vector2(-1, 0), Vector2(0, -.6), Vector2(1, 0)]

var timer = 0.0
var t = 0.0
var day_duration = 75.0

var simulation_speed = 1.0


signal end_of_day

func _process(delta: float) -> void:
	timer += delta * simulation_speed
	t = timer / day_duration
	
	var linear_0 = sun_positions[0] * (1 - t) + sun_positions[1] * t
	var linear_1 = sun_positions[1] * (1 - t) + sun_positions[2] * t
	var quadratic_0 = linear_0 * (1 - t) + linear_1 * t
	
	sun_dir = Vector3(quadratic_0.x, quadratic_0.y, -1).normalized()
	
	if timer > day_duration:
		emit_signal("end_of_day")
		set_process(false)

func start_day():
	set_process(true)
	timer = 0

func get_sun_dir_from_mouse():
	var mouse_pos = camera.get_local_mouse_position() / 4
	mouse_pos = Vector2(mouse_pos.x, mouse_pos.y)
	
	if mouse_pos != old_mouse_pos:
		old_mouse_pos = mouse_pos
		sun_dir.x = mouse_pos.x
		sun_dir.y = mouse_pos.y
		sun_dir.z = -100
		sun_dir = sun_dir.normalized()
