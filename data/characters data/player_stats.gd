extends CharacterStats
class_name PlayerStats

signal inventory_updated()
signal item_equiped(item: Upgrade, slot: Upgrade.SLOT_TYPE)
signal item_unequiped(item: Upgrade, slot: Upgrade.SLOT_TYPE)

enum MONEY
{
	TICKETS,
	TOKENS
}

@export var money_dictionary: Dictionary = { 
	MONEY.TOKENS: 0, 
	MONEY.TICKETS: 0
}

# Слоти для екіпірування
@export var head_slot: Upgrade  # Слот для голови
@export var body_slot: Upgrade  # Слот для тіла
@export var legs_slot: Upgrade  # Слот для ніг

# Пул предметів, які є у гравця
@export var inventory: Array[Upgrade]

# Інші пули
@export var temporary_upgrades: Array[TemporaryUpgrade]

# Додає предмет до інвентаря
func add_to_inventory(new_upgrade: Upgrade) -> void:
	if new_upgrade:
		# Перевіряємо, чи предмет вже одягнутий у відповідному слоті
		var equipped_item: Upgrade = null
		match new_upgrade.slot_type:
			Upgrade.SLOT_TYPE.HEAD:
				if head_slot and head_slot.name == new_upgrade.name:
					equipped_item = head_slot
			Upgrade.SLOT_TYPE.BODY:
				if body_slot and body_slot.name == new_upgrade.name:
					equipped_item = body_slot
			Upgrade.SLOT_TYPE.LEGS:
				if legs_slot and legs_slot.name == new_upgrade.name:
					equipped_item = legs_slot
			Upgrade.SLOT_TYPE.FIGHTING_STYLE:
				if fighting_style and fighting_style.name == new_upgrade.name:
					equipped_item = fighting_style

		# Якщо предмет вже одягнутий, замінюємо його
		if equipped_item:
			unequip_upgrade(equipped_item)  # Знімаємо поточний предмет
			remove_from_inventory(equipped_item)  # Видаляємо його з інвентаря

		# Видаляємо всі інші предмети з таким самим ім'ям з інвентаря
		for upgrade in inventory:
			if upgrade.name == new_upgrade.name:
				remove_from_inventory(upgrade)

		# Додаємо новий предмет до інвентаря
		inventory.append(new_upgrade)
		
		if equipped_item:
			equip_upgrade(new_upgrade)
		
		print("Added to inventory: ", new_upgrade.name)
		inventory_updated.emit()

# Видаляє предмет з інвентаря
func remove_from_inventory(upgrade: Upgrade) -> void:
	if inventory.has(upgrade):
		inventory.erase(upgrade)
		print("Removed from inventory: ", upgrade.name)
		inventory_updated.emit()

func equip_upgrade(upgrade: Upgrade) -> void:
	if !inventory.has(upgrade):
		print("Upgrade not in inventory: ", upgrade.name)
		return

	match upgrade.slot_type:
		Upgrade.SLOT_TYPE.HEAD:
			if head_slot:
				unequip_upgrade(head_slot)  # Знімаємо поточний предмет
			head_slot = upgrade
			print("Equipped to head slot: ", upgrade.name)
		Upgrade.SLOT_TYPE.BODY:
			if body_slot:
				unequip_upgrade(body_slot)
			body_slot = upgrade
			print("Equipped to body slot: ", upgrade.name)
		Upgrade.SLOT_TYPE.LEGS:
			if legs_slot:
				unequip_upgrade(legs_slot)
			legs_slot = upgrade
			print("Equipped to legs slot: ", upgrade.name)
		Upgrade.SLOT_TYPE.FIGHTING_STYLE:
			if upgrade is FightingStyle:
				change_fighting_style(upgrade)
			else:
				print("Invalid fighting style: ", upgrade.name)
				return
		_:
			print("Invalid slot type for upgrade: ", upgrade.name)
			return

	item_equiped.emit(upgrade, upgrade.slot_type)
	remove_from_inventory(upgrade)
	apply_modifier(upgrade, true)  # Застосовуємо ефекти предмета

# Знімає предмет зі слота
func unequip_upgrade(upgrade: Upgrade) -> void:
	if head_slot == upgrade:
		head_slot = null
		print("Unequipped from head slot: ", upgrade.name)
	elif body_slot == upgrade:
		body_slot = null
		print("Unequipped from body slot: ", upgrade.name)
	elif legs_slot == upgrade:
		legs_slot = null
		print("Unequipped from legs slot: ", upgrade.name)
	elif fighting_style == upgrade:
		print("cannot unequip figthing style")
		return
	else:
		print("Upgrade not equipped: ", upgrade.name)
		return

	add_to_inventory(upgrade)
	item_unequiped.emit(upgrade, upgrade.slot_type)
	apply_modifier(upgrade, false)  # Видаляємо ефекти предмета

func clear_temporary_modifiers():
	for upgrade in temporary_upgrades:
		remove_temporary_upgrade(upgrade)
	
# Додає тимчасовий модифікатор і застосовує його ефекти
func add_temporary_upgrade(new_upgrade: TemporaryUpgrade) -> void:
	temporary_upgrades.push_back(new_upgrade)
	apply_modifier(new_upgrade, true)  # true = додати ефекти

# Видаляє тимчасовий модифікатор і віднімає його ефекти
func remove_temporary_upgrade(new_upgrade: TemporaryUpgrade) -> void:
	if temporary_upgrades.has(new_upgrade):
		temporary_upgrades.erase(new_upgrade)
		apply_modifier(new_upgrade, false)  # false = відняти ефекти

# Застосовує або видаляє ефекти модифікатора
func apply_modifier(modifier: Upgrade, is_adding: bool) -> void:
	if modifier is FightingStyle:
		return
	
	for stat in modifier.upgrade_array:
		var value = stat.multiplier
		if !is_adding:
			value = -value  # Якщо віднімаємо, інвертуємо значення
		
		if modifier is StatUpgrade:
			match stat.stat_type:
				StatUpgrade.UPGRADABLE_STATS.MAX_HEALTH:
					increase_max_health(value)
				StatUpgrade.UPGRADABLE_STATS.ATTACK_POWER_MULTI:
					increase_attack_power_multiplier(value)
				StatUpgrade.UPGRADABLE_STATS.CRITICAL_CHANCE:
					increase_critical_chance(value)
				StatUpgrade.UPGRADABLE_STATS.CRITICAL_DAMAGE:
					increase_critical_damage_multiplier(value)
				StatUpgrade.UPGRADABLE_STATS.DODGE_CHANCE:
					increase_dodge_chance(value)
				StatUpgrade.UPGRADABLE_STATS.MOVEMENT_SPEED_MULTI:
					increase_movement_speed_multiplier(value)
				StatUpgrade.UPGRADABLE_STATS.STATUS_RESIST_MULTI:
					increase_status_resist_multiplier(value)
				StatUpgrade.UPGRADABLE_STATS.EFFECT_POWER_MULTI:
					increase_effect_power_multiplier(value)
	stats_upgraded.emit()

func change_fighting_style(new_style: FightingStyle):
	if !inventory.has(new_style):
		print("Inventory doesn't have such style")
		return

	# Знімаємо поточний стиль бою
	if fighting_style:
		unequip_fighting_style(fighting_style)

	# Встановлюємо новий стиль бою
	fighting_style = new_style
	remove_from_inventory(new_style)
	apply_modifier(new_style, true)  # Застосовуємо ефекти нового стилю бою

# Знімає поточний стиль бою
func unequip_fighting_style(style: FightingStyle):
	if fighting_style == style:
		fighting_style = null
		add_to_inventory(style)
		apply_modifier(style, false)  # Видаляємо ефекти старого стилю бою
