extends BTCondition
class_name CheckDistance

@export var target_distance: float
@export var target: BBNode

# Enum для вибору типу успішної перевірки
enum CheckMode {
	GREATER,  # Дистанція більша за target_distance
	LESS,     # Дистанція менша за target_distance
	EQUAL     # Дистанція дорівнює target_distance
}

@export var check_mode: CheckMode = CheckMode.GREATER

var actor_global_position: Vector2
var target_global_position: Vector2

func _enter() -> void:
	var controller: Controller = scene_root
	if !controller:
		return

	actor_global_position = controller.actor_global_position
	target_global_position = controller.target.global_position

func _tick(delta: float) -> Status:
	var current_distance: float = actor_global_position.distance_to(target_global_position)

	match check_mode:
		CheckMode.GREATER:
			if current_distance > target_distance:
				return Status.SUCCESS

		CheckMode.LESS:
			if current_distance < target_distance:
				return Status.SUCCESS

		CheckMode.EQUAL:
			if is_equal_approx(current_distance, target_distance):
				return Status.SUCCESS
				
	return FAILURE
