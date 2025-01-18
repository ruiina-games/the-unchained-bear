extends Node
class_name HealthComponent

signal got_hit(enemy: Character)

@export var agent :Character

func _ready() -> void:
	if !agent:
		print(name + " doesn't have an agent")
		return

func apply_damage(damage_component :DamageComponent):
	if !agent:
		print(name + " doesn't have an agent")
		return

	var damage =  damage_component.get_damage_amount()
	var damage_causer = damage_component.get_damage_causer()
	
	var current_hp: float = agent.character_stats.current_health
	var max_hp: float = agent.character_stats.max_health
	
	current_hp = clampf(current_hp - damage, 0, max_hp)
	
	got_hit.emit(damage_causer)
	
	if current_hp <= 0:
		# Helpers.slow_motion_start(0.2, 0.2)
		
		if !agent.has_signal("died"):
			return

		agent.died.emit(agent)
		return

func heal(heal_amount :float):
	if !agent:
		print(name + " doesn't have an agent")
		return
	
	var current_hp: float = agent.character_stats.current_health
	current_hp = clampf(current_hp + heal_amount, current_hp, heal_amount)
