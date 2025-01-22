extends PlayerState
class_name PlayerRunState

func _update(delta: float):
	handle_movement()

func handle_movement():
	if !character.can_move:
		return

	var dir = Input.get_axis("move_left", "move_right")

	# Прискорення і уповільнення
	if dir != 0:
		if sign(dir) != sign(controller.current_velocity.x) and abs(controller.current_velocity.x) > 10:
			controller.current_velocity.x *= 0.3
			controller.tilt = lerp(controller.tilt, 0.0, 0.3)

		controller.current_velocity.x += dir * (controller.acceleration * character.character_stats.movement_speed_multiplier)

		if dir != controller.direction:
			controller.actor.scale.x *= -1
		controller.direction = dir

	# Обмеження максимальної швидкості
	controller.current_velocity.x = clamp(controller.current_velocity.x, -controller.speed, controller.speed * character.character_stats.movement_speed_multiplier)
	controller.current_velocity.y = 0
	
	# Нахил моноциклу
	if dir != 0:
		controller.tilt = lerp(controller.tilt, dir * controller.max_tilt, controller.tilt_inertia)
	else:
		controller.tilt = lerp(controller.tilt, 0.0, 0.1)
		
		# Виклик події MOVEMENT_FINISHED, коли швидкість занадто мала
	if abs(controller.current_velocity.x) < 1:  # Поріг швидкості, щоб вважати рух завершеним
		dispatch(state_machine.MOVEMENT_FINISHED)
	
	super()
