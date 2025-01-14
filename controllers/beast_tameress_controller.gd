extends Controller
class_name BeastTameressController

@export var max_consecutive_hits_can_take: int = 4
@export var animation_tree: AnimationTree

@onready var consecutive_hits_reset_timer: Timer = %"Consecutive Hits Reset Timer"

@onready var phase_01: BTState = $LimboHSM/Phase_01

var blackboard: Blackboard
var consecutive_hits: int:
	set(new_value):
		var active_bb: Blackboard = hsm.get_active_state().blackboard
		if active_bb.has_var("consecutive_hits"):
			consecutive_hits = new_value
			active_bb.set_var("consecutive_hits", consecutive_hits)
			print(active_bb.get_var("consecutive_hits"))
			
			if active_bb.get_var("consecutive_hits") > max_consecutive_hits_can_take:
				consecutive_hits = 0
			else:
				consecutive_hits_reset_timer.start()

func _ready() -> void:
	consecutive_hits_reset_timer.timeout.connect(_on_consecutive_hits_reset_timer_timeout)
	
	hsm.initialize(self)
	hsm.set_active(true)
	hsm.change_active_state(phase_01)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		consecutive_hits += 1

func _on_consecutive_hits_reset_timer_timeout():
	consecutive_hits = 0
	print("boss now can get even more pucnhes!!!")
