extends Node2D

@export var player_controller: PlayerController
@export var main_camera: Camera2D

@export_category("Camera effects variables")
@export var tilt_duration: float = 0.3
@export var target_zoom: Vector2 = Vector2(0.32, 0.32)
@export var max_tilt_angle: float = 0.03

var default_camera_zoom: Vector2

func _ready():
	default_camera_zoom = main_camera.zoom

func _process(delta):
	tilt_camera(player_controller.direction)

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
