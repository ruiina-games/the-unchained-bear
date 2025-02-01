extends Control

@onready var inventory_upper_container = %InventoryUpperContainer
@onready var stats_upper_container = %StatsUpperContainer
@onready var switch_button = %SwitchButton


func _ready():
	inventory_upper_container.hide()
	stats_upper_container.show()

func _on_switch_button_pressed():
	inventory_upper_container.visible = !inventory_upper_container.visible
	stats_upper_container.visible = !stats_upper_container.visible
