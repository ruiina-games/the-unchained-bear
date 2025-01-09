extends LimboHSM
class_name PlayerStateMachine

@export var character: CharacterBody2D
@export var controller: PlayerController
@export var state_conditions: Dictionary = {}
@export var path_to_anim_parameters: String = "parameters/MainStateMachine/conditions/"
@export var debug_label: Label

var MOVEMENT_STARTED: StringName = "movement_started"
var MOVEMENT_FINISHED: StringName = "movement_finished"
var JUMPED: StringName = "jumped"
var LANDED: StringName = "landed"
# var GOT_HIT: StringName = "got_hit"
# var CHARACTER_DIED: StringName = "character_died"

var animation_tree: AnimationTree
var current_state: String = "Idle"

func _ready() -> void:
	init_state_machine()
	create_state_conditions()

func init_state_machine():
	if character.get_anim_tree():
		animation_tree = character.get_anim_tree()
		
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
	
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		dispatch(JUMPED)
	
# Ця функція сетитів всі умови в animation_tree на false, а умову анімаціїї,
# яку потрібно зараз програвати на true
func switch_state(target_state: String):
	for state in state_conditions.keys():
		# Отримуємо шлях до параметра анімації
		var condition_path = state_conditions[state]
		# Якщо це цільовий стан, активуємо його
		if state == target_state:
			animation_tree.set(condition_path, true)
		else:
			animation_tree.set(condition_path, false)
	
	current_state = target_state
