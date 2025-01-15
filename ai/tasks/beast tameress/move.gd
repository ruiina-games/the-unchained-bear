extends BaseAction
class_name MoveAction

@export var move_speed: float = 1000.0
@export var tolerance: float = 50.0  # Допустима відстань до цілі для завершення

var target_global_position: Vector2
var velocity: Vector2 = Vector2.ZERO
var direction: Vector2 = Vector2.ZERO

func _enter() -> void:
	controller = scene_root
	if !controller:
		print("Error: Controller is not defined!")
		return

func _tick(delta: float) -> Status:
	if !controller or controller.actor == null:
		print("Error: Actor is not defined!")
		return Status.FAILURE

	var actor_global_position = controller.actor.global_position
	target_global_position = controller.get_target_move_position(1500)

	# Розрахунок напряму (лише по x)
	direction = actor_global_position.direction_to(target_global_position)
	direction.y = 0.0  # Ігноруємо вісь 
	
	controller.actor.adjust_scale_for_direction(direction)

	# Якщо персонаж досягнув цілі
	if abs(actor_global_position.x - target_global_position.x) <= tolerance:
		velocity = Vector2.ZERO
		controller.actor.velocity = velocity
		controller.actor.move_and_slide()
		controller.actor.adjust_scale_for_direction(actor_global_position.direction_to(controller.target.global_position))
		
		print("distance is " + str(controller.actor.global_position.distance_to(controller.target.global_position)))
		print("Reached target. Stopping.")
		return Status.SUCCESS

	# Розрахунок швидкості
	velocity = Vector2(direction.x * move_speed, 0)
	controller.actor.velocity = velocity

	# Рух персонажа
	controller.actor.move_and_slide()

	return Status.RUNNING

func _exit():
	if controller and controller.actor:
		controller.actor.velocity = Vector2.ZERO
	velocity = Vector2.ZERO
