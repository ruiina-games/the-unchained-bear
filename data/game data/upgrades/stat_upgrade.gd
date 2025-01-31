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
	var multiplier: float
	
	match rarity:
		RARITY.COMMON:
			multiplier = upgrade_multi_step
		RARITY.UNCOMMON:
			multiplier = upgrade_multi_step * 2
		RARITY.RARE:
			multiplier = upgrade_multi_step * 3
		RARITY.MYTHICAL:
			multiplier = upgrade_multi_step * 4
		RARITY.LEGENDARY:
			multiplier = upgrade_multi_step * 5
			apply_legendary_effect()
	
	# Застосовуємо множник до всіх значень у upgrade_dictionary
	for stats_model in upgrade_array:
		if multiplier < 1.0:
			stats_model.multiplier = 1 + multiplier
		else:
			stats_model.multiplier *= multiplier
