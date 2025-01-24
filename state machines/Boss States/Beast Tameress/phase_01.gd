extends AIState

@export var hp_percentage_threshold: float

func _update(delta: float) -> void:
	if !is_active():
		return
	
	var character: Character = owner.actor
	var character_stats: CharacterStats = character.character_stats
	var current_hp: int = character_stats.current_health
	var max_hp: int = character_stats.max_health
	
	if current_hp <= max_hp * hp_percentage_threshold:
		dispatch(EVENT_FINISHED)
	
	blackboard.set_var("is_dead", owner.actor.is_dead)
	blackboard.set_var("can_move", owner.actor.can_move)
