extends Area2D
class_name Hitbox

signal hit_target(damaged_character: Character)

@export var agent :Character
@export var object: ThrowingObject

func _on_hitbox_entered(area: Area2D):
	if area is Hurtbox:
		pass
	if area is Hurtbox && area.agent:
		hit_target.emit(area.agent)

func _on_hitbox_exited(area):
	pass
