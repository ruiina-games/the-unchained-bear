extends StateMachine
class_name TigerStateMachine

func create_state_conditions():
	state_conditions["catch_bite"] =  path_to_anim_parameters + "catch_bite"
	state_conditions["catch_idle"] =  path_to_anim_parameters + "catch_idle"
	state_conditions["catch_off"] =  path_to_anim_parameters + "catch_off"
	state_conditions["idle"] =  path_to_anim_parameters + "idle"
	state_conditions["death"] =  path_to_anim_parameters + "death"
	state_conditions["run"] =  path_to_anim_parameters + "run"
	state_conditions["jump"] =  path_to_anim_parameters + "jump"
	state_conditions["fly_up"] =  path_to_anim_parameters + "fly_up"
	state_conditions["fly_down"] =  path_to_anim_parameters + "fly_down"
	state_conditions["fly_catch"] =  path_to_anim_parameters + "fly_catch"
	state_conditions["fly_land"] =  path_to_anim_parameters + "fly_land"
