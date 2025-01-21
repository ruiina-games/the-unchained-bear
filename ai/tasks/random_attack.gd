extends BaseAction
class_name RandomAttack

@export var available_attacks: int = 3

func _enter() -> void:
	super()
	
	if !controller.actor.can_move:
		return
	
	var fighting_style: FightingStyle = controller.actor.character_stats.fighting_style

	available_attacks = fighting_style.max_combo_count
	fighting_style.combo_count = randi_range(0, available_attacks - 1)
	var attack_index: int = fighting_style.combo_count
	
	state_machine.switch_animation_in_blendspace("ATTACK", attack_index)
	state_machine.switch_state("attack")
