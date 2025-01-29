extends BaseAction
class_name MoveAction

@export var move_speed: float = 1000.0
@export var tolerance: float = 100.0  # Допустима відстань до цілі для завершення
@export var should_stop_at_enemy: bool = false

var velocity: Vector2 = Vector2.ZERO
var target_position: Vector2

func _enter() -> void:
	controller = scene_root
	if !controller:
		print("Error: Controller is not defined!")
		return

	# Отримуємо нову позицію для руху
	target_position = controller.get_target_move_position()
	#controller.actor.adjust_scale_for_direction(target_position)

func _tick(delta: float) -> Status:
	if !controller or controller.actor == null:
		print("Error: Actor is not defined!")
		return Status.FAILURE
		
	if !controller.actor.can_move:
		return Status.FAILURE
		
	if controller.actor.is_dead:
		return Status.FAILURE

	var actor_global_position = controller.actor.global_position
	var distance_to_target = actor_global_position.distance_to(target_position)
	
	# Перевіряємо, чи потрібно зупинитися біля ворога
	if should_stop_at_enemy and controller.target:
		var enemy_position: Vector2 = controller.target.global_position
		var distance_to_enemy: float = actor_global_position.distance_to(enemy_position)
		
		if distance_to_enemy < tolerance:
			# Зупиняємо рух і повертаємо актора до ворога
			velocity = Vector2.ZERO
			controller.actor.velocity = velocity
			controller.actor.move_and_slide()
			
			var look_at_direction = controller.actor.global_position.direction_to(controller.target.global_position)
			controller.actor.adjust_scale_for_direction(look_at_direction)
			return Status.SUCCESS

	# Якщо досягнуто цільової позиції
	if distance_to_target <= tolerance:
		velocity = Vector2.ZERO
		controller.actor.velocity = velocity
		controller.actor.move_and_slide()
		# print("Reached target. Stopping.")
		
		# Повертаємо актора до ворога
		var look_at_direction = controller.actor.global_position.direction_to(controller.target.global_position)
		controller.actor.adjust_scale_for_direction(look_at_direction)
		
		return Status.SUCCESS
	
	# Рухаємо актора до цільової позиції
	var direction = actor_global_position.direction_to(target_position)
	velocity = direction * move_speed
	# velocity.y = 0  # Ігноруємо вертикальний рух (якщо потрібно)
	controller.actor.velocity = velocity
	
	controller.actor.move_and_slide()
	return Status.RUNNING
