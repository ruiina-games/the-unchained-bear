extends PlayerState
class_name PlayerAttackState

var combo_timer: Timer

func initialize_state():
	super()
	combo_timer = Timer.new()
	combo_timer.wait_time = 1
	combo_timer.one_shot = true
	combo_timer.timeout.connect(_on_combo_timer_timeout)
	add_child(combo_timer)

func _enter() -> void:
	start_attack()
	
	if !combo_timer.is_stopped():
		combo_timer.stop()

func start_attack() -> void:
	if controller.combo_count >= controller.max_combo_count:
		controller.combo_count = 0  # Скидаємо комбо після досягнення максимуму
	
	print("Combo count: " + str(controller.combo_count))
	animation_tree.set("parameters/MainStateMachine/ATTACK/0/blend_position", controller.combo_count)
	controller.combo_count += 1
	state_machine.switch_state(animation_state_name)  # Вмикаємо атаку

func _on_animation_finished(animation_name: String) -> void:
	dispatch(state_machine.FINISHED_ATTACK)
	combo_timer.start()

func _on_combo_timer_timeout():
	controller.reset_combo()
