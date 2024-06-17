class_name FoodPiece
extends Sprite2D

var max_food = 10.0
var remaining_food = max_food:
	get:
		return remaining_food
	set(value):
		remaining_food = value
		
		material.set_shader_parameter("consume_percentage", remaining_food / max_food)

var up : bool = false:
	set(value):
		up = value
		material.set_shader_parameter("up", up)

var down : bool = false:
	set(value):
		down = value
		material.set_shader_parameter("down", down)

var left : bool = false:
	set(value):
		left = value
		material.set_shader_parameter("left", left)

var right : bool = false:
	set(value):
		right = value
		material.set_shader_parameter("right", right)

func _ready() -> void:
	var offset_texture = material.get_shader_parameter("offset_texture") as NoiseTexture2D
	var noise = offset_texture.noise as FastNoiseLite
	noise.seed = randi()
