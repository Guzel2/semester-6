class_name Camera
extends Camera2D

@export var UI : Node2D

var scroll_multiplier = 1.25

var move_speed = 30
var friction = .9

var dir = Vector2(0, 0)

var track_mouse = false
var mouse_start_pos = Vector2(0, 0)
var mouse_offset = Vector2(0, 0)

func _input(event):
	if event.is_action_pressed("scroll_down"):
		change_zoom(1.0 / scroll_multiplier)
	
	if event.is_action_pressed("scroll_up"):
		change_zoom(scroll_multiplier)
	
	if event.is_action_pressed("middle_mouse_button"):
		track_mouse = true
		mouse_start_pos = get_local_mouse_position()
	if event.is_action_released("middle_mouse_button"):
		track_mouse = false
	
	var mouse_event = event as InputEventMouseMotion
	if mouse_event:
		if track_mouse:
			position -= mouse_event.velocity * .1

func _physics_process(delta):
	movement(delta)
	

func movement(delta):
	var temp_dir = Vector2(0, 0)
	
	if Input.is_action_pressed("up"):
		temp_dir += Vector2.UP
	if Input.is_action_pressed("down"):
		temp_dir += Vector2.DOWN
	if Input.is_action_pressed("left"):
		temp_dir += Vector2.LEFT
	if Input.is_action_pressed("right"):
		temp_dir += Vector2.RIGHT
	
	if position.x < 0:
		temp_dir.x += 1
	if position.x > 1000:
		temp_dir.x -= 1
	
	if position.y < 0:
		temp_dir.y += 1
	if position.y > 1000:
		temp_dir.y -= 1
	
	dir += temp_dir.normalized()
	
	position += dir * delta / zoom * move_speed
	
	dir *= pow(friction, 60 * delta)

func change_zoom(multiplier: float):
	zoom *= multiplier
	UI.scale /= multiplier
	
	#adjust camera position according to mouse
	#var mouse_pos = get_global_mouse_position()
	#var dir_from_mouse = position - mouse_pos
	#position = mouse_pos + dir_from_mouse * (1.0 / multiplier)
