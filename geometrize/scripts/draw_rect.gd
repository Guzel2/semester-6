class_name DrawRect
extends Object

var position : Vector2:
	set(value):
		position = value
		rect.position = value

var size : Vector2:
	set(value):
		size = value
		rect.size = value

var rect : Rect2

var color : Color
