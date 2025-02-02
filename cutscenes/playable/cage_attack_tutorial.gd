extends Node2D

@onready var bear_new = $BearNew
@onready var camera_2d = $Camera2D
@onready var animation_player = $AnimationPlayer

signal cutscene_ended

var attack_count: int = 0
var is_cage_opened: bool = false
# Called when the node enters the scene tree for the first time.
func _ready():
	bear_new.animation_tree.active = false
	animation_player.play("BEGIN")
	bear_new.spin_eyes.visible = false

func connect_signals(main: Node):
	connect("cutscene_ended", Callable(main, "_on_cutscene_ended"))

func play_stand_up():
	bear_new.animation_player.play("TUTORIAL_STAND_UP")
	
func play_run():
	bear_new.animation_player.play("TUTORIAL_RUN")
	
func play_idle():
	bear_new.animation_player.play("TUTORIAL_IDLE")

func play_pick_up():
	bear_new.animation_player.play("TUTORIAL_PICK_CYCLE")
	
func play_end_run():
	bear_new.animation_player.play("FREE_STYLE/RUN")
	
func _unhandled_input(event):
	if event.is_action_pressed("attack") and !is_cage_opened:
		bear_new.animation_player.play("TUTORIAL_ATTACK")
		await get_tree().create_timer(0.8).timeout
		%CageHit.play(0.2)
		animation_player.play("CROSSBAR_SHAKE")
		bear_new.animation_player.animation_finished.connect(func(anim_name): 
			if attack_count == 3:
				is_cage_opened = true
				%CageBreak.play()
				animation_player.play("CROSSBAR_BREAK")
				return
			if anim_name == "TUTORIAL_ATTACK": 
				attack_count += 1
				
			)

func emit_cutscene_ended():
	cutscene_ended.emit()


func _on_skip_button_pressed():
	emit_cutscene_ended()
