extends GridContainer

@export var character_stats: CharacterStats

@onready var attack_power_multiplier: Label = %strength
@onready var max_health: Label = %"max health"
@onready var current_health: Label = %"current health"
@onready var critical_chance: Label = %"critical chance"
# @onready var critical_damage_multiplier: Label = %"critical damage"
@onready var dodge_chance: Label = %"dodge chance"
# @onready var attack_speed_multiplier: Label = %"attack speed"
@onready var movement_speed_multiplier: Label = %"movement speed"
# @onready var attack_range: Label = %"attack range"
@onready var status_resist_multiplier: Label = %"status resist"
@onready var effect_power_multiplier: Label = %"effect power"

func update_stats_display() -> void:
	if !character_stats:
		return
		
	# Update each label with corresponding stat value
	attack_power_multiplier.text = str(character_stats.attack_power_multiplier)
	max_health.text = str(character_stats.max_health)
	current_health.text = str(character_stats.current_health)
	critical_chance.text = str(character_stats.critical_chance)
	critical_damage_multiplier.text = str(character_stats.critical_damage_multiplier)
	dodge_chance.text = str(character_stats.dodge_chance)
	movement_speed_multiplier.text = str(character_stats.movement_speed_multiplier)
	status_resist_multiplier.text = str(character_stats.status_resist_multiplier)
	effect_power_multiplier.text = str(character_stats.effect_power_multiplier)

# Call this in _ready()
func _ready() -> void:
	if !character_stats:
		return
	character_stats.stats_upgraded.connect(func():
		update_stats_display()
		)
	# update_stats_display()

# You might also want to call this whenever character_stats are updated
func _on_character_stats_changed() -> void:
	update_stats_display()
