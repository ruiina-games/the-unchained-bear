extends Controller
class_name PlayerController

@export_category("Actor Movement")
# Змінні для контролю за рухом
@export var speed: float = 800.0
@export var turn_speed: float = 0.5
@export var max_tilt: float = 20.0
@export var acceleration: float = 100.0  # Заміна для delta
@export var deceleration: float = 20.0  # Заміна для delta
@export var jump_force: float = 2400

@export var sec_to_reset_combo: float = 0.4

@onready var idle_state: LimboState = %Idle
@onready var run_state: PlayerState = %Run
@onready var jump_state: LimboState = %Jump
@onready var attack_state: LimboState = %Attack
@onready var death_state: LimboState = %Death
@onready var stunned_state: StunnedPlayer = %Stunned

var tilt_inertia: float = 0.1
var combo_count: int

@onready var control: Control = $CanvasLayer/Control

func kill_actor():
	hsm.dispatch(hsm.DIED)

func init_state_machine() -> void:
	hsm.add_transition(idle_state, run_state, hsm.MOVEMENT_STARTED)
	hsm.add_transition(run_state, idle_state, hsm.MOVEMENT_FINISHED)
	hsm.add_transition(hsm.ANYSTATE, jump_state, hsm.JUMPED)
	hsm.add_transition(jump_state, idle_state, hsm.LANDED)
	hsm.add_transition(run_state, attack_state, hsm.STARTED_ATTACK)
	hsm.add_transition(idle_state, attack_state, hsm.STARTED_ATTACK)
	hsm.add_transition(attack_state, idle_state, hsm.FINISHED_ATTACK)
	hsm.add_transition(hsm.ANYSTATE, death_state, hsm.DIED)
	hsm.add_transition(hsm.ANYSTATE, stunned_state, hsm.STUNNED)
	hsm.add_transition(stunned_state, idle_state, stunned_state.EVENT_FINISHED)

	hsm.initialize(self)
	hsm.set_active(true)
	hsm.change_active_state(idle_state)

func _physics_process(delta: float):
	super(delta)
	
	# Плавне вирівнювання нахилу
	if abs(current_velocity.x) < 10:
		tilt = lerp(tilt, 0.0, 0.2)

	if abs(tilt) < 0.5 and abs(current_velocity.x) < 5:
		tilt = 0.0

func set_stunned(was_stunned: bool):
	super(was_stunned)
	if !was_stunned:
		hsm.allowed_advance_movement = true
		hsm.dispatch(stunned_state.EVENT_FINISHED)
	else:
		hsm.allowed_advance_movement = false
		hsm.dispatch(hsm.STUNNED)


func reset_combo():
	print("Combo has been reset")
	fighting_style.combo_count = 0

func apply_knockback(direction, force):
	hsm.dispatch(hsm.MOVEMENT_FINISHED)
	super(direction, force)
	tilt = clamp(tilt, -max_tilt, max_tilt)
	actor.rotate(deg_to_rad(tilt))
