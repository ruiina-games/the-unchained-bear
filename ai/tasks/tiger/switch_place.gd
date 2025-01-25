extends BaseAction

var already_switched = false
var distance_x = 300  # Дистанція, на яку актор повинен зникати за межі екрана
var speed = 100  # Швидкість переміщення актора
var target_position = Vector2()  # Цільова позиція актора
var moving_out = true  # Прапорець для контролю напрямку руху
var anim_tree: AnimationTree 

func _enter() -> void:
	super()
	unique_actor = controller.tiger
	if unique_actor:
		target_position = unique_actor.global_position + Vector2(distance_x, 0) * (1 if !already_switched else -1)
	anim_tree = state_machine.animation_tree
	state_machine.switch_state("run")

func _tick(delta: float) -> Status:
	if not unique_actor:
		return FAILURE

	# Переміщення до цільової позиції
	var direction = (target_position - unique_actor.global_position).normalized()
	unique_actor.global_position += direction * speed * delta

	# Перевірка, чи досягнуто цільову позицію
	if unique_actor.global_position.distance_to(target_position) < 1:
		if moving_out:
			# Зміна напрямку для повернення з іншого боку
			already_switched = !already_switched
			unique_actor.adjust_scale_for_direction(Vector2(1, 0) if already_switched else Vector2(-1, 0))
			unique_actor.global_position.x = -unique_actor.global_position.x  # Перемістити на протилежний бік
			target_position = unique_actor.global_position + Vector2(distance_x, 0) * (1 if already_switched else -1)
			moving_out = false
		else:
			# Повернення завершено
			moving_out = true
			return SUCCESS
			
	if moving_out:
		anim_tree.set("parameters/MainStateMachine/RUN/blend_position", -1)
	else:
		anim_tree.set("parameters/MainStateMachine/RUN/blend_position", 1)

	return RUNNING
