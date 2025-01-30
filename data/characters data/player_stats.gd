extends CharacterStats
class_name PlayerStats

@export var game_data: GameData

# @export var unique_skill: Resource
@export var temporary_upgrades: Array[TemporaryUpgrade]
@export var one_time_upgrades: Array[Upgrade]

func clear_temporary_modifiers():
	for upgrade in temporary_upgrades:
		remove_temporary_upgrade(upgrade)
	
# Додає тимчасовий модифікатор і застосовує його ефекти
func add_temporary_upgrade(new_upgrade: TemporaryUpgrade) -> void:
	temporary_upgrades.push_back(new_upgrade)
	apply_modifier(new_upgrade, true)  # true = додати ефекти

# Видаляє тимчасовий модифікатор і віднімає його ефекти
func remove_temporary_upgrade(new_upgrade: TemporaryUpgrade) -> void:
	if temporary_upgrades.has(new_upgrade):
		temporary_upgrades.erase(new_upgrade)
		apply_modifier(new_upgrade, false)  # false = відняти ефекти

# Застосовує або видаляє ефекти модифікатора
func apply_modifier(modifier: Upgrade, is_adding: bool) -> void:
	for stat in modifier.upgrade_array:
		
		var value = stat.multiplier
		if !is_adding:
			value = -value  # Якщо віднімаємо, інвертуємо значення
		
		match stat.stat_type:
			Upgrade.UPGRADABLE_STATS.MAX_HEALTH:
				increase_max_health(value)
			Upgrade.UPGRADABLE_STATS.ATTACK_POWER_MULTI:
				increase_attack_power_multiplier(value)
			Upgrade.UPGRADABLE_STATS.CRITICAL_CHANCE:
				increase_critical_chance(value)
			Upgrade.UPGRADABLE_STATS.CRITICAL_DAMAGE:
				increase_critical_damage_multiplier(value)
			Upgrade.UPGRADABLE_STATS.DODGE_CHANCE:
				increase_dodge_chance(value)
			Upgrade.UPGRADABLE_STATS.MOVEMENT_SPEED_MULTI:
				increase_movement_speed_multiplier(value)
			Upgrade.UPGRADABLE_STATS.STATUS_RESIST_MULTI:
				increase_status_resist_multiplier(value)
			Upgrade.UPGRADABLE_STATS.EFFECT_POWER_MULTI:
				increase_effect_power_multiplier(value)
