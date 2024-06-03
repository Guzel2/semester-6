class_name ShopMenu
extends CanvasLayer

@export var buy_indicator : ColorRect
@export var sell_indicator : ColorRect

func show_buy_indicator():
	buy_indicator.visible = true

func hide_buy_indicator():
	buy_indicator.visible = false

func show_sell_indicator():
	sell_indicator.visible = true

func hide_sell_indicator():
	sell_indicator.visible = false
