class_name BoughtHolder
extends ItemHolder

signal remaining_obstacles(items : Array)

var use_obstacles = true
var obstacle_buyable = true

func show_move_indicator():
	shop_menu.show_sell_indicator()

func hide_move_indicator():
	shop_menu.hide_sell_indicator()

func new_run():
	for child in get_children():
		queue_free()

func start_day():
	var obstacles = []
	for item in get_children():
		item = item as Item
		if item.item < EnumManager.obstacle_count:
			obstacles.append(item.item)
			
			item.queue_free()
	
	emit_signal("remaining_obstacles", obstacles)

func end_day():
	if !use_obstacles:
		return
	
	if obstacle_buyable:
		return
	
	if !can_equip:
		return
	
	var potential_items = []
	
	for x in EnumManager.obstacle_count:
		potential_items.append(EnumManager.item_list.keys()[x])
	
	add_item(potential_items.pick_random(), Item.item_state.bought)

func _on_main_start_of_day():
	start_day()

func _on_obstacle_ui_holder_remaining_obstacles(items):
	for item in items:
		add_item(item, Item.item_state.bought)
	
	call_deferred("end_day")

func _on_sell_all_pressed() -> void:
	for item in get_children():
		item = item as Item
		
		if !item:
			continue
		
		if item.locked:
			continue
		
		item.sell_item()

