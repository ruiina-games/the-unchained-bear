extends PlayerState

var was_on_floor: bool = true

const AIR_CONTROL := 0.4 # 40% від наземного прискорення

func _enter() -> void:
	was_on_floor = true
	controller.current_velocity.y = -controller.jump_force

func _update(delta: float) -> void:
	# Air control
	var dir = Input.get_axis("move_left", "move_right")
	if dir != 0:
		var air_accel: float = controller.acceleration * character.character_stats.movement_speed_multiplier * AIR_CONTROL
		var max_speed: float = controller.speed * character.character_stats.movement_speed_multiplier
		controller.current_velocity.x += dir * air_accel
		controller.current_velocity.x = clamp(controller.current_velocity.x, -max_speed, max_speed)

	character.is_on_floor = is_equal_approx(character.global_position.y, GlobalVariables.FLOOR_HEIGHT)
	super(delta)

	if !was_on_floor and character.is_on_floor:
		controller.current_velocity.y = 0
		character.velocity.y = 0
		if dir != 0:
			dispatch(state_machine.MOVEMENT_STARTED)
		else:
			dispatch(state_machine.LANDED)

	was_on_floor = character.is_on_floor
