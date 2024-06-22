class_name NumberDisplay
extends Label

@export var prefix : String = ""
@export var suffix : String = "number"

func update_number(number : int):
	text = prefix + str(number) + suffix
