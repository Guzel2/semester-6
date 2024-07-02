class_name EquiptHolder
extends ItemHolder

signal equipt_items(items : Array)

var manual_evolution = true

func show_move_indicator():
	shop_menu.show_sell_indicator()

func hide_move_indicator():
	shop_menu.hide_sell_indicator()

func new_run():
	for child in get_children():
		queue_free()

func start_day():
	emit_signal("equipt_items", get_children())

func end_day():
	if manual_evolution:
		return
	
	var money = 4
	
	for x in 100:
		if money <= 0:
			break
		
		var roll = randi() % 2
		
		#add new item
		if roll == 0:
			if !can_equip:
				continue
			
			var potential_items = EnumManager.item_list.keys().slice(EnumManager.obstacle_count)
			
			for item in get_children():
				item = item as Item
				
				if !item:
					continue
				
				var index = potential_items.find(item.item_string)
				if index != -1:
					potential_items.remove_at(index)
			
			add_item(EnumManager.item_list[potential_items.pick_random()], Item.item_state.equipt)
		
		else:
			if get_child_count() == 0:
				continue
			
			var item_index = randi() % get_child_count()
			var item = get_child(item_index) as Item
			
			if !item.can_level_up:
				continue
			
			if item.level <= money:
				money -= item.level
				money -= 1
				item.level += 1
		
		money -= 1

func _on_main_start_of_day():
	start_day()

func _on_main_end_of_day() -> void:
	end_day()
