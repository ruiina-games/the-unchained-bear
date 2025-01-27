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

	# Перевірка, чи target перед нами
	var target = controller.target
	if target and _is_target_in_correct_direction(target):
		state_machine.animation_tree.animation_finished.connect(func(anim_name):
			if anim_name.to_lower() == bite_animation_state_name:
				var direction_to_target = unique_actor.global_position.direction_to(target.global_position)
				
				if direction_to_target.x < 0:
					target.global_position.x = unique_actor.global_position.x - 300
				else:
					target.global_position.x = unique_actor.global_position.x + 300
				
				state_machine.switch_state("catch_idle")
				await controller.get_tree().create_timer(1.5).timeout
				state_machine.switch_state("catch_off")
				animation_sequence_finished = true
			)
		state_machine.switch_state(bite_animation_state_name)
	else:
		animation_sequence_finished = true  # Завершуємо стан, якщо target не перед нами

func _tick(delta: float) -> Status:
	if animation_sequence_finished:
		return SUCCESS
	return RUNNING

func _is_target_in_correct_direction(target: Node2D) -> bool:
	# Визначаємо напрямок до target
	var direction_to_target = unique_actor.global_position.direction_to(target.global_position)

	# Якщо actor дивиться праворуч (transform.x.x == 1), target має бути праворуч
	if unique_actor.transform.x.x == 1 and direction_to_target.x < 0:
		return true
	# Якщо actor дивиться ліворуч (transform.x.x == -1), target має бути ліворуч
	elif unique_actor.transform.x.x == -1 and direction_to_target.x > 0:
		return true

	return false
