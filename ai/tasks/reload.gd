extends BaseAction
class_name ReloadAction

@export var has_to_reload: bool = true

func _enter() -> void:
	super()
	state_machine.switch_state("idle")
			
	if has_to_reload:
		state_machine.fire_blend_animation("RELOAD")
