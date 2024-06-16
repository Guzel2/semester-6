@tool
class_name FoodVisual
extends Node2D

@export var texture : Texture2D
@export var mat : Material
@export var sprite_scene : PackedScene

@export var generate_subimages : bool = false:
	set(value):
		if value:
			spawn_subimages()
		

@export var cell_size : int = 10

func _ready() -> void:
	spawn_subimages()

func spawn_subimages():
	for child in get_children():
		child.queue_free()
	
	var image = texture.get_image()
	
	var width = image.get_width() / cell_size
	var height = image.get_height() / cell_size
	
	for x in width:
		for y in height:
			var sprite = sprite_scene.instantiate() as Sprite2D
			
			add_child(sprite)
			
			var sub_image = Image.new()
			sub_image = Image.create(cell_size, cell_size, false, image.get_format())
			
			for sub_x in cell_size:
				for sub_y in cell_size:
					var pixel_pos = Vector2(x * cell_size + sub_x, y * cell_size + sub_y)
					var color = Color.ALICE_BLUE #image.get_pixelv(pixel_pos)
					
					sub_image.set_pixel(sub_x, sub_y, color)
			
			var sub_texture = ImageTexture.new()
			sub_texture.create_from_image(sub_image)
			
			sprite.texture = sub_texture
			
			sprite.position = Vector2(x * width, y * height) * 1.1
	
	print(get_child_count())
