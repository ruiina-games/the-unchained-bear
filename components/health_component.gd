extends Node
class_name HealthComponent

signal got_hit(enemy: Character)

@export var agent: Character
var enemy: Character

func _ready() -> void:
	if !agent:
		print(name + " doesn't have an agent")
		return

func apply_damage(_enemy: Character):
	if !agent:
		print(name + " doesn't have an agent")
		return
		
	if !_enemy:
		return
		
	enemy = _enemy

	if check_dodge():
		return

	var damage_effect: Damage = enemy.character_stats.fighting_style.get_damage()
	process_effects(enemy.character_stats, damage_effect)

	got_hit.emit(enemy)

	if agent.character_stats.current_health <= 0:
		handle_death()

func check_dodge() -> bool:
	if randf() < agent.character_stats.dodge_chance:
		print("Attack dodged!")
		return true
	return false

func process_effects(enemy_stats: CharacterStats, damage: Damage):
	apply_direct_damage(enemy_stats, damage)
	apply_negative_effects(enemy_stats, damage.effect)

func apply_direct_damage(enemy_stats: CharacterStats, damage: Damage):
	var agent_stats: CharacterStats = agent.character_stats

	var is_critical: bool = randf() < enemy_stats.critical_chance
	var critical_multiplier: float = enemy_stats.critical_damage_multiplier if is_critical else 1.0

	var base_damage: float = damage.get_damage_amount() * critical_multiplier
	base_damage *= (1 - agent_stats.status_resist_multiplier)

	agent_stats.take_damage(base_damage)

func apply_negative_effects(enemy_stats: CharacterStats, negative_effect: NegativeEffect):
	if !negative_effect or randf() >= negative_effect.base_proc_chance:
		return

	var effect_multiplier: float = enemy_stats.effect_power_multiplier

	if negative_effect is TickingNegativeEffect:
		process_ticking_effects(negative_effect, effect_multiplier)

	elif negative_effect is Knockback:
		process_knockback_effect(negative_effect, effect_multiplier)

	elif negative_effect is SlowEffect:
		process_slow_effect(negative_effect, effect_multiplier)

	elif negative_effect is StunEffect:
		process_stun_effect(negative_effect, effect_multiplier)

func process_ticking_effects(effect: TickingNegativeEffect, multiplier: float):
	var tick_count: int = int(effect.get_ticks_amount() * multiplier)
	var tick_interval: float = effect.get_tick_interval() * multiplier

	if effect is FireEffect:
		for i in range(tick_count):
			await get_tree().create_timer(tick_interval).timeout
			var adjusted_damage = effect.base_damage * multiplier
			adjusted_damage *= (1 - agent.character_stats.status_resist_multiplier)
			agent.character_stats.take_damage(adjusted_damage)

	elif effect is BleedingEffect:
		for i in range(tick_count):
			await get_tree().create_timer(tick_interval).timeout
			var bleeding_damage = effect.calculate_damage(agent.character_stats.max_health)
			bleeding_damage *= multiplier
			bleeding_damage *= (1 - agent.character_stats.status_resist_multiplier)
			agent.character_stats.take_damage(bleeding_damage)

func process_knockback_effect(effect: Knockback, multiplier: float):
	var knockback_force = effect.knockback_force * multiplier
	knockback_force *= (1 - agent.character_stats.status_resist_multiplier)
	var knockback_direction: Vector2 = enemy.global_position.direction_to(agent.global_position).normalized()
	print(knockback_direction.normalized())
	knockback_direction.y = 0
	agent.got_knocked.emit(knockback_direction, knockback_force)

func process_slow_effect(effect: SlowEffect, multiplier: float):
	var slow_ratio = effect.slow_ratio * multiplier
	agent.character_stats.movement_speed_multiplier *= (1 - slow_ratio)
	await get_tree().create_timer(effect.duration * multiplier).timeout
	agent.character_stats.movement_speed_multiplier /= (1 - slow_ratio)

func process_stun_effect(effect: StunEffect, multiplier: float):
	agent.set_stunned(true)
	await get_tree().create_timer(effect.duration * multiplier).timeout
	agent.set_stunned(false)

func handle_death():
	GlobalSignals.character_died.emit(agent)
	
	if !agent.has_signal("died"):
		return

	agent.died.emit(agent)
	
	print(agent.name + " has died.")

func heal(heal_amount: float):
	if !agent:
		print(name + " doesn't have an agent")
		return

	var current_hp: float = agent.character_stats.current_health
	agent.character_stats.current_health = clamp(current_hp + heal_amount, 0, agent.character_stats.max_health)
