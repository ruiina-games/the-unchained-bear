extends GridContainer

@export var character_stats: CharacterStats

@onready var damage_multiplier = %damage_multiplier
@onready var max_health = %"max health"
@onready var dodge_chance = %dodge_chance
@onready var critical_chance = %critical_chance
@onready var movement_speed = %movement_speed
@onready var critical_damage = %critical_damage
@onready var status_resist = %status_resist
@onready var effect_power = %"effect power"

@onready var tickets_amount = %TicketsAmount
@onready var tokens_amount = %TokensAmount


func update_stats_display() -> void:
	if !character_stats:
		return

	damage_multiplier.text = format_multiplier(character_stats.attack_power_multiplier)
	max_health.text = str(int(character_stats.max_health))
	dodge_chance.text = format_chance(character_stats.dodge_chance)
	critical_chance.text = format_chance(character_stats.critical_chance)
	critical_damage.text = format_multiplier(character_stats.critical_damage_multiplier)
	movement_speed.text = format_multiplier(character_stats.movement_speed_multiplier)
	status_resist.text = format_multiplier(character_stats.status_resist_multiplier)
	effect_power.text = format_multiplier(character_stats.effect_power_multiplier)

	tickets_amount.text = str(character_stats.money_dictionary[0])
	tokens_amount.text = str(character_stats.money_dictionary[1])


func _ready() -> void:
	if !character_stats:
		return
	character_stats.stats_upgraded.connect(_on_character_stats_changed)
	update_stats_display()

func _on_character_stats_changed() -> void:
	update_stats_display()

func format_multiplier(value: float) -> String:
	return "x" + str(snapped(value, 0.01))

func format_chance(value: float) -> String:
	return str(int(value * 100)) + "%"
