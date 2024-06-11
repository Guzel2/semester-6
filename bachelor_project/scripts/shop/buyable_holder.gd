class_name BuyableHolder
extends ItemHolder

var potential_items = []

signal no_children_left

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

func reroll_shop():
	clear_shop()
	
	refill_shop()

func clear_shop():
	for item in get_children():
		item = item as Item
		
		if !item.locked:
			item.queue_free()
			
			remove_child(item)

func refill_shop():
	set_potential_items()
	
	var old_child_count = get_child_count()
	var new_child_count = 9 - old_child_count
	
	if old_child_count > 0:
		var item = get_child(0) as Item
		
		if item:
			await item.stopped_moving
	
	skip_sorting = true
	
	for x in new_child_count:
		add_item(EnumManager.item_list[potential_items.pick_random()], Item.item_state.buyable)
		
		#make it so it only sorts once and not every time a new item gets added
	
	call_deferred("late_sort")

func _on_main_end_off_day():
	reroll_shop()

func _on_reroll_shop_pressed() -> void:
	reroll_shop()

func late_sort():
	
	skip_sorting = false
	
	queue_sort()
