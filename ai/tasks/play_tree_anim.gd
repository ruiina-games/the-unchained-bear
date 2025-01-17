extends BaseAction
class_name PlayTreeAnimation

@export var animation_condition: StringName = "run"

func _generate_name() -> String:
	return "Play Animation Tree State"

func _enter() -> void:
	super()
	state_machine.switch_state(animation_condition)
	
func _tick(delta: float) -> Status:
	if !state_machine:
		return FAILURE
	else:
		return SUCCESS

func _exit() -> void:
	pass
