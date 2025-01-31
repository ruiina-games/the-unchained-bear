extends Node

@export var player_stats: PlayerStats  # Посилання на статистику гравця
@export var shop_assortment: Array[ShopUpgrade]  # Асортимент магазину

var i: int = 0
func _ready() -> void:
	for upgrade in shop_assortment:
		upgrade.initialize_upgrade()

# Функція для оновлення асортименту магазину
func update_assortment() -> void:
	var items_to_remove: Array[ShopUpgrade] = []  # Предмети, які потрібно видалити з асортименту

	for item in shop_assortment:
		var player_has_item = false  # Скидаємо змінну для кожного предмета
	
		# Перевіряємо, чи гравець вже має цей предмет
		for upgrade in player_stats.inventory:
			if upgrade.name == item.name:
				print("inventary object: " + upgrade.name, " vs ", "new item ", item.name)
				player_has_item = true
				break  # Виходимо з циклу, якщо знайшли предмет

		if player_has_item:
			# Якщо гравець має цей предмет, збільшуємо його рідкість
			if item.rarity < Upgrade.RARITY.size() - 1:  # Перевіряємо, чи рідкість не максимальна
				item.rarity += 1
				item.cost *= 2  # Збільшуємо вартість
			else:
				# Якщо рідкість максимальна, додаємо предмет до списку для видалення
				items_to_remove.append(item)

	# Видаляємо предмети з максимальною рідкістю з асортименту
	for item in items_to_remove:
		shop_assortment.erase(item)
		print("Removed from shop (max rarity): ", item.title)

# Функція для перевірки, чи може гравець купити предмет
func can_afford(item: ShopUpgrade) -> bool:
	return player_stats.money_dictionary[item.money_type] >= item.cost

# Функція для покупки предмета
func purchase_item(item: ShopUpgrade) -> bool:
	if !can_afford(item):
		print("Not enough money to purchase: ", item.title)
		return false

	# Віднімаємо гроші
	player_stats.money_dictionary[item.money_type] -= item.cost

	# Додаємо предмет до інвентаря гравця
	var new_upgrade = item.duplicate()
	player_stats.add_to_inventory(new_upgrade)

	# Оновлюємо асортимент магазину
	update_assortment()

	print("Purchased: ", item.title)
	return true

# Функція для відображення доступних для покупки предметів
func display_available_items() -> void:
	print("Available items in shop:")
	for item in shop_assortment:
		var can_buy = can_afford(item)
		print("- ", item.title, " (Cost: ", item.cost, " ", item.money_type, " ", item.rarity, ") - ", "Can buy: ", can_buy)
