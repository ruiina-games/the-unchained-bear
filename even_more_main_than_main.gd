extends Node2D

@onready var canvas_layer: CanvasLayer = $CanvasLayer

@export var beast_tameress_scene: PackedScene
@export var duo_animals_scene: PackedScene
@export var acrobat_scene: PackedScene

@onready var beast_tameress_btn: Button = %beast_tameress_btn
@onready var duo_animals_btn: Button = %duo_animals_btn
@onready var acrobat_btn: Button = %acrobat_btn

var current_level: Node2D
var current_scene: PackedScene

func _ready() -> void:
	canvas_layer.show()
	beast_tameress_btn.pressed.connect(func():
		add_level(beast_tameress_scene)
		)
	duo_animals_btn.pressed.connect(func():
		add_level(duo_animals_scene)
		)
	acrobat_btn.pressed.connect(func():
		add_level(acrobat_scene)
		)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		if current_level:
			current_level.queue_free()
		add_level(current_scene)
		GlobalSignals.stop_slow_motion.emit()
	elif event.is_action_pressed("pause"):
		go_to_main_menu()
		GlobalSignals.stop_slow_motion.emit()

func add_level(scene_to_spawn: PackedScene):
	current_scene = scene_to_spawn
	current_level = scene_to_spawn.instantiate()
	add_child(current_level)
	canvas_layer.hide()

func go_to_main_menu():
	if current_level:
		current_level.queue_free()
	canvas_layer.show()
