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
var slowmo_timer: Timer = null  # Таймер для слоу-мо
var _tilt_tween: Tween = null
var _last_tilt_moving: bool = false


func _ready():
	if main_camera:
		initialize()

	GlobalSignals.hurt_triggered.connect(func(causer):
		hitstop()
		if causer and causer.name != "BearNew":
			shake_camera(shake_duration, shake_magnitude)
		else:
			shake_camera(shake_duration * 0.3, shake_magnitude * 0.3)
	)
	GlobalSignals.character_died.connect(func(agent):
		slow_motion(slowmotion_duration, slowmotion_strength)
		await get_tree().create_timer(slowmotion_duration).timeout
		GlobalSignals.ready_to_transit.emit(agent)
		)
	GlobalSignals.stop_slow_motion.connect(func(): stop_slow_motion())

func initialize():
	default_camera_zoom = main_camera.zoom
	original_offset = main_camera.offset

func _process(delta):
	if !player_controller or !main_camera:
		return
	tilt_camera(player_controller.direction.x)
	
func tilt_camera(direction: float):
	var is_moving = Input.is_action_pressed("move_left") or Input.is_action_pressed("move_right")
	if is_moving == _last_tilt_moving and _tilt_tween and _tilt_tween.is_valid():
		return
	_last_tilt_moving = is_moving

	if _tilt_tween and _tilt_tween.is_valid():
		_tilt_tween.kill()

	_tilt_tween = create_tween()
	if is_moving:
		var target_rotation = -direction * max_tilt_angle
		_tilt_tween.parallel().tween_property(main_camera, "rotation", target_rotation, tilt_duration)
		_tilt_tween.parallel().tween_property(main_camera, "zoom", target_zoom, tilt_duration)
	else:
		_tilt_tween.parallel().tween_property(main_camera, "rotation", 0, tilt_duration)
		_tilt_tween.parallel().tween_property(main_camera, "zoom", default_camera_zoom, tilt_duration)

func hitstop(duration: float = 0.05) -> void:
	Engine.time_scale = 0.05
	await get_tree().create_timer(duration * 0.05).timeout
	if slowmo_timer == null or !slowmo_timer.time_left > 0:
		Engine.time_scale = 1.0

func shake_camera(shake_duration: float = 0.5, shake_magnitude: float = 10.0) -> void:
	if !main_camera:
		return
	var tween: Tween = create_tween()
	var steps := 10
	var step_duration := shake_duration / float(steps)
	var current_offset = original_offset

	for i in range(steps):
		var random_offset = Vector2(
			randf_range(-shake_magnitude, shake_magnitude),
			randf_range(-shake_magnitude, shake_magnitude)
		)
		var target_offset = original_offset + random_offset
		tween.tween_property(main_camera, "offset", target_offset, step_duration)
		current_offset = target_offset

	tween.tween_property(main_camera, "offset", original_offset, step_duration)

func slow_motion(duration: float, percentage: float):
	Engine.time_scale = percentage  # Встановлюємо нову швидкість часу
	
	# Якщо таймер вже існує, видаляємо його
	if slowmo_timer:
		slowmo_timer.stop()
		slowmo_timer.queue_free()
	
	# Створюємо новий таймер для відновлення нормальної швидкості
	slowmo_timer = Timer.new()
	slowmo_timer.one_shot = true
	slowmo_timer.wait_time = duration * percentage
	add_child(slowmo_timer)
	slowmo_timer.connect("timeout", _reset_time_scale)
	slowmo_timer.start()

func _reset_time_scale():
	Engine.time_scale = 1.0  # Повертаємо швидкість часу до нормальної
	if slowmo_timer:
		slowmo_timer.queue_free()  # Видаляємо таймер
		slowmo_timer = null

func stop_slow_motion():
	# Викликаємо метод для відновлення часу
	_reset_time_scale()
