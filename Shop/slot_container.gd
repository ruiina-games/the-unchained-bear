extends HBoxContainer
class_name SlotContainer

@export var default_icon: Texture2D

@export var slot: Upgrade.SLOT_TYPE = Upgrade.SLOT_TYPE.NONE  # Тип слота (голова, тіло, ноги тощо)
@export var item: StatUpgrade  # Предмет, який знаходиться у слоті

@onready var icon: TextureRect = %Icon
@onready var item_name: Label = %ItemName
@onready var slot_name: Label = %SlotName
@onready var stats: Label = %Stats

func _ready():
	update_ui()  # Оновлюємо інтерфейс при створенні панелі

# Оновлюємо інтерфейс на основі даних предмета
func update_ui() -> void:
	if item:
		# Заповнюємо іконку (якщо вона є)
		# item.load_icon()
		if item.icon_texture:
			icon.texture = item.icon_texture

		# Заповнюємо назву предмета
		item_name.text = item.name

		# Заповнюємо назву слота
		slot_name.text = "Slot: " + StatUpgrade.SLOT_TYPE.keys()[slot]

		# Заповнюємо статистику предмета
		var stats_text = ""
		for stat in item.upgrade_array:
			var stat_name = StatUpgrade.UPGRADABLE_STATS.keys()[stat.stat_type]
			var stat_value = stat.multiplier
			stats_text += stat_name + ": " + str(stat_value) + "\n"
		stats.text = stats_text
	else:
		item_name.text = "Empty"
		slot_name.text = "Slot: " + Upgrade.SLOT_TYPE.keys()[slot]
		stats.text = ""
		icon.texture = default_icon

# Оновлюємо предмет у слоті
func set_item(new_item: Upgrade) -> void:
	item = new_item
	update_ui()  # Оновлюємо інтерфейс при зміні предмета№
