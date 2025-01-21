extends AIState

func _update(delta: float) -> void:
	blackboard.set_var("can_move", owner.actor.can_move)
