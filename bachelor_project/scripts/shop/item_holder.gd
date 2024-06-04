class_name ItemHolder
extends HFlowContainer

@export var item_scene : PackedScene

@export var shop_menu : ShopMenu

var previous_positions = {}

var can_buy:
	get:
		return shop_menu.money > 0

func _ready() -> void:
	var pre_sort_callable = Callable(self, '_on_pre_sort_children')
	connect('pre_sort_children', pre_sort_callable)
	var sort_callable = Callable(self, '_on_sort_children')
	connect('sort_children', sort_callable)

func _on_pre_sort_children() -> void:
	previous_positions.clear()
	for buyable in get_children():
		buyable = buyable as Item
		
		if buyable:
			previous_positions[buyable] = buyable.position

func _on_sort_children():
	for buyable in get_children():
		buyable = buyable as Item
		
		buyable.move_from_to(previous_positions[buyable], buyable.position)

func add_item(item, state : Item.item_state):
	var scene = item_scene.instantiate() as Item
	scene.holder = self
	scene.item = item
	scene.state = state
	
	add_child(scene)
	
	add_connections(scene)

func add_connections(item : Item):
	var show_callable = Callable(self, "show_move_indicator")
	item.connect('button_down', show_callable)
	var hide_callable = Callable(self, "hide_move_indicator")
	item.connect('button_up', hide_callable)

func remove_connections(item : Item):
	var show_callable = Callable(self, "show_move_indicator")
	item.disconnect('button_down', show_callable)
	var hide_callable = Callable(self, "hide_move_indicator")
	item.disconnect('button_up', hide_callable)

func show_move_indicator():
	pass

func hide_move_indicator():
	pass

