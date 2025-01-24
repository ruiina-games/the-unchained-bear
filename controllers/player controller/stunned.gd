extends PlayerState
class_name StunnedPlayer

func _enter() -> void:
	state_machine.switch_state("idle")

func _unhandled_input(event: InputEvent) -> void:
	pass
