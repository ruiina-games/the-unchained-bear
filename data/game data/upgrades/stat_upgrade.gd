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
			multiplier = 1
		RARITY.UNCOMMON:
			multiplier = 2
		RARITY.RARE:
			multiplier = 3
		RARITY.MYTHICAL:
			multiplier = 4
		RARITY.LEGENDARY:
			multiplier = 5
			apply_legendary_effect()
	
	# Застосовуємо множник до всіх значень у upgrade_array
	for stats_model in upgrade_array:
		stats_model.multiplier *= multiplier
