class_name BoughtHolder
extends ItemHolder

@export var buyable_holder : BuyableHolder

func show_move_indicator():
	shop_menu.show_sell_indicator()

func hide_move_indicator():
	shop_menu.hide_sell_indicator()
