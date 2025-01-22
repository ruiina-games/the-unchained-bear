extends LimboState
class_name PlayerState

@export var animation_state_name :String

var animation_tree: AnimationTree
var state_machine :PlayerStateMachine
var character :Character
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
	if !character.can_move:
		return
	handle_movement()

func state_input():
	pass

func initialize_state():
	if !animation_tree:
		return
		
	if get_parent() is PlayerStateMachine:
		state_machine = get_parent()
		
	if !state_machine:
		return
		
	playback = animation_tree["parameters/MainStateMachine/playback"]
	animation_tree.animation_finished.connect(_on_animation_finished)

func handle_movement():
	if controller.current_velocity.x > 0:
		controller.current_velocity.x -= controller.deceleration
		controller.current_velocity.x = max(controller.current_velocity.x, 0)
	elif controller.current_velocity.x < 0:
		controller.current_velocity.x += controller.deceleration
		controller.current_velocity.x = min(controller.current_velocity.x, 0)
	
	# Збереження поточного масштабу та ротації
	var original_scale = character.scale
	var original_rotation = character.rotation

	character.velocity = controller.current_velocity
	
	# Виклик move_and_slide()
	character.move_and_slide()

	# Відновлення масштабу та ротації
	character.reset_scale(original_scale, original_rotation)
	controller.tilt = clamp(controller.tilt, -controller.max_tilt, controller.max_tilt)
	controller.actor.rotate(deg_to_rad(controller.tilt))

func _on_animation_finished(anim_name: String):
	pass
