class_name ObstacleButton
extends Button

var follow_mouse = false
var offset : Vector2

var start_pos : Vector2
var end_pos : Vector2

@export var moving_time = .5
var move_time = .0

var moving = false

var holder : Container

@export var max_move_distance = 10

@export var icon_sprite : AnimatedSprite2D
@export var preview_sprite : AnimatedSprite2D

var icon_mode = true

func _on_button_down() -> void:
	start_following_mouse()
	start_pos = position

func _on_button_up() -> void:
	stop_following_mouse()

func _on_pressed() -> void:
	if position.distance_to(start_pos) < max_move_distance:
		holder.queue_sort()

func start_following_mouse():
	follow_mouse = true
	
	offset = get_global_mouse_position() - position

func stop_following_mouse():
	follow_mouse = false
	
	holder.queue_sort()

func move_from_to(_start_pos : Vector2, _end_pos : Vector2):
	start_pos = _start_pos
	end_pos = _end_pos
	move_time = 0
	moving = true

func _process(delta: float) -> void:
	if follow_mouse:
		position = get_global_mouse_position() - offset
		
		if icon_mode:
			if position.distance_to(start_pos) > max_move_distance:
				icon_mode = false
				icon_sprite.visible = false
				preview_sprite.visible = true
		elif position.distance_to(start_pos) < max_move_distance:
			icon_mode = true
			icon_sprite.visible = true
			preview_sprite.visible = false
	
	if moving:
		move_time += delta
		var t = move_time / moving_time
		
		t = ease(t, -3)
		
		position = (1.0 - t) * start_pos + t * end_pos
		
		if t >= 1:
			position = end_pos
			moving = false
