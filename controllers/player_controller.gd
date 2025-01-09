extends Node2D

@onready var actor: Bear = %BearNew

@export_category("Actor Movement")
# Змінні для контролю за рухом
@export var speed: float = 800.0
@export var turn_speed: float = 0.5
@export var max_tilt: float = 20.0
@export var acceleration: float = 100.0  # Заміна для delta
@export var deceleration: float = 20.0  # Заміна для delta
@export var gravity: float = 40.0

# Змінні для руху
var current_velocity: Vector2 = Vector2.ZERO
var tilt: float = 0.0
var direction: float = 1.0
var tilt_inertia: float = 0.1

func _physics_process(delta: float) -> void:
	var dir: float = Input.get_axis("move_left", "move_right")

	# Прискорення і уповільнення
	if dir != 0:
		if sign(dir) != sign(current_velocity.x) and abs(current_velocity.x) > 10:
			current_velocity.x *= 0.3
			tilt = lerp(tilt, 0.0, 0.3)

		current_velocity.x += dir * acceleration

		if dir != direction:
			actor.scale.x *= -1
		direction = dir
	else:
		if current_velocity.x > 0:
			current_velocity.x -= deceleration
			current_velocity.x = max(current_velocity.x, 0)
		elif current_velocity.x < 0:
			current_velocity.x += deceleration
			current_velocity.x = min(current_velocity.x, 0)

	# Обмеження максимальної швидкості
	current_velocity.x = clamp(current_velocity.x, -speed, speed)

	# Гравітація (застосовується тільки по вертикалі)
	current_velocity.y += gravity

	# Нахил моноциклу
	if dir != 0:
		tilt = lerp(tilt, dir * max_tilt, tilt_inertia)
	else:
		tilt = lerp(tilt, 0.0, 0.1)

	tilt = clamp(tilt, -max_tilt, max_tilt)

	actor.rotation = 0  # Скидаємо будь-який попередній нахил
	actor.rotate(deg_to_rad(tilt))

	# Збереження поточного масштабу та ротації
	var original_scale = actor.scale
	var original_rotation = actor.rotation

	actor.velocity = current_velocity
	
	# Виклик move_and_slide()
	actor.move_and_slide()

	# Відновлення масштабу та ротації
	actor.scale = original_scale
	actor.rotation = original_rotation

	# Плавне вирівнювання нахилу
	if abs(current_velocity.x) < 10:
		tilt = lerp(tilt, 0.0, 0.2)

	if abs(tilt) < 0.5 and abs(current_velocity.x) < 5:
		tilt = 0.0
