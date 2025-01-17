# Base Class for working with Controllers.

extends BTCondition
class_name BaseCondition

var controller: Controller

func _enter() -> void:
	if scene_root is Controller:
		controller = scene_root
	else:
		print("No controller is available. BaseCondition won't work")
		return
