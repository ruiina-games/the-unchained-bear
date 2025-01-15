extends BTCondition
class_name CheckDistance

@export var target_distance: float
@export var target: BBNode

var actor_global_position: Vector2
var target_global_position: Vector2

func _enter() -> void:
	var controller: Controller = scene_root
	if !controller:
		return
	
	#if blackboard.get_var(target.variable):
	#	blackboard.get_var(target.variable)
	
	actor_global_position = controller.actor_global_position
	target_global_position = controller.target.global_position

func _tick(delta: float) -> Status:
	var current_distance: float = actor_global_position.distance_to(target_global_position)
	var direction: Vector2 = (target_global_position - actor_global_position).normalized()
	
	# Якщо дистанція більша, ніж потрібно
	if current_distance > target_distance:
		return Status.SUCCESS
	
	# Якщо дистанція менша, ніж потрібно
	elif current_distance < target_distance:
		return Status.SUCCESS
	
	# Якщо дистанція відповідає бажаній
	return Status.FAILURE
