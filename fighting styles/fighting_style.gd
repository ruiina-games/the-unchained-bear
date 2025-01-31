extends ShopUpgrade
class_name FightingStyle

@export var max_combo_count: int
@export var damage_variations: Dictionary

var combo_count: int

func get_damage() -> Damage:
	if combo_count >= max_combo_count:
		combo_count = 0
	return damage_variations[combo_count]

func get_damage_at_index(index: int):
	if index >= max_combo_count:
		index = 0
	return damage_variations[index]
