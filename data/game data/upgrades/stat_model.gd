# Model for applying upgrades.
# Contains stat_type, as well as multiplier.
# Used for upgrading stats via Upgrade.

extends Resource
class_name StatModel

@export var stat_type: Upgrade.UPGRADABLE_STATS
@export var multiplier: float
