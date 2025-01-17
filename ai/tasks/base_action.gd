extends BTAction
class_name BaseAction

var controller: Controller
var state_machine: StateMachine

func _enter() -> void:
	if scene_root is Controller:
		controller = scene_root
		state_machine = controller.get_hsm()
	else:
		return
	
	if !state_machine:
		print("i can't get fckng hsm")
		return

func _tick(delta: float) -> Status:
	if !state_machine:
		return FAILURE
	else:
		return SUCCESS
