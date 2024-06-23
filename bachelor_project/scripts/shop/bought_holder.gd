class_name BoughtHolder
extends ItemHolder

signal remaining_obstacles(items : Array)

func show_move_indicator():
	shop_menu.show_sell_indicator()

func hide_move_indicator():
	shop_menu.hide_sell_indicator()

func start_day():
	var obstacles = []
	for item in get_children():
		item = item as Item
		if item.item < EnumManager.obstacle_count:
			obstacles.append(item.item)
			
			item.queue_free()
	
	emit_signal("remaining_obstacles", obstacles)

func end_day():
	pass

func _on_main_start_off_day():
	start_day()

func _on_main_end_off_day():
	end_day()

func _on_obstacle_ui_holder_remaining_obstacles(items):
	for item in items:
		add_item(item, Item.item_state.bought)

func _on_sell_all_pressed() -> void:
	for item in get_children():
		item = item as Item
		
		if !item:
			continue
		
		if item.locked:
			continue
		
		item.sell_item()
