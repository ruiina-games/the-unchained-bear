extends Character
class_name Bear

@onready var animation_player = $AnimationPlayer
@onready var spin_eyes = $Polygons/Head/SpinEyes

enum STYLES_ID {
	FREESTYLE = 0,
	BOXING = 1,
	LUMBERJACK = 2,
	LEGHAND = 3
}

func _ready() -> void:
	super()
	
	$HealthComponent.got_hit.connect(func(enemy):
		if enemy is Monkey:
			enemy.break_object()
		)
