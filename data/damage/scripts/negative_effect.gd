extends Effect
class_name NegativeEffect

signal negative_effect_enabled(target: Character, dealer: Character, effect: NegativeEffect)
signal effect_reset(target: Character, effect: NegativeEffect)

@export var base_damage: float
