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

func get_temporary_upgrades_pool(requested_upgrades_amount: int, player_stats: PlayerStats) -> Array[TemporaryUpgrade]:
	var pool: Array[TemporaryUpgrade] = []
	var upgrades_to_randomize: Array[TemporaryUpgrade] = []
	
	# Create a copy of the pool to avoid modifying original
	var available_upgrades = temporary_upgrades_pool.duplicate()
	
	while pool.size() < requested_upgrades_amount and available_upgrades.size() > 0:
		var random_index = randi_range(0, available_upgrades.size() - 1)
		var selected_upgrade = available_upgrades[random_index]
		available_upgrades.remove_at(random_index)
		
		# Check if player already has this upgrade
		var existing_upgrade = null
		for upgrade in player_stats.temporary_upgrades:
			if upgrade.name == selected_upgrade.name:
				existing_upgrade = upgrade
				break
		
		if existing_upgrade:
			if existing_upgrade.rarity < Upgrade.RARITY.LEGENDARY:
				# Create upgrade with increased rarity
				var upgraded_version = selected_upgrade.duplicate()
				upgraded_version.rarity = min(Upgrade.RARITY.LEGENDARY, existing_upgrade.rarity + 1)  # Use existing upgrade's rarity as base
				upgraded_version.initialize_upgrade()
				pool.push_back(upgraded_version)
		else:
			# Add to pool and mark for rarity randomization
			var new_upgrade = selected_upgrade.duplicate()
			pool.append(new_upgrade)
			upgrades_to_randomize.append(new_upgrade)
	
	# Randomize rarities while avoiding duplicates
	randomize_rarities_unique(upgrades_to_randomize, player_stats)
	
	#for upgrade in pool:
	#	var rarity_name = get_rarity_name(upgrade.rarity)
	#	print("Name: ", upgrade.name, " | Rarity: ", rarity_name)
	
	return pool

func randomize_rarities_unique(pool: Array[TemporaryUpgrade], player_stats: PlayerStats):
	# Get existing rarities from player's upgrades
	var existing_rarities = []
	for upgrade in player_stats.temporary_upgrades:
		existing_rarities.append(upgrade.rarity)
	
	for upgrade in pool:
		var available_rarities = []
		
		# Create list of available rarities that aren't already in use
		for rarity in rarity_to_chance.keys():
			if not rarity in existing_rarities:
				available_rarities.append(rarity)
		
		if available_rarities.is_empty():
			# If all rarities are used, default to increasing the rarity
			upgrade.rarity = min(upgrade.rarity + 1, Upgrade.RARITY.LEGENDARY)
		else:
			# Normalize chances for available rarities
			var total_chance = 0.0
			var adjusted_chances = {}
			
			for rarity in available_rarities:
				total_chance += rarity_to_chance[rarity]
			
			for rarity in available_rarities:
				adjusted_chances[rarity] = rarity_to_chance[rarity] / total_chance
			
			# Select random rarity from available ones
			var random_value = randf()
			var cumulative_chance = 0.0
			
			for rarity in adjusted_chances.keys():
				cumulative_chance += adjusted_chances[rarity]
				if random_value <= cumulative_chance:
					upgrade.rarity = rarity
					existing_rarities.append(rarity)  # Add to existing rarities to prevent future duplicates
					break
		
		upgrade.initialize_upgrade()

func get_rarity_name(rarity_value: int) -> String:
	var keys = Upgrade.RARITY.keys()
	return keys[rarity_value]
