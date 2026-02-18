extends AIController
class_name AnimalsDuoController

@onready var phase_01: BTState = %Phase_01
@onready var phase_02: BTState = %Phase_02
@onready var phase_03: BTState = %Phase_03

@export var tiger: Character

@onready var tiger_hsm: LimboHSM = %TigerHSM

@onready var phase_01_tiger: BTState = $TigerHSM/Phase_01

func _ready() -> void:
	super()
	hsm.add_transition(phase_01, phase_02, hsm.EVENT_FINISHED)
	hsm.add_transition(phase_02, phase_03, hsm.EVENT_FINISHED)
	
	tiger_hsm.initialize(self)
	tiger_hsm.set_active(true)
	tiger_hsm.change_active_state(phase_01_tiger)

func get_tiger_hsm():
	return tiger_hsm

func get_target_move_position():
	super()
	return target.global_position
