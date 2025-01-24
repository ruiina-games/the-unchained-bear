extends AIController
class_name AnimalsDuoController

@onready var phase_01: BTState = %Phase_01
@onready var phase_02: BTState = %Phase_02

func _ready() -> void:
	super()
	hsm.add_transition(phase_01, phase_02, hsm.EVENT_FINISHED)

func get_target_move_position():
	super()
	return target.global_position
