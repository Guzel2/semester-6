class_name BuyableHolder
extends ItemHolder

@export var buyable_scene : PackedScene

@export var bought_holder : ItemHolder

@export var shop_menu : ShopMenu

func _ready():
	for x in 9:
		var buyable = buyable_scene.instantiate() as Item
		add_child(buyable)
		buyable.holder = self
		
		add_connections(buyable)
	
	super._ready()

func show_move_indicator():
	shop_menu.show_buy_indicator()

func hide_move_indicator():
	shop_menu.hide_buy_indicator()
