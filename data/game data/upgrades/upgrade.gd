extends Resource
class_name Upgrade

enum RARITY {
	COMMON = 1,
	UNCOMMON = 2,
	RARE = 3,
	MYTHICAL = 4,
	LEGENDARY = 5
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

@export var rarity: RARITY:
	set(new_rarity):
		set_rarity(new_rarity)

# Key is UPGRADABLE_STATS, value is multiplier.
@export var upgrade_dictionary: Dictionary

var drop_chance: float
var multiplier: float

func set_rarity(new_rarity: RARITY):
	if rarity == new_rarity:
		return
	rarity = new_rarity
	
	match rarity:
		RARITY.COMMON:
			drop_chance = 0.4
			multiplier = 1.1
		RARITY.UNCOMMON:
			drop_chance = 0.3
			multiplier = 1.2
		RARITY.RARE:
			drop_chance = 0.15
			multiplier = 1.3
		RARITY.MYTHICAL:
			drop_chance = 0.1
			multiplier = 1.4
		RARITY.LEGENDARY:
			drop_chance = 0.05
			multiplier = 1.5
			apply_legendary_effect()
	
	# Застосовуємо множник до всіх значень у upgrade_dictionary
	for key in upgrade_dictionary:
		upgrade_dictionary[key] *= multiplier

func apply_legendary_effect():
	# Додатковий унікальний ефект для легендарних покращень
	print("Легендарний ефект активовано!")
	# Наприклад, можна додати випадковий бонус до одного з атрибутів
	var random_stat = UPGRADABLE_STATS.values()[randi() % UPGRADABLE_STATS.size()]
	var bonus_multiplier = 1.2  # Додатковий бонус 20%
	upgrade_dictionary[random_stat] *= bonus_multiplier
	print("Додатковий бонус до: ", UPGRADABLE_STATS.keys()[random_stat - 1])
