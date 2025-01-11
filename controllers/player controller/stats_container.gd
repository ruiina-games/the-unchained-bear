extends GridContainer

@export var character_stats: CharacterData

@onready var strength: Label = %strength
@onready var max_health: Label = %"max health"
@onready var current_health: Label = %"current health"
@onready var critical_chance: Label = %"critical chance"
@onready var dodge_chance: Label = %"dodge chance"
@onready var attack_speed: Label = %"attack speed"
@onready var movement_speed: Label = %"movement speed"
@onready var attack_range: Label = %"attack range"
@onready var status_resist: Label = %"status resist"
@onready var effect_power: Label = %"effect power"

func _ready() -> void:
	update_labels()

func update_labels() -> void:
	strength.text = "%.2f" % character_stats.strength
	max_health.text = "%d" % character_stats.max_health
	current_health.text = "%d" % character_stats.current_health
	critical_chance.text = "%.2f%%" % (character_stats.critical_chance * 100)
	dodge_chance.text = "%.2f%%" % (character_stats.dodge_chance * 100)
	attack_speed.text = "%.2f" % character_stats.attack_speed
	movement_speed.text = "%.2f" % character_stats.movement_speed
	attack_range.text = "%.2f" % character_stats.attack_range
	status_resist.text = "%.2f%%" % (character_stats.status_resist * 100)
	effect_power.text = "%.2f" % character_stats.effect_power
