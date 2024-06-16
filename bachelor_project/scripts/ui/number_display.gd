class_name NumberDisplay
extends Label

@export var suffix : String = "number"

func update_number(number : int):
	text = str(number) + " " + suffix
