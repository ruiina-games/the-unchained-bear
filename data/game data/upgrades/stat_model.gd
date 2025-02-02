# Model for applying upgrades.
# Contains stat_type, as well as multiplier.
# Used for upgrading stats via Upgrade.

extends Resource
class_name StatModel

@export var stat_type: StatUpgrade.UPGRADABLE_STATS
@export var multiplier: float

var previous_multiplier: float

# Конструктор для зручного створення StatModel
func _init(p_stat_type: StatUpgrade.UPGRADABLE_STATS = StatUpgrade.UPGRADABLE_STATS.MAX_HEALTH, p_multiplier: float = 0) -> void:
	stat_type = p_stat_type
	multiplier = p_multiplier
