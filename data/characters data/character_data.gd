extends Resource
class_name CharacterData

@export var strength: float = 1.0
@export var max_health: int = 2000
@export var current_health: int = max_health
@export var critical_chance: float = 0.05
@export var critical_damage: float = 1.2
@export var dodge_chance: float = 0.0
@export var attack_speed: float = 1.0
@export var movement_speed: float = 1.0
@export var attack_range: float = 0.0
@export var status_resist: float = 0.1
@export var effect_power: float = 1.0

# Methods to handle improvements and updates
func increase_strength(amount: float) -> void:
	strength += amount

func increase_max_health(amount: int) -> void:
	max_health += amount
	current_health = min(current_health + amount, max_health)

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)

func take_damage(amount: int) -> void:
	current_health = max(current_health - amount, 0)

func increase_critical_chance(amount: float) -> void:
	critical_chance += amount

func increase_critical_damage(amount: float) -> void:
	critical_damage += amount

func increase_dodge_chance(amount: float) -> void:
	dodge_chance += amount

func increase_attack_speed(amount: float) -> void:
	attack_speed += amount

func increase_movement_speed(amount: float) -> void:
	movement_speed += amount

func increase_attack_range(amount: float) -> void:
	attack_range += amount

func increase_status_resist(amount: float) -> void:
	status_resist = min(status_resist + amount, 1.0) # Cap at 100%

func increase_effect_power(amount: float) -> void:
	effect_power += amount
