extends AIController
class_name BeastTameressController

@export var monkey: Monkey

func _ready() -> void:
	super()
	setup_monkey()

func setup_monkey():
	if !objects_container:
		return
	
	monkey.objects_container = objects_container
	monkey.ready_to_throw_object.connect(func():
		if !target:
			return
		var throw_direction: Vector2 = actor.global_position.direction_to(target.global_position)
		actor.adjust_scale_for_direction(throw_direction)
		monkey.throw_object(throw_direction.normalized())
	)
