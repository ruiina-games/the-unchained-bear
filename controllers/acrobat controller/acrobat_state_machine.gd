extends AIStateMachine

func create_state_conditions():
	super()
	state_conditions["melee_attack"] =  path_to_anim_parameters + "melee_attack"
	state_conditions["charge"] =  path_to_anim_parameters + "charge"
	
