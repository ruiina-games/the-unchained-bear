extends GridContainer

@export var character_stats: CharacterStats

@onready var damage_multiplier = %damage_multiplier
@onready var max_health = %"max health"
@onready var dodge_chance = %dodge_chance
@onready var critical_chance = %critical_chance
@onready var current_health = %current_health
@onready var movement_speed = %movement_speed
@onready var critical_damage = %critical_damage
@onready var status_resist = %status_resist
@onready var effect_power = %"effect power"

@onready var tickets_amount = %TicketsAmount
@onready var tokens_amount = %TokensAmount


func update_stats_display() -> void:
	if !character_stats:
		return
	
	# Update each label with corresponding stat value
	damage_multiplier.text = format_multiplier_text(character_stats.attack_power_multiplier)
	max_health.text = str(character_stats.max_health)
	current_health.text = str(character_stats.current_health)
	dodge_chance.text = format_multiplier_text(character_stats.dodge_chance)
	critical_chance.text = format_multiplier_text(character_stats.critical_chance)
	critical_damage.text = format_multiplier_text(character_stats.critical_damage_multiplier)
	movement_speed.text = format_multiplier_text(character_stats.movement_speed_multiplier)
	status_resist.text = format_multiplier_text(character_stats.status_resist_multiplier)
	effect_power.text = format_multiplier_text(character_stats.effect_power_multiplier)
	
	tickets_amount.text = str(character_stats.money_dictionary[0])
	tokens_amount.text = str(character_stats.money_dictionary[1])


# Call this in _ready()
func _ready() -> void:
	if !character_stats:
		return
	character_stats.stats_upgraded.connect(_on_character_stats_changed)
	update_stats_display()
	
# You might also want to call this whenever character_stats are updated
func _on_character_stats_changed() -> void:
	update_stats_display()

func format_multiplier_text(multiplier: float):
	var final_text: String = str(multiplier*100) + "%"
	return final_text
