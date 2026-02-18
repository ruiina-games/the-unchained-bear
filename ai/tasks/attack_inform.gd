# This task is meant to inform the player of the AdI attack.
# It's being called before the delay before the attack.

extends BTDelay
class_name AttackInformDelay

# @export var seconds: float
@export var inform_text: String

var controller: Controller

func _enter() -> void:
	controller = scene_root
	if !controller:
		"Attack Inform ain't gonna work w/o controller"
	controller.attack_notify(inform_text, seconds)
