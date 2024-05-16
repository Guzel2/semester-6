extends Node2D

@export var noise : Noise

func _ready() -> void:
	create_height_map_png()

func create_height_map_png():
	var sprite = Image.new().create(1000, 1000, false, Image.FORMAT_RGBA8)
	
	for x in 1000:
		for y in 1000:
			var height = noise.get_noise_2d(x, y)
			sprite.set_pixel(x, y, Color(height, 0, 0, 1))
	
	sprite.save_png("sprites/height_map.png")

func create_white_square_png():
	var sprite = Image.new().create(149, 149, false, Image.FORMAT_RGBA8)
	
	for x in 149:
		for y in 149:
			sprite.set_pixel(x, y, Color(1, 1, 1, 1))
	
	sprite.save_png("bg.png")

func create_hold_height_map():
	var sprite = Image.new().create(1000, 1000, false, Image.FORMAT_RGBA8)
	
	for x in range(200, 300):
		for y in range(200, 300):
			var vector = Vector2(x, y) - Vector2(250, 250)
			var length = vector.length()
			if length < 50:
				var height = 1.0 - (length / 50.0)
				
				sprite.set_pixel(x, y, Color(height, 0, 0, 1))
	
	for x in range(200, 250):
		for y in range(400, 450):
			sprite.set_pixel(x, y, Color(.7, 0, 0, 1))
	
	
	sprite.save_png("sprites/height_map.png")
