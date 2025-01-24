extends Character
class_name Lion

func roar():
	if !character_stats:
		return
	
	character_stats.attack_power_multiplier += 0.5
	character_stats.status_resist_multiplier += 0.5
	character_stats.critical_chance += 0.2
	character_stats.effect_power_multiplier += 0.5
	
	character_stats.fighting_style.combo_count = -1
	frames_to_activate_attack_for = 20
	attack()
	frames_to_activate_attack_for = 6

func get_hurt():
	super()
	print("lion get hurt")

func attack():
	var direction_to_enemy: Vector2 = global_position.direction_to(owner.target.global_position).normalized()
	adjust_scale_for_direction(direction_to_enemy)
	super()
