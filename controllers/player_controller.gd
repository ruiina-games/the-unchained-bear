extends Node2D

@onready var bear_new: Bear = $BearNew
@onready var bear_visual: Node2D = $BearNew/BearVisual
@onready var animation_tree: AnimationTree = $BearNew/AnimationTree

# Змінні для контролю за рухом
var speed: float = 400.0
var turn_speed: float = 0.5
var max_tilt: float = 20.0
var acceleration: float = 600.0
var deceleration: float = 300.0
var gravity: float = 500

# Змінні для руху
var current_velocity: Vector2 = Vector2.ZERO
var tilt: float = 0.0
var direction: float = 0.0
var tilt_inertia: float = 0.1

func _ready() -> void:
	animation_tree.set("parameters/MainStateMachine/idle", false)
	animation_tree.set("parameters/MainStateMachine/run", true)

func _physics_process(delta: float) -> void:
	var dir: float = Input.get_axis("move_left", "move_right")
	
	# Прискорення і уповільнення
	if dir != 0:
		if sign(dir) != sign(current_velocity.x) and abs(current_velocity.x) > 10:
			current_velocity.x *= 0.3
			tilt = lerp(tilt, 0.0, 0.3)
		
		current_velocity.x += dir * acceleration * delta
		direction = dir

	else:
		if current_velocity.x > 0:
			current_velocity.x -= deceleration * delta
			current_velocity.x = max(current_velocity.x, 0)
		elif current_velocity.x < 0:
			current_velocity.x += deceleration * delta
			current_velocity.x = min(current_velocity.x, 0)
	
	# Обмеження максимальної швидкості
	current_velocity.x = clamp(current_velocity.x, -speed, speed)

	# Гравітація (застосовується тільки по вертикалі)
	current_velocity.y += gravity * delta

	# Нахил моноциклу
	if dir != 0:
		tilt = lerp(tilt, dir * max_tilt, tilt_inertia)
	else:
		tilt = lerp(tilt, 0.0, 0.1)

	tilt = clamp(tilt, -max_tilt, max_tilt)
	
	bear_new.velocity = current_velocity
	bear_new.rotation = deg_to_rad(tilt)
	bear_new.move_and_slide()

	# Плавне вирівнювання нахилу
	if abs(current_velocity.x) < 10:
		tilt = lerp(tilt, 0.0, 0.2)

	if abs(tilt) < 0.5 and abs(current_velocity.x) < 5:
		tilt = 0.0
		
	bear_new.set_facing(dir)
