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
	var direction = controller.actor.global_position.direction_to(controller.target.global_position).normalized()

	# Розраховуємо цільову позицію на основі дистанції заряду
	target_position = actor_global_position + direction * charge_distance
	is_charging = true  # Починаємо заряд
	
	controller.actor.adjust_scale_for_direction(direction)

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
	var distance_to_target = actor_global_position.distance_to(target_position)

	# Якщо досягнуто цільову позицію
	if distance_to_target <= tolerance:
		velocity = Vector2.ZERO
		controller.actor.velocity = velocity
		controller.actor.move_and_slide()
		print("Charge completed. Stopping.")
		is_charging = false  # Зупиняємо заряд
		return Status.SUCCESS

	# Рухаємо персонажа до цільової позиції
	var direction = actor_global_position.direction_to(target_position)
	velocity = direction * move_speed
	controller.actor.velocity = velocity
	controller.actor.move_and_slide()

	return Status.RUNNING
