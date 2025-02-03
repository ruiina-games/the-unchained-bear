extends Resource
class_name CharacterStats

signal got_hit()
signal hp_changed(new_hp: int)
signal died()

signal stats_upgraded
signal fighting_style_changed

@export var attack_power_multiplier: float = 1.0
@export var max_health: int = 2000
@export var critical_chance: float = 0.05
@export var critical_damage_multiplier: float = 1.2
@export var dodge_chance: float = 0.0
@export var movement_speed_multiplier: float = 1.0
@export var status_resist_multiplier: float = 0.1
@export var effect_power_multiplier: float = 1.0
@export var fighting_style: FightingStyle:
	set(new_fs):
		fighting_style = new_fs
		if fighting_style:
			fighting_style_changed.emit()

var current_health: int
var reserve_copy: CharacterStats

# Methods to handle improvements and updates
func increase_attack_power_multiplier(amount: float) -> void:
	print("attack_power_multiplier ", attack_power_multiplier)
	print("amount", amount)
	attack_power_multiplier += amount

func increase_max_health(amount: float) -> void:
	max_health += amount
	heal(amount)

func heal(amount: int) -> void:
	current_health = min(current_health + amount, max_health)

func take_damage(amount: int) -> void:
	current_health = max(current_health - amount, 0)
	got_hit.emit()
	hp_changed.emit(current_health)

func increase_critical_chance(amount: float) -> void:
	critical_chance = clampf(critical_chance + amount, critical_chance, 0.8)

func increase_critical_damage_multiplier(amount: float) -> void:
	critical_damage_multiplier += amount

func increase_dodge_chance(amount: float) -> void:
	dodge_chance = clampf(dodge_chance + amount, dodge_chance, 0.8)

func increase_movement_speed_multiplier(amount: float) -> void:
	movement_speed_multiplier += amount

func increase_status_resist_multiplier(amount: float) -> void:
	status_resist_multiplier = clampf(status_resist_multiplier + amount, status_resist_multiplier, 0.8)

func increase_effect_power_multiplier(amount: float) -> void:
	effect_power_multiplier += amount

func reset():
	if !reserve_copy:
		return
		
	attack_power_multiplier = reserve_copy.attack_power_multiplier
	max_health = reserve_copy.max_health
	critical_chance = reserve_copy.critical_chance
	critical_damage_multiplier = reserve_copy.critical_damage_multiplier
	dodge_chance = reserve_copy.dodge_chance
	movement_speed_multiplier = reserve_copy.movement_speed_multiplier
	status_resist_multiplier = reserve_copy.status_resist_multiplier
	effect_power_multiplier = reserve_copy.effect_power_multiplier
	fighting_style = reserve_copy.fighting_style
	
