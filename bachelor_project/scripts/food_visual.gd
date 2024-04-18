class_name FoodVisual
extends Sprite2D

var max_food = 10.0
var remaining_food = max_food

func _process(delta):
	modulate.a = remaining_food / max_food
