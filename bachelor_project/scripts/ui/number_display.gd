class_name NumberDisplay
extends Label

@export var prefix : String = ""
@export var suffix : String = "number"

@export var copy_display : NumberDisplay

func update_number(number : int):
	text = prefix + str(number) + suffix
	
	if copy_display:
		copy_display.text = text
