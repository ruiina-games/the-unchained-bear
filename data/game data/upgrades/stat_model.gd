# Model for applying upgrades.
# Contains stat_type, as well as multiplier.
# Used for upgrading stats via Upgrade.

extends Resource
class_name StatModel

@export var stat_type: StatUpgrade.UPGRADABLE_STATS
@export var base_value: float

var multiplier: float
