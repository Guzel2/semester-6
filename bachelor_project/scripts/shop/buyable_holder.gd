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
	
	call_deferred("refill_shop")

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
	
	var wait_for_other = false
	
	for item in get_children():
		item = item as Item
		
		if item.position != item.start_pos:
			wait_for_other = true
			break
	
	if wait_for_other:
		if old_child_count > 0:
			var item = get_child(0) as Item
			
			if item:
				await item.stopped_moving
	
	for x in new_child_count:
		add_item(EnumManager.item_list[potential_items.pick_random()], Item.item_state.buyable)
	
	#call_deferred("late_sort")

func _on_main_end_off_day():
	reroll_shop()

func _on_reroll_shop_pressed() -> void:
	reroll_shop()

func late_sort():
	call_deferred("force_sort")

func force_sort():
	for item in get_children():
		item = item as Item
		
		if !item:
			continue
		
		if item.locked:
			continue
		
		item.position = Vector2(0, 0)
	
	queue_sort()
