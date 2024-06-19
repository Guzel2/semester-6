class_name DrawRect
extends Object

var position : Vector2:
	set(value):
		position = value
		rect.position = value
		
		set_end()

var size : Vector2:
	set(value):
		size = value
		rect.size = value
		
		set_end()

var end : Vector2

var rect : Rect2

var color : Color

var difference : float = 0
var overlap : int = 0
var error_size : float:
	get:
		return difference + float(overlap) / 1000# + (3000 / (size.y * size.y))

func set_end():
	end = position + size

func get_overlap(other_rect : DrawRect) -> int:
	var overlap_left = max(position.x, other_rect.position.x)
	var overlap_right = min(end.x, other_rect.end.x)
	var overlap_top = max(position.y, other_rect.position.y)
	var overlap_bottom = min(end.y, other_rect.end.y)
	
	var overlap_width = overlap_right - overlap_left
	var overlap_height = overlap_bottom - overlap_top
	
	if overlap_width > 0 and overlap_height > 0:
		return overlap_width * overlap_height
	else:
		return 0
