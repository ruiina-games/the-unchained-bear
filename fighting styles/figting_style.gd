extends Resource
class_name FightingStyle

@export var id: int
@export var name: String
@export_multiline var description: String
@export var max_combo_count: int
@export var damage_variations: Dictionary
@export var animation_res: Resource

var combo_count: int

func get_damage() -> Damage:
	# print(combo_count)
	if combo_count >= max_combo_count:
		combo_count = 0
	return damage_variations[combo_count]

func get_damage_at_index(index: int):
	if index >= max_combo_count:
		index = 0
	return damage_variations[index]
