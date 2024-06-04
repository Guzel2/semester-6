class_name ObstacleButton
extends Button

var follow_mouse = false
var offset : Vector2
var local_offset : Vector2

var start_pos : Vector2
var end_pos : Vector2

@export var moving_time = .5
var move_time = .0

var moving = false

var holder : ObstacleUIHolder

@export var max_move_distance = 10
@export var rotation_step_size = 10

@export var icon_sprite : AnimatedSprite2D
@export var preview_sprite : AnimatedSprite2D

var icon_mode = true

var item : EnumManager.item_list = EnumManager.item_list.rock_0
var item_string : String

func _ready():
	item_string = EnumManager.item_list.keys()[item]
	icon_sprite.animation = item_string
	preview_sprite.animation = item_string

func _on_button_down() -> void:
	start_following_mouse()
	start_pos = position
	
	holder.lock_scroll_wheel(true)

func _on_button_up() -> void:
	if position.distance_to(start_pos) > max_move_distance:
		spawn_obstacle()
		queue_free()
	stop_following_mouse()
	
	holder.lock_scroll_wheel(false)

func _on_pressed() -> void:
	if position.distance_to(start_pos) < max_move_distance:
		holder.queue_sort()

func start_following_mouse():
	follow_mouse = true
	
	offset = get_global_mouse_position() - position
	local_offset = get_local_mouse_position()
	
	preview_sprite.scale = holder.camera.zoom

func _process(delta: float) -> void:
	if follow_mouse:
		position = get_global_mouse_position() - offset
		
		if icon_mode:
			if position.distance_to(start_pos) > max_move_distance:
				change_icon_mode(false)
		elif position.distance_to(start_pos) < max_move_distance:
			change_icon_mode(true)
	
	if moving:
		move_time += delta
		var t = move_time / moving_time
		
		t = ease(t, -3)
		
		position = (1.0 - t) * start_pos + t * end_pos
		
		if t >= 1:
			position = end_pos
			moving = false

func _input(event):
	if !follow_mouse:
		return
	
	if event.is_action_pressed("scroll_down"):
		preview_sprite.rotation_degrees += rotation_step_size
	
	if event.is_action_pressed("scroll_up"):
		preview_sprite.rotation_degrees -= rotation_step_size

func stop_following_mouse():
	follow_mouse = false
	
	holder.queue_sort()

func move_from_to(_start_pos : Vector2, _end_pos : Vector2):
	start_pos = _start_pos
	end_pos = _end_pos
	move_time = 0
	moving = true

func change_icon_mode(change : bool):
	icon_mode = change
	icon_sprite.visible = change
	preview_sprite.visible = !change
	preview_sprite.rotation_degrees = 0

func spawn_obstacle():
	var pos = holder.obstacle_manager.get_local_mouse_position() - local_offset + preview_sprite.position
	
	holder.obstacle_manager.add_obstacle(preview_sprite.animation, preview_sprite.rotation, pos)
	
