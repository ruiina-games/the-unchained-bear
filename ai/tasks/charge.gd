extends BaseAction
class_name ChargeAction

@export var move_speed: float = 1000.0  # Швидкість руху
@export var charge_distance: float = 500.0  # Дистанція заряду
@export var tolerance: float = 10.0  # Допустима відстань до цілі для завершення

var velocity: Vector2 = Vector2.ZERO
var target_position: Vector2  # Цільова позиція для заряду
var is_charging: bool = false  # Чи почався заряд

func _enter() -> void:
	controller = scene_root
	if !controller:
		print("Error: Controller is not defined!")
		return

	# Отримуємо поточну позицію та напрямок руху персонажа
	var actor_global_position = controller.actor.global_position
	var target_global_position = controller.target.global_position

	# Визначаємо напрямок лише по осі X
	var direction_x = sign(target_global_position.x - actor_global_position.x)  # -1 (ліворуч), 1 (праворуч)

	# Розраховуємо цільову позицію на основі дистанції заряду (лише по осі X)
	target_position = actor_global_position + Vector2(direction_x * charge_distance, 0)
	is_charging = true  # Починаємо заряд

	# Налаштовуємо масштаб персонажа залежно від напрямку
	controller.actor.adjust_scale_for_direction(Vector2(direction_x, 0))

func _tick(delta: float) -> Status:
	if !controller or controller.actor == null:
		print("Error: Actor is not defined!")
		return Status.FAILURE

	if !controller.actor.can_move:
		return Status.FAILURE

	if controller.actor.is_dead:
		return Status.FAILURE

	# Якщо заряд завершено
	if !is_charging:
		return Status.SUCCESS

	var actor_global_position = controller.actor.global_position
	var distance_to_target = abs(actor_global_position.x - target_position.x)  # Відстань лише по осі X

	# Якщо досягнуто цільову позицію
	if distance_to_target <= tolerance:
		velocity = Vector2.ZERO
		controller.actor.velocity = velocity
		controller.actor.move_and_slide()
		is_charging = false  # Зупиняємо заряд
		return Status.SUCCESS

	# Рухаємо персонажа до цільової позиції (лише по осі X)
	var direction_x = sign(target_position.x - actor_global_position.x)  # Напрямок руху (-1 або 1)
	velocity = Vector2(direction_x * move_speed, 0)  # Рух лише по осі X
	controller.actor.velocity = velocity
	controller.actor.move_and_slide()

	return Status.RUNNING
