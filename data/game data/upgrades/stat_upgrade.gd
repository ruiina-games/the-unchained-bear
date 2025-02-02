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

var first_time: bool = false
@export var upgrade_array: Array[StatModel]

func initialize_upgrade():
	if !first_time:
		for stat in upgrade_array:
			match rarity:
				Upgrade.RARITY.COMMON:
					stat.previous_multiplier = 0
				Upgrade.RARITY.UNCOMMON:
					stat.previous_multiplier = 1.0
				Upgrade.RARITY.RARE:
					stat.previous_multiplier = 2.0
				Upgrade.RARITY.MYTHICAL:
					stat.previous_multiplier = 3.0
				Upgrade.RARITY.LEGENDARY:
					stat.previous_multiplier = 4.0
		first_time = true
	super()

func update_rarity():
	var new_multiplier: float
	
	# Визначаємо новий множник на основі рідкості
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
	
	# Застосовуємо новий множник до кожного StatModel
	for stats_model in upgrade_array:
		if stats_model.previous_multiplier > 0:
		# Скасовуємо попередній множник (ділимо на нього)
			stats_model.multiplier /= stats_model.previous_multiplier
		# Застосовуємо новий множник
		stats_model.multiplier *= new_multiplier
		# Оновлюємо previous_multiplier для наступного виклику
		stats_model.previous_multiplier = new_multiplier
