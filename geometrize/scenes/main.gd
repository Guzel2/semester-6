extends Node2D

@export var change_indicator : ColorRect

@export_range(2, 100) var sample_points = 2

var last_frame : Image = null
var current_frame : Image = null

var last_texture : Texture = null
var current_texture : Texture = null

func _ready():
	pass

func _process(delta):
	current_texture = get_viewport().get_texture()
	current_frame = current_texture.get_image()
	
	if last_texture:
		change_indicator.material.set_shader_parameter("last_texture", last_texture)
		
		#compare_frames()
	
	last_texture = current_texture
	last_frame = current_frame

func compare_frames():
	var last_frame_width = last_frame.get_width()
	var last_frame_height = last_frame.get_height()
	
	if last_frame.get_width() != current_frame.get_width() or last_frame.get_height() != current_frame.get_height():
		return
	
	var step_count = sample_points
	var step_size = Vector2(last_frame_width, last_frame_height) / step_count
	
	var total_difference = 0
	
	for x in step_count:
		for y in step_count:
			var _x = x * step_size.x
			var _y = y * step_size.y
			
			var last_color = last_frame.get_pixel(_x, _y)
			var current_color = current_frame.get_pixel(_x, _y)
			
			var difference = last_color - current_color
			
			var difference_v = Vector3(difference.r, difference.g, difference.b)
			
			total_difference += difference_v.length()
	
	if total_difference > 0:
		print(total_difference)
