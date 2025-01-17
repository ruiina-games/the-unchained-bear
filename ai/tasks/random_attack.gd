extends BaseAction
class_name RandomAttack

@export var available_attacks: int = 3

func _enter() -> void:
	super()
	
	state_machine.switch_animation_in_blendspace("ATTACK", randi_range(0, available_attacks - 1))
	state_machine.switch_state("attack")
