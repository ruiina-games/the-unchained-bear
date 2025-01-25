extends BaseAction
class_name Bite

var tiger: Character

@export var bite_index: int
@export var bite_animation_state_name: String

var animation_sequence_finished: bool = false

func _enter() -> void:
	super()
	animation_sequence_finished = false

	var fighting_style: FightingStyle = unique_actor.character_stats.fighting_style
	var attack_index: int = bite_index

	state_machine.animation_tree.animation_finished.connect(func(anim_name):
		if anim_name.to_lower() == bite_animation_state_name:
			state_machine.switch_state("catch_idle")
			await controller.get_tree().create_timer(1.5).timeout
			state_machine.switch_state("catch_off")
			animation_sequence_finished = true
		)
	state_machine.switch_state(bite_animation_state_name)

func _tick(delta: float) -> Status:
	if animation_sequence_finished:
		return SUCCESS
	return RUNNING
