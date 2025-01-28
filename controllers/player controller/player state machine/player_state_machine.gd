extends StateMachine
class_name PlayerStateMachine

@export var debug_label: Label

@export var allowed_advance_movement: bool = false

var MOVEMENT_STARTED: StringName = "movement_started"
var MOVEMENT_FINISHED: StringName = "movement_finished"
var JUMPED: StringName = "jumped"
var LANDED: StringName = "landed"
var STARTED_ATTACK: StringName = "started_attack"
var FINISHED_ATTACK: StringName = "finished_attack"
var DIED: StringName = "death"
var STUNNED: StringName = "stunned"
var UNSTUCK: StringName = "unstuck"

func init_state_machine():
	super()
		
	for state in get_children():
		if state is PlayerState:
			state.character = character
			state.animation_tree = animation_tree
			state.controller = controller
			state.state_machine = self
			state.initialize_state()

func create_state_conditions():
	state_conditions["attack"] =  path_to_anim_parameters + "attack"
	state_conditions["bend"] =  path_to_anim_parameters + "bend"
	state_conditions["death"] =  path_to_anim_parameters + "death"
	state_conditions["idle"] = path_to_anim_parameters + "idle"
	state_conditions["jump"] =  path_to_anim_parameters + "jump"
	state_conditions["run"] =  path_to_anim_parameters + "run"
	state_conditions["land"] =  path_to_anim_parameters + "land"
	state_conditions["fly"] =  path_to_anim_parameters + "fly"
	state_conditions["death"] = path_to_anim_parameters + "death"
	
func _unhandled_input(event: InputEvent) -> void:
	if allowed_advance_movement:
		if event.is_action_pressed("jump"):
			dispatch(JUMPED)
		if event.is_action_pressed("attack"):
			dispatch(STARTED_ATTACK)

	if event.is_action_pressed("unstuck"):
		controller.unstuck()

	if !character.can_move:
		return
		
	if get_active_state():
		get_active_state().state_input()
	
# Ця функція сетитів всі умови в animation_tree на false, а умову анімаціїї,
# яку потрібно зараз програвати на true
func switch_state(target_state: String):
	super(target_state)
	
	current_state = target_state
	var attack_animations_path = "parameters/MainStateMachine/" + current_state.to_upper() + "/blend_position"
	animation_tree.set(attack_animations_path, controller.fighting_style.id)
