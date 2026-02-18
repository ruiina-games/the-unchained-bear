extends Node2D

@export var shop_scene: PackedScene = preload("res://Shop/shop.tscn")

var shop_instance: Node
var player_stats: PlayerStats

func _ready() -> void:
	# Spawn the shop
	shop_instance = shop_scene.instantiate()
	add_child(shop_instance)

	# Get player stats from the shop's player controller
	var pc = shop_instance.find_child("PlayerController", true, false)
	if pc and pc is PlayerController:
		player_stats = pc.actor.character_stats

	_setup_debug_ui()
	_update_display()

func _process(_delta: float) -> void:
	_update_display()

func _setup_debug_ui() -> void:
	_connect_btn("AddTickets", func(): _add_money(PlayerStats.MONEY.TICKETS, 100))
	_connect_btn("AddTokens", func(): _add_money(PlayerStats.MONEY.TOKENS, 10))
	_connect_btn("SetMaxMoney", _set_max_money)
	_connect_btn("ResetAll", _reset_all)

func _connect_btn(btn_name: String, callback: Callable) -> void:
	var btn = find_child(btn_name, true, false)
	if btn:
		btn.pressed.connect(callback)

func _add_money(type: PlayerStats.MONEY, amount: int) -> void:
	if !player_stats:
		return
	player_stats.money_dictionary[type] += amount
	player_stats.stats_upgraded.emit()

func _set_max_money() -> void:
	if !player_stats:
		return
	player_stats.money_dictionary[PlayerStats.MONEY.TICKETS] = 9999
	player_stats.money_dictionary[PlayerStats.MONEY.TOKENS] = 9999
	player_stats.stats_upgraded.emit()

func _reset_all() -> void:
	if !player_stats:
		return
	player_stats.money_dictionary[PlayerStats.MONEY.TICKETS] = 0
	player_stats.money_dictionary[PlayerStats.MONEY.TOKENS] = 0
	player_stats.inventory.clear()
	player_stats.head_slot = null
	player_stats.body_slot = null
	player_stats.legs_slot = null
	player_stats.clear_temporary_modifiers()
	player_stats.reset()
	player_stats.stats_upgraded.emit()
	player_stats.inventory_updated.emit()

func _update_display() -> void:
	var label = find_child("MoneyLabel", true, false)
	if !label or !player_stats:
		return
	label.text = "Tickets: %d | Tokens: %d\nInventory: %d items\nHP: %d/%d | ATK: %.2f" % [
		player_stats.money_dictionary[PlayerStats.MONEY.TICKETS],
		player_stats.money_dictionary[PlayerStats.MONEY.TOKENS],
		player_stats.inventory.size(),
		player_stats.current_health,
		player_stats.max_health,
		player_stats.attack_power_multiplier
	]
