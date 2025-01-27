extends BaseAction

@export var speed = 400  # Швидкість переміщення актора
@export var distance_x = 480  # Дистанція, на яку актор повинен зникати за межі екрана

var target_position = Vector2()  # Цільова позиція актора
var moving_out = true  # Прапорець для контролю напрямку руху
var anim_tree: AnimationTree
var movement_finished: bool = false  # Прапорець для перевірки завершення руху

func _enter() -> void:
	super()
	movement_finished = false
	unique_actor = controller.tiger
	if unique_actor:
		# Визначення дальньої позиції (-2300 або 2300) в залежності від поточної позиції актора
		var far_position: float = 2000
		if unique_actor.global_position.x < 0:
			far_position = -far_position

		# Додаємо відстань для виходу за екран
		target_position = Vector2(far_position + sign(far_position) * distance_x, unique_actor.global_position.y)
		var dir_to_center: Vector2 = unique_actor.global_position.direction_to(Vector2.UP)
		unique_actor.adjust_scale_for_direction(dir_to_center)

	anim_tree = state_machine.animation_tree
	state_machine.switch_state("run")
	print("Entered state, target position set to: ", target_position)

func _tick(delta: float) -> Status:
	if not unique_actor:
		print("Unique actor not found, returning FAILURE")
		return FAILURE

	if movement_finished:
		# Перевіряємо, чи завершився рух
		anim_tree.set("parameters/MainStateMachine/RUN/blend_position", 0)
		print("Movement finished, returning SUCCESS")
		return SUCCESS

	# Переміщення до цільової позиції
	var direction = unique_actor.global_position.direction_to(target_position)
	unique_actor.velocity = direction * speed
	print("Current direction: ", direction, " Velocity: ", unique_actor.velocity)

	# Перевірка, чи досягнуто цільову позицію (вихід за екран)
	if unique_actor.global_position.distance_to(target_position) < 200.0:
		print("Target position reached: ", target_position)
		if moving_out:
			# Встановлюємо нову позицію для повернення на екран
			unique_actor.global_position.x = -target_position.x  # Перемістити на протилежний бік
			unique_actor.adjust_scale_for_direction(Vector2(1, 0) if target_position.x > 0 else Vector2(-1, 0))

			# Нова цільова позиція на екрані
			target_position.x = unique_actor.global_position.x + sign(target_position.x) * distance_x
			moving_out = false

			# Оновлення blend_position для руху задом
			anim_tree.set("parameters/MainStateMachine/RUN/blend_position", -1)
			print("Switched to moving back on screen, new target position: ", target_position)
		else:
			# Повернення завершено
			moving_out = true
			movement_finished = true

			# Оновлення blend_position для руху передом
			anim_tree.set("parameters/MainStateMachine/RUN/blend_position", 1)
			print("Movement to screen completed, returning SUCCESS")
			return SUCCESS

	# Оновлення blend_position для анімації під час руху
	if moving_out:
		anim_tree.set("parameters/MainStateMachine/RUN/blend_position", -1)
	else:
		anim_tree.set("parameters/MainStateMachine/RUN/blend_position", 1)

	unique_actor.move_and_slide()
	print("Actor moving: position ", unique_actor.global_position, " target ", target_position)
	return RUNNING
