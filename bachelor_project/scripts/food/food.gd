class_name Food
extends Object

var max_food = 10.0
var remaining_food = max_food

func remove_food():
	pass

func consume_food(value: float) -> float:
	remaining_food -= value
	
	if remaining_food < 0:
		return value + remaining_food
	
	return value
