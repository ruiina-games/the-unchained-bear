extends BaseAction
class_name SpecificAttack

@export var attack_index: int = 0
@export var animation_name: String

var animation_finished: bool

func _enter() -> void:
	super()
	animation_finished = false
	
	if !controller.actor.can_move:
		return
	
	var fighting_style: FightingStyle = controller.actor.character_stats.fighting_style

	var available_attacks = fighting_style.max_combo_count
	if attack_index > available_attacks - 1:
		return
	
	fighting_style.combo_count = attack_index
	
	state_machine.switch_animation_in_blendspace("ATTACK", attack_index)
	state_machine.switch_state("attack")
	
	state_machine.animation_tree.animation_finished.connect(func(anim_name):
		# if anim_name.to_lower() == animation_name:
		animation_finished = true
		)

func _tick(delta: float) -> Status:
	if animation_finished:
		return SUCCESS
	else:
		return RUNNING
