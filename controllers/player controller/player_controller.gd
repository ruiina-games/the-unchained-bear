extends Node2D
class_name PlayerController

@onready var actor: Bear = %BearNew

@export_category("Actor Movement")
# Змінні для контролю за рухом
@export var speed: float = 800.0
@export var turn_speed: float = 0.5
@export var max_tilt: float = 20.0
@export var acceleration: float = 100.0  # Заміна для delta
@export var deceleration: float = 20.0  # Заміна для delta
@export var gravity: float = 40.0

@onready var hsm: LimboHSM = %LimboHSM
@onready var idle_state: LimboState = %Idle
@onready var run_state: PlayerState = %Run

# Змінні для руху
var current_velocity: Vector2 = Vector2.ZERO
var tilt: float = 0.0
var direction: float = 1.0
var tilt_inertia: float = 0.1

func _ready() -> void:
	_init_state_machine()

func _init_state_machine() -> void:
	# hsm.add_transition(idle_state, run_state, idle_state.EVENT_FINISHED)
	hsm.add_transition(hsm.ANYSTATE, run_state, hsm.MOVEMENT_STARTED)
	hsm.add_transition(run_state, idle_state, hsm.MOVEMENT_FINISHED)
	# hsm.add_transition(move_state, idle_state, move_state.EVENT_FINISHED)

	hsm.initialize(self)
	hsm.set_active(true)
	hsm.change_active_state(idle_state)

func _physics_process(delta: float):
	current_velocity.y += gravity
	# Плавне вирівнювання нахилу
	if abs(current_velocity.x) < 10:
		tilt = lerp(tilt, 0.0, 0.2)

	if abs(tilt) < 0.5 and abs(current_velocity.x) < 5:
		tilt = 0.0
