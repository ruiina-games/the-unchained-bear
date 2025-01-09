extends LimboState
class_name PlayerState

@export var animation_state_name :String

var animation_tree: AnimationTree
var state_machine :PlayerStateMachine
var character :CharacterBody2D
var controller: PlayerController
var playback :AnimationNodeStateMachinePlayback

# var START_ATTACK :StringName = "start_attack"
# var START_SHOOT :StringName = "start_shoot"

func _enter() -> void:
	if state_machine:
		state_machine.switch_state(animation_state_name)
		if state_machine.debug_label:
			state_machine.debug_label.text = animation_state_name

func _update(delta: float) -> void:
	handle_movement()

func initialize_state():
	if !animation_tree:
		return
		
	if get_parent() is PlayerStateMachine:
		state_machine = get_parent()
		
	if !state_machine:
		return
		
	playback = animation_tree["parameters/MainStateMachine/playback"]

func handle_movement():
	# Збереження поточного масштабу та ротації
	var original_scale = character.scale
	var original_rotation = character.rotation

	character.velocity = controller.current_velocity
	
	# Виклик move_and_slide()
	character.move_and_slide()

	# Відновлення масштабу та ротації
	character.scale = original_scale
	character.rotation = original_rotation
	
	controller.tilt = clamp(controller.tilt, -controller.max_tilt, controller.max_tilt)
	controller.actor.rotation = 0  # Скидаємо будь-який попередній нахил
	controller.actor.rotate(deg_to_rad(controller.tilt))
