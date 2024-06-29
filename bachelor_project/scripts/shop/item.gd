class_name Item
extends Button

@export var sprite : AnimatedSprite2D
@export var lock_sprite : Sprite2D
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

var moving = false:
	get:
		return moving
	set(value):
		moving = value
		
		if !moving:
			emit_signal("stopped_moving")

var holder : ItemHolder

enum item_state
{
	buyable,
	bought,
	equipt,
}

var state : item_state = item_state.buyable

@export var level_display : NumberDisplay
var item : EnumManager.item_list = EnumManager.item_list.rock_0
var item_string : String
var level : int = 0:
	set(value):
		level = value
		level_display.update_number(level + 1)
var max_level : int = EnumManager.max_item_level

var can_level_up:
	get:
		return level < max_level

var locked = false

signal stopped_moving

var tooltips = {
	EnumManager.item_list.rock_0 : "An oval shaped rock for blocking paths.",
	EnumManager.item_list.rock_1 : "A sharp rock for blocking paths.",
	EnumManager.item_list.rock_2 : "A sharp rock for blocking paths.",
	EnumManager.item_list.stick_0 : "A small twig for blocking paths.",
	EnumManager.item_list.stick_1 : "A stick for blocking paths.",
	
	EnumManager.item_list.antenna : "Antenna\n
									Level 1: Increase Scent detection by 2 Positions.\n(Normal is 5, Maximum is 27)\n
									Level 2: Increase Scent detection by 4 Positions.\n
									Level 3: Increase Scent detection by 6 Positions.\n
									Level 4: Increase Scent detection by 8 Positions.\n
									Level 5: Increase Scent detection by 10 Positions.\n",
	EnumManager.item_list.eyes : "Eyes\n
									Level 1: Increase Scent detection by 2 Positions.\n(Normal is 6, Maximum is 30)\n
									Level 2: Increase Scent detection by 4 Positions.\n
									Level 3: Increase Scent detection by 6 Positions.\n
									Level 4: Increase Scent detection by 8 Positions.\n
									Level 5: Increase Scent detection by 10 Positions.\n",
	EnumManager.item_list.scent_gland : "Scent Gland\n
									Level 1: Decrease Scent scan/deploy cooldown by 5%.\n
									Level 2: Decrease Scent scan/deploy cooldown by 10%.\n
									Level 3: Decrease Scent scan/deploy cooldown by 15%.\n
									Level 4: Decrease Scent scan/deploy cooldown by 20%.\n
									Level 5: Decrease Scent scan/deploy cooldown by 25%.\n",
	EnumManager.item_list.gaster : "Scent Gaster\n
									Level 1: Increase maximum food storage by 10%.\n
									Level 2: Increase maximum food storage by 20%.\n
									Level 3: Increase maximum food storage by 30%.\n
									Level 4: Increase maximum food storage by 40%.\n
									Level 5: Increase maximum food storage by 50%.\n",
	EnumManager.item_list.mandibles : "Mandibles\n
									Level 1: Increase harvesting speed by 5%.\n
									Level 2: Increase harvesting speed by 10%.\n
									Level 3: Increase harvesting speed by 15%.\n
									Level 4: Increase harvesting speed by 20%.\n
									Level 5: Increase harvesting speed by 25%.\n",
	EnumManager.item_list.legs : "Stronger Legs\n
									Level 1: Increase move speed by 10%.\n
									Level 2: Increase move speed by 20%.\n
									Level 3: Increase move speed by 30%.\n
									Level 4: Increase move speed by 40%.\n
									Level 5: Increase move speed by 50%.\n",
}

func _ready():
	item_string = EnumManager.item_list.keys()[item]
	sprite.animation = item_string
	
	tooltip_text = tooltips[item]

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

func sell_item():
	holder.ant_manager.ant_count += 1
	
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
		
		if item < EnumManager.obstacle_count or other_item.item < EnumManager.obstacle_count:
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
		if state == item_state.bought:
			return false
		
		return add_to_bought_holder()
	
	if item < EnumManager.obstacle_count:
		if state == item_state.bought:
			return false
		
		return add_to_bought_holder()
	
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

func _on_gui_input(event):
	if event is InputEventMouseButton and event.pressed:
		event = event as InputEventMouseButton
		
		if event.button_index == MOUSE_BUTTON_RIGHT:
			lock_item(!locked)

func lock_item(lock : bool):
	print(level)
	locked = lock
	
	lock_sprite.visible = locked
	
	disabled = lock
