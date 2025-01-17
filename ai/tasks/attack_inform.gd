# This task is meant to inform the player of the AI attack.
# It's being called before the delay before the attack.

extends BaseAction

func _tick(delta: float) -> Status:
	if !controller:
		return FAILURE
	controller.attack_notify()
	return SUCCESS
