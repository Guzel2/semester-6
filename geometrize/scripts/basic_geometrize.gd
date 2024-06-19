@tool
extends Node2D

@export var use_evolution = false
@export var run = false:
	set(value):
		run = value
		
		if run:
			generate_all_rects()

@export var texture : Texture2D
var image : Image

var squares

var bg_rect : DrawRect
var rects : Array = []

func _process(delta):
	if run:
		queue_redraw()

func _draw():
	if !run:
		return
	
	draw_rect(bg_rect.rect, bg_rect.color)
	
	for drawing_rect in rects:
		drawing_rect = drawing_rect as DrawRect
		
		var rect = drawing_rect.rect
		var color = drawing_rect.color
		
		draw_rect(rect, color)

func generate_all_rects():
	rects.clear()
	
	image = texture.get_image()
	
	var width = image.get_width()
	var height = image.get_height()
	
	var total_color : Color = Color(0, 0, 0)
	var pixel_count = width * height
	
	for x in width:
		for y in height:
			var color = image.get_pixel(x, y)
			
			total_color += color
	
	total_color /= pixel_count
	
	bg_rect = DrawRect.new()
	bg_rect.position = Vector2(0, 0)
	bg_rect.size = Vector2(width, height)
	bg_rect.color = total_color
	
	var rect_count = 100
	
	for i in rect_count:
		var rect = generate_rect(image)
		rects.append(rect)
		
		print("Progress: ", i, "/", rect_count)
		
		await get_tree().create_timer(.01).timeout
	
	print("done")

func generate_rect(image : Image) -> DrawRect:
	var new_rects = []
	
	var width = image.get_width()
	var height = image.get_height()
	
	for i in 15:
		var rect = DrawRect.new()
		
		var found_fitting_rectangle = false
		for test in 100:
			
			rect.position = Vector2(randi_range(0, width), randi_range(0, height))
			rect.size = Vector2(randi_range(20, width - rect.position.x), randi_range(30, height - rect.position.y))
			
			var end = rect.position + rect.size
			
			if end.x < width and end.y < height:
				found_fitting_rectangle = true
				break
		
		if !found_fitting_rectangle:
			continue
		
		#rect.color = Color(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1))
		rect.color = image.get_pixelv(rect.position + rect.size / 2)
		
		var total_difference = 0
		var total_pixels = rect.size.x * rect.size.y
		
		for loc_x in rect.size.x - 1:
			for loc_y in rect.size.y - 1:
				var x = loc_x + rect.position.x
				var y = loc_y + rect.position.y
				
				var color = image.get_pixel(x, y)
				
				var new_color = (color - rect.color)
				
				var difference = abs(new_color.r) + abs(new_color.g) + abs(new_color.b)
				
				total_difference += difference
		
		total_difference /= total_pixels
		
		rect.difference = total_difference
		
		for other_rect in rects:
			rect.overlap += rect.get_overlap(other_rect)
		
		new_rects.append(rect)
	
	var min_error_size = new_rects[0].error_size
	var return_rect = new_rects[0]
	
	for x in range(1, new_rects.size()):
		var rect = new_rects[x] as DrawRect
		
		if rect.error_size < min_error_size:
			return_rect = rect
			min_error_size = rect.error_size
	
	if use_evolution:
		return_rect = create_variations(image, return_rect)
	
	return return_rect

func create_variations(image: Image, original_rect: DrawRect):
	var new_rects = []
	
	var width = image.get_width()
	var height = image.get_height()
	
	for i in 15:
		var rect = DrawRect.new()
		
		var found_fitting_rectangle = false
		
		for test in 100:
			
			rect.position = Vector2(original_rect.position.x * randf_range(.8, 1.25), original_rect.position.y * randf_range(.8, 1.25))
			rect.size = Vector2(original_rect.size.x * randf_range(.8, 1.25), original_rect.size.y * randf_range(.8, 1.25))
			
			var end = rect.position + rect.size
			
			if end.x < width and end.y < height:
				found_fitting_rectangle = true
				break
		
		if !found_fitting_rectangle:
			continue
		
		#rect.color = Color(randf_range(0, 1), randf_range(0, 1), randf_range(0, 1))
		#rect.color = image.get_pixelv(rect.position + rect.size / 2)
		
		rect.color = original_rect.color# * Color(randf_range(.91, 1.1), randf_range(.91, 1.1), randf_range(.91, 1.1))
		
		var total_difference = 0
		var total_pixels = rect.size.x * rect.size.y
		
		for loc_x in rect.size.x - 1:
			for loc_y in rect.size.y - 1:
				var x = loc_x + rect.position.x
				var y = loc_y + rect.position.y
				
				var color = image.get_pixel(x, y)
				
				var new_color = (color - rect.color)
				
				var difference = abs(new_color.r) + abs(new_color.g) + abs(new_color.b)
				
				total_difference += difference
		
		total_difference /= total_pixels
		
		rect.difference = total_difference
		
		for other_rect in rects:
			rect.overlap += rect.get_overlap(other_rect)
		
		new_rects.append(rect)
	
	var min_error_size = original_rect.error_size
	var return_rect = original_rect
	
	for x in range(1, new_rects.size()):
		var rect = new_rects[x] as DrawRect
		
		if rect.error_size < min_error_size:
			return_rect = rect
			min_error_size = rect.error_size
	
	if return_rect == original_rect:
		print("chose original")
	
	return return_rect
