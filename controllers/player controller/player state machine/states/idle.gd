extends PlayerState
class_name PlayerIdleState

func _update(delta: float):
	super(delta)
	# Переходимо до стану руху, якщо є ввід від гравця
	var dir = Input.get_axis("move_left", "move_right")
	if dir != 0:
		dispatch(state_machine.MOVEMENT_STARTED)
