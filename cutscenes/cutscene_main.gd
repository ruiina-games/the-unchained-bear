extends Node2D

@onready var initial_movement_tutorial = $InitialMovementTutorial

# Called when the node enters the scene tree for the first time.
func _ready():
	$AudioStreamPlayer.play()
	initial_movement_tutorial.ready_to_change_scene.connect(change_scene)
	
func change_scene():
	var new_scene = initial_movement_tutorial.next_stage.instantiate()
	initial_movement_tutorial.queue_free()
	add_child(new_scene)
