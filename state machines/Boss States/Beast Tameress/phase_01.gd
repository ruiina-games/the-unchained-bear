extends AIState

func _update(delta: float) -> void:
	blackboard.set_var("is_dead", owner.actor.is_dead)
	blackboard.set_var("can_move", owner.actor.can_move)
