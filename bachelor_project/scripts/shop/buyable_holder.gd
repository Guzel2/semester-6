class_name BuyableHolder
extends ItemHolder

@export var reroll_move_time = .3

var potential_items = []
var potential_obstacles = []

signal no_children_left

var use_obstacles = true
var obstacle_buyable = true
var manual_evolution = true

func _ready():
	set_potential_items()
	
	super._ready()

func set_potential_items():
	potential_items.clear()
	potential_obstacles.clear()
	
	for x in EnumManager.item_list.size():
		if x < EnumManager.obstacle_count:
			if !obstacle_buyable:
				continue
		else:
			if !manual_evolution:
				continue
		
		potential_items.append(EnumManager.item_list.keys()[x])

func show_move_indicator():
	shop_menu.show_buy_indicator()

func hide_move_indicator():
	shop_menu.hide_buy_indicator()

func reroll_shop():
	if !can_buy:
		return
	
	shop_menu.money -= 1
	
	clear_shop()
	
	call_deferred("refill_shop")

func clear_shop():
	for item in get_children():
		item = item as Item
		
		if !item.locked:
			item.queue_free()
			
			remove_child(item)

func refill_shop():
	if !manual_evolution and !obstacle_buyable:
		ant_manager.ant_count += 2
		shop_menu.money = 0
		return
	
	set_potential_items()
	
	var old_child_count = get_child_count()
	
	var new_child_count = max_item_count - old_child_count
	
	var original_move_time = -1
	
	if get_child_count() > 0:
		var wait_for_other = false
		
		var first_item = get_child(0) as Item
		
		original_move_time = first_item.moving_time
		
		for item in get_children():
			item = item as Item
			
			item.moving_time = reroll_move_time
			
			if item.position != item.start_pos:
				wait_for_other = true
		
		if wait_for_other:
			await first_item.stopped_moving
	
	for x in new_child_count:
		add_item(EnumManager.item_list[potential_items.pick_random()], Item.item_state.buyable)
	
	if original_move_time > 0:
		for item in get_children():
			item = item as Item
			
			item.moving_time = original_move_time
	
	#call_deferred("late_sort")

func _on_main_end_of_day():
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
