extends TickingNegativeEffect
class_name BleedingEffect

# Percentage of target's max HP
@export var bleeding_damage_percent: float = 0.03

func calculate_damage(targets_max_hp: float):
	base_damage = targets_max_hp * bleeding_damage_percent
	return base_damage
