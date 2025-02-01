extends Node2D

@onready var player_controller: PlayerController = %PlayerController
@export var new_fighting_style: FightingStyle

var player_stats: PlayerStats

func _ready() -> void:
	player_stats = player_controller.actor.character_stats

	# Підключаємо сигнал stats_upgraded
	player_stats.stats_upgraded.connect(_on_stats_upgraded)

	# Тестовий код для перевірки слотів
	test_slots()

# Обробник сигналу stats_upgraded
func _on_stats_upgraded() -> void:
	print("Stats upgraded! Current stats:")
	print_stats()

# Виводимо поточну статистику гравця
func print_stats() -> void:
	print("Max Health: ", player_stats.max_health)
	print("Attack Power Multiplier: ", player_stats.attack_power_multiplier)
	print("Critical Chance: ", player_stats.critical_chance)
	print("Critical Damage Multiplier: ", player_stats.critical_damage_multiplier)
	print("Dodge Chance: ", player_stats.dodge_chance)
	print("Movement Speed Multiplier: ", player_stats.movement_speed_multiplier)
	print("Status Resist Multiplier: ", player_stats.status_resist_multiplier)
	print("Effect Power Multiplier: ", player_stats.effect_power_multiplier)
	print("\n")

# Тестовий метод для перевірки слотів
func test_slots() -> void:
	print("Initial stats:")
	print_stats()

	# Створюємо тестові предмети для кожного слота
	var helmet_stats: Array[StatModel] = [
		StatModel.new(StatUpgrade.UPGRADABLE_STATS.DODGE_CHANCE, 0.05),  # +5% до шансу ухилення
		StatModel.new(StatUpgrade.UPGRADABLE_STATS.MAX_HEALTH, 500)  # +500 HP
	]
	var helmet = create_upgrade("Iron Helmet", Upgrade.SLOT_TYPE.HEAD, helmet_stats)

	var armor_stats: Array[StatModel] = [
		StatModel.new(StatUpgrade.UPGRADABLE_STATS.MAX_HEALTH, 1000),  # +1000 HP
		StatModel.new(StatUpgrade.UPGRADABLE_STATS.STATUS_RESIST_MULTI, 0.2)  # +20% до резисту статусів
	]
	var armor = create_upgrade("Steel Armor", Upgrade.SLOT_TYPE.BODY, armor_stats)

	var boots_stats: Array[StatModel] = [
		StatModel.new(StatUpgrade.UPGRADABLE_STATS.MOVEMENT_SPEED_MULTI, 0.15)  # +15% до швидкості руху
	]
	var boots = create_upgrade("Leather Boots", Upgrade.SLOT_TYPE.LEGS, boots_stats)

	# Додаємо предмети до інвентаря
	player_stats.add_to_inventory(helmet)
	player_stats.add_to_inventory(armor)
	player_stats.add_to_inventory(boots)

	# Екіпіруємо предмети у слоти
	print("\nEquipping items...")
	player_stats.equip_upgrade(helmet)
	player_stats.equip_upgrade(armor)
	player_stats.equip_upgrade(boots)

	# Виводимо оновлену статистику
	print("\nStats after equipping items:")
	print_stats()

	# Знімаємо предмети зі слотів
	print("\nUnequipping items...")
	player_stats.unequip_upgrade(helmet)
	player_stats.unequip_upgrade(armor)
	player_stats.unequip_upgrade(boots)

	# Виводимо статистику після зняття предметів
	print("\nStats after unequipping items:")
	print_stats()

# Допоміжна функція для створення апгрейдів
func create_upgrade(name: String, slot_type: Upgrade.SLOT_TYPE, stats: Array[StatModel]) -> Upgrade:
	var upgrade = StatUpgrade.new()
	upgrade.name = name
	upgrade.slot_type = slot_type
	upgrade.upgrade_array = stats  # Передаємо масив StatModel в upgrade_array
	return upgrade
