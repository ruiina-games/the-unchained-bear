extends StateMachine
class_name AIStateMachine

var current_bb: Blackboard

func _update(delta: float) -> void:
	if !blackboard:
		return
	
func create_state_conditions():
	state_conditions["run"] =  path_to_anim_parameters + "run"
	state_conditions["kick"] =  path_to_anim_parameters + "kick"
	state_conditions["idle"] =  path_to_anim_parameters + "idle"
	state_conditions["attack"] =  path_to_anim_parameters + "attack"
	state_conditions["death"] =  path_to_anim_parameters + "death"
