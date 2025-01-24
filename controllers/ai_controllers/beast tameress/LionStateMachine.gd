extends StateMachine
class_name LionStateMachine

func create_state_conditions():
	state_conditions["run"] =  path_to_anim_parameters + "run"
	state_conditions["idle"] =  path_to_anim_parameters + "idle"
	state_conditions["attack"] =  path_to_anim_parameters + "attack"
	state_conditions["roar"] =  path_to_anim_parameters + "roar"
