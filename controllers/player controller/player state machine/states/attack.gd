extends PlayerState
class_name PlayerAttackState

var fighting_style: FightingStyle
var attack_animations_path: String
var combo_timer: Timer

func initialize_state():
	super()
	combo_timer = Timer.new()
	combo_timer.wait_time = 1
	combo_timer.one_shot = true
	combo_timer.timeout.connect(_on_combo_timer_timeout)
	add_child(combo_timer)

func _enter() -> void:
	fighting_style = controller.fighting_style
	
	if !fighting_style:
		return
	
	if state_machine.debug_label:
			state_machine.debug_label.text = animation_state_name
			
	start_attack()
	
	if !combo_timer.is_stopped():
		combo_timer.stop()

func start_attack() -> void:
	if fighting_style.combo_count >= fighting_style.max_combo_count:
		fighting_style.combo_count = 0  # Скидаємо комбо після досягнення максимуму
	
	# print("Combo count: " + str(fighting_style.combo_count))
	
	attack_animations_path = "parameters/MainStateMachine/ATTACK/" + str(fighting_style.id) + "/blend_position"
	animation_tree.set(attack_animations_path, fighting_style.combo_count)
	state_machine.switch_state(animation_state_name)  # Вмикаємо атаку

func _on_animation_finished(animation_name: String) -> void:
	dispatch(state_machine.FINISHED_ATTACK)
	character.character_stats.fighting_style.combo_count += 1
	combo_timer.start()

func _on_combo_timer_timeout():
	controller.reset_combo()
