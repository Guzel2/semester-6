class_name BuyableHolder
extends ItemHolder

@export var buyable_scene : PackedScene

@export var bought_holder : ItemHolder

var potential_items = []

func _ready():
	set_potential_items()
	
	for x in 9:
		var buyable = buyable_scene.instantiate() as Item
		buyable.holder = self
		buyable.item = EnumManager.item_list[potential_items.pick_random()]
		
		add_child(buyable)
		
		add_connections(buyable)
	
	super._ready()

func set_potential_items():
	potential_items.clear()
	
	for item in EnumManager.item_list:
		potential_items.append(item)
	
	print(potential_items)
	

func show_move_indicator():
	shop_menu.show_buy_indicator()

func hide_move_indicator():
	shop_menu.hide_buy_indicator()
