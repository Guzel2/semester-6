class_name BuyableHolder
extends ItemHolder

@export var buyable_scene : PackedScene

@export var bought_holder : ItemHolder

func _on_start_next_day_pressed() -> void:
	var buyable = buyable_scene.instantiate() as Item
	add_child(buyable)
	buyable.holder = self
