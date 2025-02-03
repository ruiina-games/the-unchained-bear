extends Upgrade
class_name StatUpgrade

enum UPGRADABLE_STATS {
	MAX_HEALTH = 1,
	ATTACK_POWER_MULTI = 2,
	CRITICAL_CHANCE = 3,
	CRITICAL_DAMAGE = 4,
	DODGE_CHANCE = 5,
	MOVEMENT_SPEED_MULTI = 6,
	STATUS_RESIST_MULTI = 7,
	EFFECT_POWER_MULTI = 8
}

@export var upgrade_array: Array[StatModel]

func update_rarity():
	var new_multiplier: float
	
	match rarity:
		RARITY.COMMON:
			new_multiplier = 1.0
		RARITY.UNCOMMON:
			new_multiplier = 2.0
		RARITY.RARE:
			new_multiplier = 3.0
		RARITY.MYTHICAL:
			new_multiplier = 4.0
		RARITY.LEGENDARY:
			new_multiplier = 5.0
			apply_legendary_effect()
	
	for stats_model in upgrade_array:
		stats_model.multiplier = stats_model.base_value * new_multiplier
		print(name, " ", stats_model.multiplier)
