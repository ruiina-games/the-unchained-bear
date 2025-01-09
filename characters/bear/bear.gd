extends CharacterBody2D
class_name Bear

enum STYLES_ID {
	FREESTYLE = 0,
	BOXING = 1,
	LUMBERJACK = 2,
	LEGHAND = 3
}

func set_facing(dir :float):
	if dir > 0:
		 = 1
	elif dir < 0:
		transform.x.x = -1
