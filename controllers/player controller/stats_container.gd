extends GridContainer

@export var character_stats: CharacterStats

@onready var attack_power_multiplier: Label = %strength
@onready var max_health: Label = %"max health"
@onready var current_health: Label = %"current health"
@onready var critical_chance: Label = %"critical chance"
# @onready var critical_damage_multiplier: Label = %"critical damage"
@onready var dodge_chance: Label = %"dodge chance"
@onready var attack_speed_multiplier: Label = %"attack speed"
@onready var movement_speed_multiplier: Label = %"movement speed"
@onready var attack_range: Label = %"attack range"
@onready var status_resist_multiplier: Label = %"status resist"
@onready var effect_power_multiplier: Label = %"effect power"
