extends PlayerState
class_name StunnedPlayer

func _enter() -> void:
	state_machine.allowed_advance_movement = false
	state_machine.switch_state("idle")

func _exit() -> void:
	state_machine.allowed_advance_movement = true
