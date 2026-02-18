extends Node2D

@onready var initial_movement_tutorial = $InitialMovementTutorial

signal cutscene_ended
# Called when the node enters the scene tree for the first time.
func _ready():
	$AudioStreamPlayer.play()
	initial_movement_tutorial.ready_to_change_scene.connect(change_scene)
	
func connect_signals(main: Node):
	connect("cutscene_ended", Callable(main, "_on_cutscene_ended"))
	
func change_scene():
	var new_scene = initial_movement_tutorial.next_stage.instantiate()
	initial_movement_tutorial.queue_free()
	new_scene.cutscene_ended.connect(func(): 
		cutscene_ended.emit()
		)
	add_child(new_scene)
