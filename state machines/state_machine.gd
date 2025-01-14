extends LimboHSM
class_name StateMachine

@export var character: CharacterBody2D
@export var controller: Controller
@export var state_conditions: Dictionary = {}
@export var path_to_main_state_machine: String = "parameters/MainStateMachine/"
@export var path_to_anim_parameters: String = "parameters/MainStateMachine/conditions/"

var animation_tree: AnimationTree
var current_state: String = "Idle"

func _ready() -> void:
	init_state_machine()
	create_state_conditions()

func init_state_machine():
	if character.get_anim_tree():
		animation_tree = character.get_anim_tree()

func create_state_conditions():
	pass
	
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
	
func switch_animation_in_blendspace(animation_state_name: String, blend_space_position: int):
	var path_to_blendspace: String = path_to_main_state_machine + animation_state_name.to_upper() + "/blend_position"
	print(blend_space_position)
	animation_tree.set(path_to_blendspace, blend_space_position)
