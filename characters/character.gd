extends CharacterBody2D
class_name Character

@export var character_stats: CharacterStats
# @export var movement_stats: MovementStats
@export var animation_tree :AnimationTree

func get_anim_tree():
	if animation_tree:
		return animation_tree
		
func attack() -> void:
	pass
