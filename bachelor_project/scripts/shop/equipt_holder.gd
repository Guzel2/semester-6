class_name EquiptHolder
extends ItemHolder

signal equipt_items(items : Array)

func show_move_indicator():
	shop_menu.show_sell_indicator()

func hide_move_indicator():
	shop_menu.hide_sell_indicator()

func new_run():
	for child in get_children():
		queue_free()

func start_day():
	emit_signal("equipt_items", get_children())

func _on_main_start_of_day():
	start_day()

