class_name FoodDebug
extends Sprite2D

var max_food = 10.0
var remaining_food = max_food:
	get:
		return remaining_food
	set(value):
		remaining_food = value
		
		modulate.a = remaining_food / max_food
		
		if remaining_food < 0:
			queue_free()
