extends HBoxContainer
class_name SlotContainer

@export var default_icon: Texture2D

@export var slot: Upgrade.SLOT_TYPE = Upgrade.SLOT_TYPE.NONE  # Тип слота (голова, тіло, ноги тощо)
@export var item: StatUpgrade  # Предмет, який знаходиться у слоті

@onready var icon: TextureRect = %Icon
@onready var item_name: Label = %ItemName
@onready var slot_name: Label = %SlotName
@onready var stats: Label = %StatsName

func _ready():
	update_ui()  # Оновлюємо інтерфейс при створенні панелі

# Оновлюємо інтерфейс на основі даних предмета
func update_ui() -> void:
	if item:
		# Заповнюємо іконку (якщо вона є)
		item.load_icon()
		if item.icon_texture:
			icon.texture = item.icon_texture

		# Заповнюємо назву предмета
		item_name.text = item.name

		# Заповнюємо назву слота
		slot_name.text = format_text(StatUpgrade.SLOT_TYPE.keys()[slot])

		# Заповнюємо статистику предмета
		var stats_text = ""
		for stat in item.upgrade_array:
			var stat_name = StatUpgrade.UPGRADABLE_STATS.keys()[stat.stat_type]
			var stat_value = stat.multiplier
			stats_text += format_text(stat_name) + ": " + format_multiplier_text(stat_value) + "\n"
		stats.text = stats_text
	else:
		item_name.text = "Empty"
		slot_name.text = format_text(Upgrade.SLOT_TYPE.keys()[slot])
		stats.text = ""
		icon.texture = default_icon

# Оновлюємо предмет у слоті
func set_item(new_item: Upgrade) -> void:
	item = new_item
	update_ui()  # Оновлюємо інтерфейс при зміні предмета№
	
func format_text(input_text: String) -> String:
	# Замінити "_" на пробіли
	var text_with_spaces = input_text.replace("_", " ")
	
	# Розділити текст на слова за пробілами
	var words = text_with_spaces.split(" ", false)  # false — щоб уникнути порожніх слів
	
	# Змінна для зберігання результату
	var result = ""
	
	# Пройтися по кожному слову
	for word in words:
		if word.length() > 0:
			# Зробити першу літеру великою, а решту — маленькими
			var formatted_word = word[0].to_upper() + word.substr(1).to_lower()
			result += formatted_word + " "  # Додати пробіл між словами
	
	# Видалити останній пробіл, якщо він є
	return result.strip_edges()

func format_multiplier_text(multiplier: float):
	var final_text: String = str(multiplier*100) + "%"
	return final_text
