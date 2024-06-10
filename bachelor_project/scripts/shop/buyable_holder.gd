class_name BuyableHolder
extends ItemHolder

var potential_items = []

func _ready():
	set_potential_items()
	
	super._ready()

func set_potential_items():
	potential_items.clear()
	
	for item in EnumManager.item_list:
		potential_items.append(item)

func show_move_indicator():
	shop_menu.show_buy_indicator()

func hide_move_indicator():
	shop_menu.hide_buy_indicator()

func refill_shop():
	set_potential_items()
	
	for x in 9 - get_child_count():
		add_item(EnumManager.item_list[potential_items.pick_random()], Item.item_state.buyable)

func _on_main_end_off_day():
	refill_shop()

func _on_reroll_shop_pressed() -> void:
	for child in get_children():
		child.queue_free()
	
	refill_shop()
