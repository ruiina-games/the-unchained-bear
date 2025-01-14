extends Node2D
class_name Controller

@export var actor: Character
@export var hsm: LimboHSM

# Змінні для руху
var current_velocity: Vector2 = Vector2.ZERO
var tilt: float = 0.0
var direction: float = 1.0
var gravity: float = 75.0

func _ready() -> void:
	_init_state_machine()

func _init_state_machine() -> void:
	pass

func _physics_process(delta: float):
	if !actor.is_on_floor():
		current_velocity.y += gravity

func get_hsm():
	if hsm:
		return hsm
	else:
		print("error")
		return
