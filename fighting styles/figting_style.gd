extends Resource
class_name FightingStyle

@export var id: int
@export var name: String
@export_multiline var description: String
@export var max_combo_count: int
@export var damage_variations: Dictionary
@export var animation_res: Resource

var combo_count: int:
	set(new_combo_count):
		if new_combo_count >= max_combo_count:
			combo_count = 0
		else:
			combo_count = new_combo_count

func get_damage(damage_key = combo_count) -> Damage:
	return damage_variations[damage_key]
