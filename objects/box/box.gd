extends ThrowingObject
class_name Box

@onready var breaking = $Break

func _ready():
	animated_sprite_2d.animation_finished.connect(func(anim_name): breaking.play())
