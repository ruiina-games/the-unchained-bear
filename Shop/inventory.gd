extends Control

@onready var inventory_upper_container = %InventoryUpperContainer
@onready var stats_upper_container = %StatsUpperContainer

const board_purple = preload("res://assets/inventory/inventory_0003_board-purple.png")
const board_yellow = preload("res://assets/inventory/inventory_0004_board-yellow.png")

@onready var stats_inv_board = %StatsInvBoard
@onready var tab_stats = %TabStats
@onready var tab_inventory = %TabInventory


func _ready():
	inventory_upper_container.hide()
	stats_upper_container.show()


func _on_tab_stats_pressed():
	inventory_upper_container.hide()
	stats_upper_container.show()
	stats_inv_board.texture = board_yellow


func _on_tab_inventory_pressed():
	inventory_upper_container.show()
	stats_upper_container.hide()
	stats_inv_board.texture = board_purple
