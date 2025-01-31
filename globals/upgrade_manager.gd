extends Node

@export var temporary_upgrades_pool: Array[TemporaryUpgrade]
@export var shop_upgrades_pool: Array[ShopUpgrade]

var rarity_to_chance: Dictionary = {
	Upgrade.RARITY.COMMON: 0.4,
	Upgrade.RARITY.UNCOMMON: 0.3,
	Upgrade.RARITY.RARE: 0.15,
	Upgrade.RARITY.MYTHICAL: 0.1,
	Upgrade.RARITY.LEGENDARY: 0.05
} 

func _ready() -> void:
	for upgrade in temporary_upgrades_pool:
		upgrade.initialize_upgrade()

# Цією функцію дістаєш тимчасові апгрейди для колеса фортуни.
# Параметри: 
#	requested_upgrades_amount - кількість покращень, які тобі потрібні.
#	player_stats - character_stats змінна у ведмедя.
func get_temporary_upgrades_pool(requested_upgrades_amount: int, player_stats: PlayerStats) -> Array[TemporaryUpgrade]:
	var pool: Array[TemporaryUpgrade] = []
	var upgrades_to_randomize: Array[TemporaryUpgrade] = []
	
	# Create a copy of the pool to avoid modifying original
	var available_upgrades = temporary_upgrades_pool.duplicate()
	
	while pool.size() < requested_upgrades_amount and available_upgrades.size() > 0:
		# Get random upgrade from available pool
		var random_index = randi_range(0, available_upgrades.size() - 1)
		var selected_upgrade = available_upgrades[random_index]
		available_upgrades.remove_at(random_index)
		
		# Check if player already has this upgrade
		var existing_upgrade = null
		for upgrade in player_stats.temporary_upgrades:
			if upgrade.name == selected_upgrade.name:
				existing_upgrade = selected_upgrade
				break
		
		if existing_upgrade:
			if selected_upgrade.rarity < Upgrade.RARITY.LEGENDARY:
				# Create upgrade with increased rarity
				var upgraded_version = selected_upgrade.duplicate()
				# Збільшуємо рідкість на 1, але не виходимо за межі LEGENDARY
				upgraded_version.rarity = min(upgraded_version.rarity + 1, Upgrade.RARITY.LEGENDARY)
				upgraded_version.initialize_upgrade()
				pool.append(upgraded_version)
				var rarity_name = get_rarity_name(upgraded_version.rarity)
		else:
			# Add to pool and mark for rarity randomization
			var new_upgrade = selected_upgrade.duplicate()
			pool.append(new_upgrade)
			upgrades_to_randomize.append(new_upgrade)
			var rarity_name = get_rarity_name(new_upgrade.rarity)
	
	randomize_rarities(upgrades_to_randomize)
	
	for upgrade in pool:
		var rarity_name = get_rarity_name(upgrade.rarity)
		print("Name: ", upgrade.name, 
			  " | Rarity: ", rarity_name)
	
	return pool

func randomize_rarities(pool: Array[TemporaryUpgrade]):
	for upgrade in pool:
		var old_rarity_name = get_rarity_name(upgrade.rarity)
		
		var random_value = randf()
		
		var cumulative_chance = 0.0
		
		for rarity in rarity_to_chance.keys():
			cumulative_chance += rarity_to_chance[rarity]
			
			if random_value <= cumulative_chance:
				upgrade.rarity = rarity
				upgrade.initialize_upgrade()
				var new_rarity_name = get_rarity_name(upgrade.rarity)
				break

func get_rarity_name(rarity_value: int) -> String:
	var keys = Upgrade.RARITY.keys()
	return keys[rarity_value]
