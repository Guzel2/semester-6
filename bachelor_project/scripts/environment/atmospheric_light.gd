class_name AtmosphericLight
extends CanvasLayer

@export var morning_color : Color
@export var day_color : Color
@export var evening_color : Color

@export var shadow_manager : ShadowManager
@export var color_rect : ColorRect

func _process(delta: float) -> void:
	var t = shadow_manager.t
	
	var linear_0 = morning_color * (1 - t) + day_color * t
	var linear_1 = day_color * (1 - t) + evening_color * t
	var quadratic_0 = linear_0 * (1 - t) + linear_1 * t
	
	color_rect.color = quadratic_0
