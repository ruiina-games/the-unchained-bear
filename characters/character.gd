extends CharacterBody2D
class_name Character

@export var animation_tree :AnimationTree

func get_anim_tree():
	if animation_tree:
		return animation_tree
		
func attack() -> void:
	pass
