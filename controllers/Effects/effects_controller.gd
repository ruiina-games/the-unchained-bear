extends Node2D

@export var player_controller: PlayerController
@export var main_camera: Camera2D

@export_category("Camera movement effects variables")
@export var tilt_duration: float = 0.3
@export var target_zoom: Vector2 = Vector2(0.32, 0.32)
@export var max_tilt_angle: float = 0.03

@export_category("Camera shake effects variables")
@export var shake_duration: float = 1
@export var shake_magnitude: float = 100

@export_category("Slowmotion effect")
@export var slowmotion_duration: float = 3.0
@export var slowmotion_strength: float = 0.1

var default_camera_zoom: Vector2
var original_offset: Vector2

func _ready():
	default_camera_zoom = main_camera.zoom
	original_offset = main_camera.offset
	
	GlobalSignals.hurt_triggered.connect(func(causer): if causer and causer.name != "BearNew": shake_camera(shake_duration, shake_magnitude))
	GlobalSignals.character_died.connect(func(agent): slow_motion(slowmotion_duration, slowmotion_strength))

func _process(delta):
	tilt_camera(player_controller.direction.x)
	
func tilt_camera(direction: float):
	if Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right"):
		var target_rotation = -direction * max_tilt_angle
		var tween = create_tween()
		tween.parallel().tween_property(main_camera, "rotation", target_rotation, tilt_duration)
		tween.parallel().tween_property(main_camera, "zoom", target_zoom, tilt_duration)
	else:
		var tween = create_tween()
		tween.parallel().tween_property(main_camera, "rotation", 0, tilt_duration)
		tween.parallel().tween_property(main_camera, "zoom", default_camera_zoom, tilt_duration)

func shake_camera(shake_duration: float = 0.5, shake_magnitude: float = 10.0) -> void:
	# Створюємо Tween через вбудовану функцію create_tween()
	var tween: Tween = create_tween()

	# Кількість "ривків" (кадрів), за які камера робить різкі зміщення
	var steps := 10
	# Час на кожен ривок
	var step_duration := shake_duration / float(steps)
	
	# Поточне (стартове) зміщення для першого кроку
	var current_offset = original_offset

	# Циклічно додаємо ривки
	for i in range(steps):
		# Генеруємо випадковий вектор зміщення
		var random_offset = Vector2(
			randf_range(-shake_magnitude, shake_magnitude),
			randf_range(-shake_magnitude, shake_magnitude)
		)
		# Цільове зміщення: оригінальне + випадковий "стрибок"
		var target_offset = original_offset + random_offset
		
		# Додаємо анімацію властивості offset у Tween:
		# від current_offset до target_offset за step_duration секунд
		tween.tween_property(
			main_camera,               # Кому анімуємо?
			"offset",           # Яку властивість?
			target_offset,      # Кінцеве значення
			step_duration       # Тривалість
		)
		
		current_offset = target_offset

	# Повертаємо зміщення у вихідну точку
	tween.tween_property(main_camera, "offset", original_offset, step_duration)


func slow_motion(duration: float, percentage: float):
	Engine.time_scale = percentage  # Встановлюємо нову швидкість часу
	
	# Створюємо таймер для відновлення нормальної швидкості
	var timer = Timer.new()
	timer.one_shot = true
	timer.wait_time = duration * percentage
	add_child(timer)
	timer.connect("timeout", _reset_time_scale)
	timer.start()

func _reset_time_scale():
	Engine.time_scale = 1.0  # Повертаємо швидкість часу до нормальної
