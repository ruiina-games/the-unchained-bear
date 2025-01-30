extends Node2D
class_name Teddy


@onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.animation_finished.connect(func(anim_name): if anim_name == "greetings": animation_player.play("idle"))
