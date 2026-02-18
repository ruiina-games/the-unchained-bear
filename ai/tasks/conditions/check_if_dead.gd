extends BaseCondition
class_name CheckIfDead

func _tick(delta: float) -> Status:
	if actor.is_dead:
		return SUCCESS
	else:
		return FAILURE
