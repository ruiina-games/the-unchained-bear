extends BaseAction

@export var speed = 400  # Швидкість переміщення актора
@export var distance_x = 480  # Дистанція, на яку актор повинен зникати за межі екрана

var target_position = Vector2()  # Цільова позиція актора
var moving_out = true  # Прапорець для контролю напрямку руху
var anim_tree: AnimationTree

func _enter() -> void:
	super()
	unique_actor = controller.tiger
	if unique_actor:
		# Визначення дальньої позиції (-2300 або 2300) в залежності від поточної позиції актора
		var far_position: float = 2000
		far_position += distance_x
		if unique_actor.global_position.x < 0:
			far_position = -far_position

		# Додаємо відстань для виходу за екран
		target_position = Vector2(far_position, unique_actor.global_position.y)
		var dir_to_center: Vector2 = unique_actor.global_position.direction_to(Vector2.UP)
		unique_actor.adjust_scale_for_direction(dir_to_center)

	anim_tree = state_machine.animation_tree
	state_machine.switch_state("run")

func _tick(delta: float) -> Status:
	if not unique_actor:
		return FAILURE

	# Переміщення до цільової позиції
	var direction = unique_actor.global_position.direction_to(target_position)
	unique_actor.velocity = direction * speed

	# Перевірка, чи досягнуто цільову позицію (вихід за екран)
	if unique_actor.global_position.distance_to(target_position) < 100.0:
		if moving_out:
			# Встановлюємо нову позицію для повернення на екран
			unique_actor.global_position.x = -target_position.x  # Перемістити на протилежний бік
			unique_actor.adjust_scale_for_direction(Vector2(1, 0) if target_position.x > 0 else Vector2(-1, 0))

			# Нова цільова позиція на екрані
			target_position.x = unique_actor.global_position.x + sign(target_position.x) * distance_x
			moving_out = false

			# Оновлення blend_position для руху задом
			anim_tree.set("parameters/MainStateMachine/RUN/blend_position", -1)
		else:
			# Повернення завершено
			moving_out = true
			# Оновлення blend_position для руху передом
			anim_tree.set("parameters/MainStateMachine/RUN/blend_position", 1)

			return SUCCESS
			

	# Оновлення blend_position для анімації під час руху
	if moving_out:
		anim_tree.set("parameters/MainStateMachine/RUN/blend_position", -1)
	else:
		anim_tree.set("parameters/MainStateMachine/RUN/blend_position", 1)
		
	unique_actor.move_and_slide()

	return RUNNING
