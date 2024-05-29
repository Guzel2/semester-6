class_name ItemHolder
extends HFlowContainer

var previous_positions = {}

func _ready() -> void:
	var pre_sort_callable = Callable(self, '_on_pre_sort_children')
	connect('pre_sort_children', pre_sort_callable)
	var sort_callable = Callable(self, '_on_sort_children')
	connect('sort_children', sort_callable)

func _on_pre_sort_children() -> void:
	previous_positions.clear()
	for buyable in get_children():
		buyable = buyable as Buyable
		
		if buyable:
			previous_positions[buyable] = buyable.position

func _on_sort_children():
	for buyable in get_children():
		buyable = buyable as Buyable
		
		buyable.move_from_to(previous_positions[buyable], buyable.position)
