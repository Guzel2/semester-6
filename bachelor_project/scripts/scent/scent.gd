class_name Scent
extends Object

var type : EnumManager.scent_types

var intensity : int = 0
var max_intensity : int = 3

var max_time : float = 20.0
var remaining_time : float = max_time

func process(delta: float):
	remaining_time -= delta
	
	if remaining_time <= 0:
		if intensity > 0:
			intensity -= 1
			remaining_time = max_time + remaining_time
	
	return remaining_time

func remove_scent():
	pass

func increase_scent():
	if intensity < max_intensity:
		intensity += 1
