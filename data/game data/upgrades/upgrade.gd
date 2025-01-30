extends Resource
class_name Upgrade

enum RARITY {
	COMMON = 0,
	UNCOMMON,
	RARE,
	MYTHICAL,
	LEGENDARY
}

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

@export var name: String
@export_multiline var description: String
@export var icon_path: String
@export var rarity: RARITY = RARITY.COMMON
@export var upgrade_array: Array[StatModel]

var drop_chance: float

func initialize_upgrade():
	update_rarity()

func update_rarity():
	var multiplier: float
	
	match rarity:
		RARITY.COMMON:
			drop_chance = 0.4
			multiplier = 1
		RARITY.UNCOMMON:
			drop_chance = 0.3
			multiplier = 2
		RARITY.RARE:
			drop_chance = 0.15
			multiplier = 3
		RARITY.MYTHICAL:
			drop_chance = 0.1
			multiplier = 4
		RARITY.LEGENDARY:
			drop_chance = 0.05
			multiplier = 5
			apply_legendary_effect()
	
	# Застосовуємо множник до всіх значень у upgrade_dictionary
	for stats_model in upgrade_array:
		stats_model.multiplier *= multiplier

func apply_legendary_effect():
	pass
