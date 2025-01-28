extends AIController
class_name BeastTameressController

@export var monkey: Monkey
@export var objects_container: Node2D

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
		monkey.object.damage = actor.character_stats.fighting_style.get_damage()
		monkey.throw_object(throw_direction.normalized())
	)

func get_target_move_position():
	super()
	
	var viewport = get_viewport_rect()
	var actor_pos = actor.global_position
	var target_pos = target.global_position

	# Визначення напрямку від боса до гравця
	var direction_to_target = actor_pos.direction_to(target_pos)

	# Розрахунок цільової позиції, яка знаходиться на відстані attack_range від target
	var target_position: Vector2 = calculate_target_position(actor_pos, target_pos, direction_to_target)

	# Перевіряємо, чи цільова позиція знаходиться в межах viewport
	if target_position.x <= -2000 || target_position.x >= 2000:
		direction_to_target = -direction_to_target
		target_position = calculate_target_position(actor_pos, target_pos, direction_to_target)
	
	return target_position
