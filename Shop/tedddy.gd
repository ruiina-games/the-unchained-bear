extends Node2D
class_name Teddy

@onready var greeting_sound = $GreetingSound
@onready var nice_choice_sound = $NiceChoiceSound
@onready var goodbye_sound = $GoodbyeSound
@onready var zakhar_rofl_sound = $ZakharRoflSound

@onready var animation_player = $AnimationPlayer

func _ready():
	animation_player.animation_finished.connect(func(anim_name): if anim_name == "greetings": animation_player.play("idle"))
