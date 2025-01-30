extends Node2D

@export var teddy: Teddy
@export var wheel: SpinWheel

@onready var hint_label = %HintLabel
@onready var player_controller = $PlayerController

var shop_active: bool = false

func _ready():
	player_controller.hp_bar_container.visible = false

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
