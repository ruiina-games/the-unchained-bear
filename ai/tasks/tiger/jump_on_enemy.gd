extends BaseAction
class_name JumpOnEnemy

var distance = 300  # Визначена дистанція стрибкач
var gravity = 200  # Гравітація під час стрибка
var target = null  # Ціль, до якої ми стрибаємо
var jumping = false
var velocity = Vector2()  # Поточна швидкість актора

var has_finished_jump: bool = false

func _enter() -> void:
	super()
	has_finished_jump = false
	target = controller.target
	
	if unique_actor and target:
		state_machine.animation_tree.animation_finished.connect(func(anim_name):
			if anim_name.to_lower() == "jump":
				var horizontal_distance = -(unique_actor.global_position.x - target.global_position.x)
				var horizontal_speed = 1600  # Фіксована горизонтальна швидкість
				var time_to_target = abs(horizontal_distance) / horizontal_speed  # Час досягнення цілі

				# Розрахунок вертикальної сили (jump_force), щоб досягнути потрібну дистанцію
				var vertical_distance = GlobalVariables.FLOOR_HEIGHT - unique_actor.global_position.y
				var jump_force = -(gravity * time_to_target)  # Сила стрибка для необхідного часу

				velocity = Vector2(sign(horizontal_distance) * horizontal_speed, jump_force)  # Початкова швидкість
		  # Початкова анімація стрибка
				jumping = true
				
			if anim_name.to_lower() == "fly_catch" || anim_name.to_lower() == "fly_land" :
				jumping = false
				has_finished_jump = true
			)
			
		state_machine.switch_state("jump")


func _tick(delta: float) -> Status:
	if not unique_actor or not target:
		return FAILURE
		
	if has_finished_jump:
		unique_actor.global_position.y = GlobalVariables.FLOOR_HEIGHT
		return SUCCESS

	if jumping:
		if velocity.y < 0:
			state_machine.switch_state("fly_up")
		else:
			state_machine.switch_state("fly_down")

		# Оновлення вертикальної швидкості
		velocity.y += gravity * delta

		# Оновлення позиції актора
		unique_actor.global_position += velocity * delta

		# Перевірка наближення до землі
		if unique_actor.global_position.y >= GlobalVariables.FLOOR_HEIGHT:
			unique_actor.global_position.y = GlobalVariables.FLOOR_HEIGHT  # Прив'язка до землі
			jumping = false
			state_machine.switch_state("fly_land")

			# Перевірка, чи ціль достатньо близько
	if unique_actor.global_position.distance_to(target.global_position) <= distance and target.global_position.y >= unique_actor.global_position.y - 50:
		target.global_position.x = unique_actor.global_position.x + ((sign(unique_actor.global_position.direction_to(target.global_position).x)) * distance)
		state_machine.switch_state("fly_catch")

	return RUNNING
