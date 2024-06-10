class_name Item
extends Button

@export var sprite : AnimatedSprite2D
@export var area : Area2D

@export var shop_max_x = 222
@export var bought_max_x = 373

@export var max_move_distance = 10

var follow_mouse = false
var offset : Vector2

var start_pos : Vector2
var end_pos : Vector2

@export var moving_time = .5
var move_time = .0

var moving = false

var holder : ItemHolder

enum item_state
{
	buyable,
	bought,
	equipt,
}

var state : item_state = item_state.buyable

var item : EnumManager.item_list = EnumManager.item_list.rock_0
var item_string : String
var level : int = 0
@export var max_level : int = EnumManager.max_item_level

var can_level_up:
	get:
		return level < max_level

func _ready():
	item_string = EnumManager.item_list.keys()[item]
	sprite.animation = item_string

func _on_button_down() -> void:
	start_following_mouse()
	start_pos = position

func _on_button_up() -> void:
	stop_following_mouse()

func _on_pressed() -> void:
	if position.distance_to(start_pos) < max_move_distance:
		
		return
		if state == item_state.buyable:
			if !add_to_bought_holder():
				holder.queue_sort()

func start_following_mouse():
	z_index = 1
	follow_mouse = true
	
	offset = get_global_mouse_position() - position

func stop_following_mouse():
	z_index = 0
	follow_mouse = false
	
	var offset_x = position.x + size.x / 2 + holder.global_position.x
	
	match state:
		item_state.buyable:
			if offset_x < shop_max_x:
				holder.queue_sort()
			elif buy_item(offset_x):
				holder.shop_menu.buy_item()
			else:
				holder.queue_sort()
		
		item_state.bought:
			if offset_x < shop_max_x:
				sell_item()
			
			elif offset_x < bought_max_x:
				if !check_overlapping_areas():
					holder.queue_sort()
			
			else:
				if !check_overlapping_areas():
					if !add_to_equipt_holder():
						holder.queue_sort()
		
		item_state.equipt:
			if offset_x < shop_max_x:
				sell_item()
			
			elif offset_x < bought_max_x:
				if !check_overlapping_areas():
					if !add_to_bought_holder():
						holder.queue_sort()
			
			else:
				if !check_overlapping_areas():
					holder.queue_sort()

func reparent_to_next_holder():
	match state:
		item_state.buyable:
			if !holder.can_buy:
				holder.queue_sort()
				return
			
			var buyable_holder = holder as BuyableHolder
			if !buyable_holder:
				return
			
			if !buyable_holder.bought_holder.can_equip:
				return
			
			buyable_holder.shop_menu.buy_item()
			buyable_holder.remove_connections(self)
			var new_holder = buyable_holder.bought_holder
			holder = new_holder
			reparent(new_holder)
			
			state = item_state.bought
			
			holder.add_connections(self)
		
		item_state.bought:
			var bought_holder = holder as BoughtHolder
			if !bought_holder:
				return
			
			if !bought_holder.equipt_holder.can_equip:
				return
			
			bought_holder.remove_connections(self)
			var new_holder = bought_holder.equipt_holder
			holder = new_holder
			reparent(new_holder)
			
			state = item_state.equipt
			
			holder.add_connections(self)

func reparent_to_previous_holder():
	match state:
		item_state.buyable:
			pass
		
		item_state.bought:
			var bought_holder = holder as BoughtHolder
			if !bought_holder:
				return
				
			var new_holder = bought_holder.buyable_holder
			holder = new_holder
			reparent(new_holder)
			
			state = item_state.buyable
			
			queue_free()
		
		item_state.equipt:
			if !holder.can_buy:
				holder.queue_sort()
				return
			
			var equipt_holder = holder as EquiptHolder
			if !equipt_holder:
				return
			
			if !equipt_holder.bought_holder.can_equip:
				return
			
			equipt_holder.remove_connections(self)
			var new_holder = equipt_holder.bought_holder
			holder = new_holder
			reparent(new_holder)
			
			holder.add_connections(self)

func sell_item():
	queue_free()

func check_overlapping_areas() -> bool:
	var areas = area.get_overlapping_areas()
	
	if areas.size() == 1:
		var other_item = areas[0].get_parent() as Item
		
		if !other_item:
			return false
		
		if other_item.item != item:
			return false
		
		if other_item.level != level:
			return false
		
		if !other_item.can_level_up:
			return false
		
		other_item.increase_level()
		
		queue_free()
		
		return true
	return false

func increase_level():
	level += 1

func buy_item(offset_x : float) -> bool:
	if !holder.can_buy:
		return false
	
	if offset_x < bought_max_x:
		if check_overlapping_areas():
			return true
		elif add_to_bought_holder():
			return true
	
	else:
		if check_overlapping_areas():
			return true
		elif add_to_equipt_holder():
			return true
	
	return false

func add_to_bought_holder() -> bool:
	if !holder.bought_holder.can_equip:
		return false
	
	holder.remove_connections(self)
	var new_holder = holder.bought_holder
	holder = new_holder
	reparent(new_holder)
	
	state = item_state.bought
	
	holder.add_connections(self)
	
	return true

func add_to_equipt_holder() -> bool:
	if !holder.equipt_holder.can_equip:
		return false
	
	holder.remove_connections(self)
	var new_holder = holder.equipt_holder
	holder = new_holder
	reparent(new_holder)
	
	state = item_state.equipt
	
	holder.add_connections(self)
	
	return true

func move_from_to(_start_pos : Vector2, _end_pos : Vector2):
	start_pos = _start_pos
	end_pos = _end_pos
	move_time = 0
	moving = true

func _process(delta: float) -> void:
	if follow_mouse:
		position = get_global_mouse_position() - offset
	
	if moving:
		move_time += delta
		var t = move_time / moving_time
		
		t = ease(t, -3)
		
		position = (1.0 - t) * start_pos + t * end_pos
		
		if t >= 1:
			position = end_pos
			moving = false
