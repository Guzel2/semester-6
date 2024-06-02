class_name Camera
extends Camera2D

@export var user_interface : UserInterface
@export var shop_menu : ShopMenu

var scroll_multiplier = 1.25

var move_speed = 30
var friction = .9

var dir = Vector2(0, 0)

var track_mouse = false
var last_mouse_pos = Vector2(0, 0)

func _ready():
	last_mouse_pos = get_local_mouse_position()

func _input(event):
	if event.is_action_pressed("scroll_down"):
		if zoom.x > .35:
			change_zoom(1.0 / scroll_multiplier)
	
	if event.is_action_pressed("scroll_up"):
		if zoom.x < 3:
			change_zoom(scroll_multiplier)
	
	if event.is_action_pressed("middle_mouse_button"):
		track_mouse = true
	if event.is_action_released("middle_mouse_button"):
		track_mouse = false

func _physics_process(delta):
	movement(delta)
	
	var mouse_pos = get_local_mouse_position()
	var mouse_dir = last_mouse_pos - mouse_pos
	last_mouse_pos = mouse_pos
	
	if track_mouse:
		position += mouse_dir * delta * move_speed * 2

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
	
	#adjust camera position according to mouse
	#var mouse_pos = get_global_mouse_position()
	#var dir_from_mouse = position - mouse_pos
	#position = mouse_pos + dir_from_mouse * (1.0 / multiplier)

func transition_to_shop(enter : bool):
	user_interface.visible = !enter
	shop_menu.visible = enter
