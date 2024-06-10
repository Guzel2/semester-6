class_name EquiptHolder
extends ItemHolder

signal equipt_items(items : Array)

func show_move_indicator():
	shop_menu.show_sell_indicator()

func hide_move_indicator():
	shop_menu.hide_sell_indicator()

func start_day():
	emit_signal("equipt_items", get_children())

func end_day():
	pass

func _on_main_start_off_day():
	start_day()

func _on_main_end_off_day():
	end_day()

