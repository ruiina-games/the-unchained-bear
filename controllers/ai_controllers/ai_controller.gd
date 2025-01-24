extends Controller
class_name AIController

@export var attack_range: float = 1600

var blackboard: Blackboard

func init_state_machine():
	if !hsm:
		return
	hsm.initialize(self)
	hsm.set_active(true)
	
	var first_state = hsm.get_child(0)
	
	if first_state:
		hsm.change_active_state(first_state)
	else:
		print("No states to play in - ", name)
		return

func get_target_move_position():
	if !target:
		return Vector2.ZERO

func calculate_target_position(actor_pos: Vector2, target_pos: Vector2, direction_to_target: Vector2) -> Vector2:
	# Нормалізуємо напрямок, щоб отримати одиничний вектор
	var dir = direction_to_target.normalized()
	# Віднімаємо від x координати цілі (target_pos.x) 
	# нормалізований напрямок, помножений на attack_range
	var new_x = target_pos.x + dir.x * attack_range
	var new_y = actor_pos.y  # або target_pos.y, залежно від того, чого хочете досягти
	
	return Vector2(new_x, new_y)
	
func look_at_target(target_position: Vector2):
	var look_at_direction = actor.global_position.direction_to(target_position)
	actor.adjust_scale_for_direction(look_at_direction)

func attack_notify(inform_text: String, inform_duration: float):
	pass
	
func apply_knockback(direction, force):
	direction = direction.normalized()
	var knockback_duration: float = 0.3  # Duration of the knockback effect
	var elapsed_time: float = 0.0
	var initial_velocity = actor.velocity

	while elapsed_time < knockback_duration:
		var knockback_force = lerp(force, 0.0, elapsed_time / knockback_duration)
		actor.velocity = direction * knockback_force
		elapsed_time += get_physics_process_delta_time()
		await get_tree().process_frame
		actor.move_and_slide()

	actor.velocity = initial_velocity
	print(name + " is knocked back with force: " + str(force))

func set_controller_inactive():
	hsm.set_active(false)
