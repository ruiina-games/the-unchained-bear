extends PlayerState
class_name KnockedPlayer

func _update(delta: float) -> void:
	if character.velocity == Vector2.ZERO:
		dispatch(state_machine.KNOCKED_FINISHED)
