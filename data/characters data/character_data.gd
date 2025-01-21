extends Resource
class_name CharacterStats

@export var attack_power_multiplier: float = 1.0
@export var max_health: int = 2000
@export var critical_chance: float = 0.05
@export var critical_damage_multiplier: float = 1.2
@export var dodge_chance: float = 0.0
@export var attack_speed_multiplier: float = 1.0
@export var movement_speed_multiplier: float = 1.0
@export var attack_range: float = 0.0
@export var status_resist_multiplier: float = 0.1
@export var effect_power_multiplier: float = 1.0
@export var fighting_style: FightingStyle

var current_health: int

# Methods to handle improvements and updates
func increase_attack_power_multiplier(amount: float) -> void:
	attack_power_multiplier += amount

func increase_max_health(amount: int) -> void:
	max_health += amount
	current_health = min(current_health + amount, max_health)

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)

func take_damage(amount: int) -> void:
	current_health = max(current_health - amount, 0)

func increase_critical_chance(amount: float) -> void:
	critical_chance += amount

func increase_critical_damage_multiplier(amount: float) -> void:
	critical_damage_multiplier += amount

func increase_dodge_chance(amount: float) -> void:
	dodge_chance += amount

func increase_attack_speed_multiplier(amount: float) -> void:
	attack_speed_multiplier += amount

func increase_movement_speed_multiplier(amount: float) -> void:
	movement_speed_multiplier += amount

func increase_attack_range(amount: float) -> void:
	attack_range += amount

func increase_status_resist_multiplier(amount: float) -> void:
	status_resist_multiplier = min(status_resist_multiplier + amount, 1.0) # Cap at 100%

func increase_effect_power_multiplier(amount: float) -> void:
	effect_power_multiplier += amount
