extends Node
class_name HealthComponent

signal got_hit(enemy: Character)

@export var agent: Character
var enemy: Character

func _ready() -> void:
	if !agent:
		print(name + " doesn't have an agent")
		return

func apply_damage(_enemy: Node2D, _object: ThrowingObject):
	if !agent:
		print(name + " doesn't have an agent")
		return
	if !_enemy:
		return
		
	enemy = _enemy

	if check_dodge():
		return

	var damage_effect: Damage = enemy.character_stats.fighting_style.get_damage()
	if _object:
		damage_effect = enemy.character_stats.fighting_style.get_damage_at_index(_object.damage_index)
	
	process_effects(enemy.character_stats, damage_effect)

	if agent.character_stats.current_health <= 0:
		handle_death()

func check_dodge() -> bool:
	if randf() < agent.character_stats.dodge_chance:
		agent.dodge_attack()
		return true
	return false

func process_effects(enemy_stats: CharacterStats, damage: Damage):
	apply_direct_damage(enemy_stats, damage)
	apply_negative_effects(enemy_stats, damage.effect)

func apply_direct_damage(enemy_stats: CharacterStats, damage: Damage):
	var agent_stats: CharacterStats = agent.character_stats

	var is_critical: bool = randf() < enemy_stats.critical_chance
	var critical_multiplier: float = 1.0
	
	if is_critical:
		print("FUCK IT IS CRITICAL")
		GlobalSignals.player_crit.emit(agent)
		critical_multiplier = enemy_stats.critical_damage_multiplier
		
	var base_damage: float = damage.get_damage_amount() * critical_multiplier * enemy_stats.attack_power_multiplier
	base_damage *= (1 - agent_stats.status_resist_multiplier)

	agent_stats.take_damage(base_damage)

func apply_negative_effects(enemy_stats: CharacterStats, negative_effect: NegativeEffect):
	if !negative_effect or randf() >= negative_effect.base_proc_chance:
		return
	
	# Перевіряємо чи ефект вже активний
	if agent.effects_dic.has(negative_effect):
		if agent.effects_dic[negative_effect] == true:
			return
			
	agent.activate_effect(negative_effect)

	var agent_stats: CharacterStats = agent.character_stats
	var effect_multiplier: float = enemy_stats.effect_power_multiplier
	var agent_effect_resistance: float = agent_stats.status_resist_multiplier

	effect_multiplier = clampf(effect_multiplier - agent_effect_resistance, 0, effect_multiplier)

	if negative_effect is TickingNegativeEffect:
		process_ticking_effects(negative_effect, effect_multiplier)
		# Тікаючі ефекти деактивуються самі після завершення циклу тіків

	elif negative_effect is Knockback:
		process_knockback_effect(negative_effect, effect_multiplier)
		# Нокбек - одноразова дія, можна деактивувати одразу
		agent.deactivate_effect(negative_effect)

	elif negative_effect is SlowEffect:
		process_slow_effect(negative_effect, effect_multiplier)
		# SlowEffect деактивується після таймера

	elif negative_effect is StunEffect:
		process_stun_effect(negative_effect, effect_multiplier)
		# StunEffect деактивується після таймера

func process_slow_effect(effect: SlowEffect, multiplier: float):    
	var slow_ratio = effect.slow_ratio * multiplier
	var original_multiplier: float = agent.character_stats.reserve_copy.movement_speed_multiplier
	
	agent.character_stats.movement_speed_multiplier = (1 - slow_ratio)
	await get_tree().create_timer(effect.duration * multiplier).timeout
	agent.character_stats.movement_speed_multiplier = original_multiplier
	agent.deactivate_effect(effect)  # Деактивуємо ефект після закінчення уповільнення

func process_stun_effect(effect: StunEffect, multiplier: float):
	agent.got_stunned.emit(true)
	print(agent.name + " Was Stunned")
	await get_tree().create_timer(effect.duration * multiplier).timeout
	print(agent.name + " Stun finished")
	agent.got_stunned.emit(false)
	agent.deactivate_effect(effect)  # Деактивуємо ефект після закінчення стану

func process_ticking_effects(effect: TickingNegativeEffect, multiplier: float):
	var tick_count: int = int(effect.get_ticks_amount() * multiplier)
	var tick_interval: float = effect.get_tick_interval() * multiplier

	if effect is FireEffect:
		for i in range(tick_count):
			if agent.round_finished:
				break
			await get_tree().create_timer(tick_interval).timeout
			var adjusted_damage = effect.base_damage * multiplier
			agent.character_stats.take_damage(adjusted_damage)
			if agent.character_stats.current_health <= 0:
				handle_death()
				break
		agent.deactivate_effect(effect)  # Деактивуємо вогонь після всіх тіків

	elif effect is BleedingEffect:
		for i in range(999999):
			if agent.round_finished:
				break
			await get_tree().create_timer(tick_interval).timeout
			var bleeding_damage = effect.calculate_damage(agent.character_stats.max_health)
			bleeding_damage *= multiplier
			agent.character_stats.take_damage(bleeding_damage)
			if agent.character_stats.current_health <= 0:
				handle_death()
				break
		agent.deactivate_effect(effect)  # Деактивуємо кровотечу після всіх тіків

func process_knockback_effect(effect: Knockback, multiplier: float):
	var knockback_force = effect.knockback_force * multiplier
	knockback_force *= (1 - agent.character_stats.status_resist_multiplier)
	var knockback_direction: Vector2 = enemy.global_position.direction_to(agent.global_position).normalized()
	# print(knockback_direction.normalized())
	knockback_direction.y = 0
	agent.got_knocked.emit(knockback_direction, knockback_force)

func handle_death():
	if !agent.is_dead:
	# Вимикаємо всі ефекти перед смертю
		GlobalSignals.character_died.emit(agent)
		agent.died.emit()
		agent.is_dead = true

func heal(heal_amount: float):
	if !agent:
		print(name + " doesn't have an agent")
		return

	var current_hp: float = agent.character_stats.current_health
	agent.character_stats.current_health = clamp(current_hp + heal_amount, 0, agent.character_stats.max_health)
