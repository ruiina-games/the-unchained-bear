extends Resource
class_name Damage

@export var damage_amount: float = 20.0
@export var multiplier: float = 1.0
@export var effect: NegativeEffect

func get_damage_amount() -> float:
	return damage_amount * multiplier
