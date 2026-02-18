extends PlayerState
class_name PlayerIdleState

func _enter() -> void:
	super()

func _update(delta: float):
	if !character.can_move:
		return
	
	super(delta)
	# Переходимо до стану руху, якщо є ввід від гравця
	var dir = Input.get_axis("move_left", "move_right")
	if dir != 0:
		dispatch(state_machine.MOVEMENT_STARTED)
