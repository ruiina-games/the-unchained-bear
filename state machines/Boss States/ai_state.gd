extends BTState
class_name AIState

var character: Character 
var controller: Controller

func _enter() -> void:
	controller = owner
	character = owner.actor
