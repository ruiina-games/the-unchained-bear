extends BTAction
class_name BaseAction

@export var bb_state_machine: BBNode

var controller: Controller
var state_machine: StateMachine
var unique_actor: Character

func _enter() -> void:
	if scene_root is Controller:
		controller = scene_root
		state_machine = controller.get_hsm()
	
	if !state_machine:
		print("i can't get fckng hsm")
		return
		
	if bb_state_machine and bb_state_machine.saved_value:
		state_machine = controller.get_node(bb_state_machine.saved_value)
		unique_actor = state_machine.character

func _tick(delta: float) -> Status:
	if !state_machine:
		return FAILURE
	else:
		return SUCCESS
