extends PlayerState
class_name PlayerAttackState

@export var max_combo_count: int = 3  # Максимальна кількість атак у комбо

func _enter() -> void:
	start_attack()

func start_attack() -> void:
	if controller.combo_count >= max_combo_count:
		controller.combo_count = 0  # Скидаємо комбо після досягнення максимуму

	print("Starting attack, combo count: " + str(controller.combo_count))
	animation_tree.set("parameters/MainStateMachine/ATTACK/0/blend_position", controller.combo_count)
	state_machine.switch_state(animation_state_name)  # Вмикаємо атаку

func _on_animation_finished(animation_name: String) -> void:
	print(animation_name)
	controller.combo_count += 1  # Збільшуємо лічильник комбо
	print("Attack finished, jumping to idle, combo count: " + str(controller.combo_count))
	dispatch(state_machine.FINISHED_ATTACK)  # Повертаємося в idle
