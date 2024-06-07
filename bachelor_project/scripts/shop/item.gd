class_name Item
extends Button

@export var sprite : AnimatedSprite2D

@export var max_move_distance = 10

var follow_mouse = false
var offset : Vector2

var start_pos : Vector2
var end_pos : Vector2

@export var moving_time = .5
var move_time = .0

var moving = false

var holder : Container


enum item_state
{
	buyable,
	bought,
	equipt,
}

var state : item_state = item_state.buyable

var item : EnumManager.item_list = EnumManager.item_list.rock_0
var item_string : String

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
		reparent_to_next_holder()

func start_following_mouse():
	z_index = 1
	follow_mouse = true
	
	offset = get_global_mouse_position() - position

func stop_following_mouse():
	z_index = 0
	follow_mouse = false
	
	if position.x > holder.size.x:
		reparent_to_next_holder()
	elif position.x < 0:
		print(state)
		reparent_to_previous_holder()
	else:
		holder.queue_sort()

func reparent_to_next_holder():
	match state:
		item_state.buyable:
			if !holder.can_buy:
				holder.queue_sort()
				return
			
			var buyable_holder = holder as BuyableHolder
			if buyable_holder:
				buyable_holder.shop_menu.buy_item()
				buyable_holder.remove_connections(self)
				var new_holder = buyable_holder.bought_holder
				holder = new_holder
				reparent(new_holder)
				
				state = item_state.bought
				
				holder.add_connections(self)
				
		
		item_state.bought:
			pass

func reparent_to_previous_holder():
	match state:
		item_state.buyable:
			pass
		
		item_state.bought:
			var bought_holder = holder as BoughtHolder
			if bought_holder:
				var new_holder = bought_holder.buyable_holder
				holder = new_holder
				reparent(new_holder)
				
				state = item_state.buyable
				
				queue_free()

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


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("middle_mouse_button"):
		print(position)
		print(get_global_mouse_position())
