class_name ShopMenu
extends CanvasLayer

@export var buy_indicator : Node2D
@export var sell_indicator : Node2D

@export var animation_player : AnimationPlayer
@export var money_display : NumberDisplay

var obstacle_buyable = true

var max_money = 6
var money = max_money:
	get:
		return money
	set(value):
		money = value
		money_display.update_number(money)

func transition_to_shop(enter : bool):
	if enter:
		money = max_money + 1
		
		if !obstacle_buyable:
			money -= 2
		
		animation_player.play("fade_in")
	else:
		animation_player.play("fade_out")

func show_buy_indicator():
	buy_indicator.visible = true

func hide_buy_indicator():
	buy_indicator.visible = false

func show_sell_indicator():
	sell_indicator.visible = true

func hide_sell_indicator():
	sell_indicator.visible = false

func buy_item():
	money -= 1

func sell_item():
	pass

