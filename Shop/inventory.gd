extends Control


func _unhandled_input(event):
	if event.is_action_pressed("inv"):
		visible = !visible
