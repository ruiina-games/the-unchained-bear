extends Node2D

@export var teddy: Teddy
@export var wheel: SpinWheel

signal next_stage

@onready var animation_player = $AnimationPlayer

@onready var hint_label = %HintLabel
@onready var question_label = %QuestionLabel


@onready var player_controller = $PlayerController

var shop_active: bool = false
var if_on_exit: bool = false
var  transition_completed: bool = false
func _ready():
	transition_completed = false
	animation_player.play("APPEAR")
	player_controller.hp_bar_container.visible = false

func connect_signals(main: Node):
	connect("next_stage", Callable(main, "_on_next_stage"))

func _on_shop_area_body_entered(body):
	shop_active = true
	hint_label.visible = true
	


func _on_shop_area_body_exited(body):
	shop_active = false
	hint_label.visible = false


func _on_wheel_area_body_entered(body):
	wheel.area_entered = true
	hint_label.visible = true


func _on_wheel_area_body_exited(body):
	wheel.area_entered = false
	hint_label.visible = false

func _unhandled_input(event):
	if event.is_action_pressed("interact") and shop_active:
		#TODO: Open Shop
		teddy.animation_player.play("greetings")
	if event.is_action_pressed("interact") and if_on_exit:
		animation_player.play("DISSAPEAR")

func _on_next_stage_area_body_entered(body):
	if_on_exit = true
	question_label.show()

func _on_next_stage_area_body_exited(body):
	if_on_exit = false
	if question_label:
		question_label.hide()

func transition_complete():
	transition_completed = true
	next_stage.emit()
