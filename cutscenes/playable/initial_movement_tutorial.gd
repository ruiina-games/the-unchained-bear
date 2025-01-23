extends Node2D
class_name InitialMovementTutorial

signal tutorial_ended

@export var player_controller: PlayerController
@export var beast_tamer: BeastTameress

@export var bear_scene: PackedScene

@onready var curtain = $Curtain
@onready var animation_player = $AnimationPlayer
@onready var tutorial_subtitle = $SubtitleControl/TutorialSubtitle
@onready var annoyance_timer = $AnnoyanceTimer
@onready var effects_controller = $EffectsController
@onready var camera_2d = $Camera2D

var tutorial_started: bool = false
var tutorial_second_stage_started: bool = false
var movement_tutorial_ended: bool = false

var a_was_pressed: bool = false
var d_was_pressed: bool = false
var space_was_pressed: bool = false
var s_was_pressed: bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	animation_player.play("fade_out")
	
	tutorial_ended.connect(func(): animation_player.play("fade_in"))

func _unhandled_input(event):
	if tutorial_started:
		if event.is_action_pressed("move_left"):
			await get_tree().create_timer(0.7).timeout
			a_was_pressed = true
		if event.is_action_pressed("move_right"):
			await get_tree().create_timer(0.7).timeout
			d_was_pressed = true
	
	if tutorial_second_stage_started:
		if event.is_action_pressed("jump"):
			space_was_pressed = true
		if event.is_action_pressed("bend"):
			s_was_pressed = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	second_stage()
	end_movement_tutorial()

func init_tutorial():
	tutorial_started = true
	tutorial_subtitle.text = "Press [A] and [D] to move left and right"
	annoyance_timer.timeout.connect(_on_annoyance_timer_timeout)
	annoyance_timer.start()

func _on_annoyance_timer_timeout():
	print("TIMEOUT")
	annoyance_timer.start()
	beast_tamer.animation_tree["parameters/MainStateMachine/conditions/attack"] = true
	beast_tamer.animation_tree.animation_finished.connect(func(anim_name): beast_tamer.animation_tree["parameters/MainStateMachine/conditions/attack"] = false)
	

func second_stage():
	if tutorial_second_stage_started == true:
		return
	
	if a_was_pressed and d_was_pressed:
		tutorial_second_stage_started = true
		animation_player.play("tamer_zoom")

		$TextPopup/TutorialSubtitle2.text = "Now jump!"
		$TextPopup.visible = true
		
		
		await get_tree().create_timer(1.5).timeout
		beast_tamer.animation_tree["parameters/MainStateMachine/conditions/attack"] = true
		$TextPopup.visible = false
		await get_tree().create_timer(0.1).timeout
		beast_tamer.animation_tree["parameters/MainStateMachine/conditions/attack"] = false
		
		
		
		
		annoyance_timer.stop()
		annoyance_timer.start()
		
		player_controller.hsm.allowed_advance_movement = true
		tutorial_subtitle.text = "Press [SPACE] to jump and [S] to bend"

func end_movement_tutorial():
	if movement_tutorial_ended == true:
		return
		
	if space_was_pressed and s_was_pressed:
		tutorial_ended.emit()
		movement_tutorial_ended = true

	
func start_transition():
	annoyance_timer.stop()
	var instance = bear_scene.instantiate()
	add_child(instance)
	instance.global_position = player_controller.global_position
	instance.global_position.y = 448.0
	player_controller.visible = false
	player_controller.process_mode = Node.PROCESS_MODE_DISABLED
	
	
	beast_tamer.animation_tree["parameters/MainStateMachine/ATTACK/blend_position"] = 1
	beast_tamer.animation_tree["parameters/MainStateMachine/conditions/attack"] = true
	await get_tree().create_timer(0.1).timeout
	beast_tamer.animation_tree["parameters/MainStateMachine/conditions/attack"] = false
	instance.animation_tree.active = false
	await get_tree().create_timer(0.3).timeout
	instance.animation_player.play("hit_head_tutorial")
	
	await get_tree().create_timer(0.5).timeout
	effects_controller.shake_camera(0.5, 40)


func start_initial_animation_with_dialogue():
	beast_tamer.animation_tree.active = false
	$TextPopup.visible = true
	beast_tamer.animation_player.play("SPEAKING_1")
	beast_tamer.animation_player.animation_finished.connect(func(anim_name): 
		if anim_name == "SPEAKING_1":
			beast_tamer.animation_tree.active = true
			$TextPopup.visible = false
		)

func change_label_text():
	$TextPopup/TutorialSubtitle2.text = "Faster! \n Piece of crap!"
	$TextPopup/TutorialSubtitle2.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	$TextPopup.visible = true
