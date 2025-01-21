extends Character
class_name BeastTameress

func perform_kick():
	if !character_stats:
		return
	
	character_stats.fighting_style.combo_count = -1
