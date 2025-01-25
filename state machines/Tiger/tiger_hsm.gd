extends StateMachine
class_name TigerStateMachine

func create_state_conditions():
	state_conditions["catch_bite"] =  path_to_anim_parameters + "catch_bite"
	state_conditions["catch_idle"] =  path_to_anim_parameters + "catch_idle"
	state_conditions["catch_off"] =  path_to_anim_parameters + "catch_off"
	state_conditions["idle"] =  path_to_anim_parameters + "idle"
	state_conditions["death"] =  path_to_anim_parameters + "death"
