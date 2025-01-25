extends Node2D

@export var scene_to_spawn: PackedScene

var instance: Node2D

func _ready() -> void:
	add_level()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		if instance:
			instance.queue_free()
		add_level()

func add_level():
	instance = scene_to_spawn.instantiate()
	add_child(instance)
