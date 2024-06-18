@tool
extends Node2D

@export var run = false:
	set(value):
		run = value
		
		if run:
			generate_rects()

@export var texture : Texture2D
var image : Image

var squares

var rects : Array = []
var rect_count : int = 100

func _process(delta):
	if run:
		queue_redraw()

func _draw():
	if !run:
		return
	
	for drawing_rect in rects:
		drawing_rect = drawing_rect as DrawRect
		
		var rect = drawing_rect.rect
		var color = drawing_rect.color
		
		draw_rect(rect, color)

func generate_rects():
	rects.clear()
	
	image = texture.get_image()
	
	var width = image.get_width()
	var height = image.get_height()
	
	for x in 100:
		var rect = DrawRect.new()
		
		rect.position = Vector2(randf_range(0, width), randf_range(0, height))
		rect.size = Vector2(randf_range(0, width - rect.position.x), randf_range(0, height - rect.position.y))
		
		rect.color = Color(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1))
		
		rects.append(rect)
	
	print(rects)
