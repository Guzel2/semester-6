@tool
class_name FoodVisual
extends Node2D

@export var food_manager : FoodManager

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
	
	var child_positions = []
	
	for x in width:
		for y in height:
			var sprite = sprite_scene.instantiate() as Sprite2D
			
			sprite.position = Vector2(x * cell_size, y * cell_size)
			
			var sub_image = Image.new()
			sub_image = sub_image.create(cell_size, cell_size, false, image.get_format())
			
			sub_image.fill(Color.PALE_GREEN)
			
			var all_pixel_invisible = true
			
			for sub_x in cell_size:
				for sub_y in cell_size:
					var pixel_pos = Vector2(x * cell_size + sub_x, y * cell_size + sub_y)
					var color = image.get_pixelv(pixel_pos)
					
					if color.a > 0:
						all_pixel_invisible = false
					
					sub_image.set_pixel(sub_x, sub_y, color)
			
			if all_pixel_invisible:
				continue
			
			var sub_texture = ImageTexture.new()
			sub_texture = sub_texture.create_from_image(sub_image)
			
			sprite.texture = sub_texture
			
			add_child(sprite)
			
			child_positions.append(Vector2(x, y))
	
	if food_manager:
		var food_info = FoodInfo.new()
		
		food_info.positions = child_positions
		
		food_info.scenes = get_children()
	
	print(child_positions)
