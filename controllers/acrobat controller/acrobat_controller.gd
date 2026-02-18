extends AIController
class_name AcrobatController

@export var objects_container: Node2D

var min_distance = 100  # Мінімальна відстань

func _ready() -> void:
	super()
	actor.ready_to_throw_object.connect(func():
		if !target:
			return
		var throw_direction: Vector2 = actor.global_position.direction_to(target.global_position)
		actor.adjust_scale_for_direction(throw_direction)
		actor.throw_object(throw_direction.normalized(), objects_container)
		)

func get_target_move_position():
	super()

	var screen_min_x = -2000  # Ліва межа екрану
	var screen_max_x = 2000   # Права межа екрану

	var actor_position = global_position  # Поточна позиція актора
	var actor_x = actor_position.x
	var current_y = actor_position.y  # Використовуємо поточну позицію Y актора

	# print("Поточна позиція актора (X):", actor_x)

	# Визначаємо діапазон для X, враховуючи min_distance та attack_range
	var min_x = max(screen_min_x, actor_x - attack_range)
	var max_x = min(screen_max_x, actor_x + attack_range)

	# print("Початковий діапазон: min_x =", min_x, "max_x =", max_x)

	# Перевіряємо, чи діапазон достатньо великий для min_distance
	if (max_x - min_x) < min_distance * 2:
		# print("Діапазон замалий. Розширюємо його...")
		min_x = max(screen_min_x, actor_x - min_distance)
		max_x = min(screen_max_x, actor_x + min_distance)
		# print("Новий діапазон: min_x =", min_x, "max_x =", max_x)

	# Якщо актор знаходиться в правій частині екрану, зсуваємо min_x вліво
	if actor_x > 0:
		min_x = max(screen_min_x, actor_x - attack_range * 2)  # Збільшуємо діапазон вліво
		# print("Зсунуто min_x вліво: min_x =", min_x)

	# Генеруємо випадкову позицію по X
	var random_x: float
	var attempts = 0
	while attempts < 100:  # Обмежуємо кількість спроб
		random_x = randf_range(min_x, max_x)
		# print("Спроба", attempts + 1, ": random_x =", random_x)

		# Перевіряємо, чи позиція знаходиться на відстані щонайменше min_distance
		if abs(random_x - actor_x) >= min_distance:
			# print("Знайдено підходящу позицію: random_x =", random_x)
			break
		attempts += 1

	# Якщо не вдалося знайти підходящу позицію, повертаємо поточну позицію актора
	if attempts >= 100:
		# print("Не вдалося знайти підходящу позицію. Використовуємо поточну позицію актора.")
		random_x = actor_x

	# Повертаємо позицію з новим X та поточним Y
	# print("Нова цільова позиція: (", random_x, ",", current_y, ")")
	return Vector2(random_x, current_y)
