extends GridContainer

@export var character_stats: CharacterStats

@onready var attack_power_multiplier: Label = %strength
@onready var max_health: Label = %"max health"
@onready var current_health: Label = %"current health"
@onready var critical_chance: Label = %"critical chance"
@onready var critical_damage_multiplier: Label = %"critical damage"
@onready var dodge_chance: Label = %"dodge chance"
@onready var attack_speed_multiplier: Label = %"attack speed"
@onready var movement_speed_multiplier: Label = %"movement speed"
@onready var attack_range: Label = %"attack range"
@onready var status_resist_multiplier: Label = %"status resist"
@onready var effect_power_multiplier: Label = %"effect power"

func _ready() -> void:
	update_labels()

func update_labels() -> void:
	attack_power_multiplier.text = "%.2f" % character_stats.attack_power_multiplier
	max_health.text = "%d" % character_stats.max_health
	current_health.text = "%d" % character_stats.current_health
	critical_chance.text = "%.2f%%" % (character_stats.critical_chance * 100)
	# critical_damage_multiplier.text = "%.2f" % character_stats.critical_damage_multiplier
	dodge_chance.text = "%.2f%%" % (character_stats.dodge_chance * 100)
	attack_speed_multiplier.text = "%.2f" % character_stats.attack_speed_multiplier
	movement_speed_multiplier.text = "%.2f" % character_stats.movement_speed_multiplier
	attack_range.text = "%.2f" % character_stats.attack_range
	status_resist_multiplier.text = "%.2f%%" % (character_stats.status_resist_multiplier * 100)
	effect_power_multiplier.text = "%.2f" % character_stats.effect_power_multiplier
