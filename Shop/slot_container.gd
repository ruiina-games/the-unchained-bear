extends HBoxContainer
class_name SlotContainer

signal slot_clicked(upgrade: Upgrade, slot_type: int)

@export var default_icon: Texture2D

@export var slot: Upgrade.SLOT_TYPE = Upgrade.SLOT_TYPE.NONE  # Тип слота (голова, тіло, ноги тощо)
@export var item: StatUpgrade  # Предмет, який знаходиться у слоті

@onready var icon: TextureRect = %Icon
@onready var item_name: Label = %ItemName
@onready var slot_name: Label = %SlotName
@onready var stats: Label = %StatsName

func _ready():
	update_ui()  # Оновлюємо інтерфейс при створенні панелі

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		if item != null and slot != Upgrade.SLOT_TYPE.FIGHTING_STYLE:
			slot_clicked.emit(item, slot)

# Оновлюємо інтерфейс на основі даних предмета
func update_ui() -> void:
	if item:
		# Заповнюємо іконку (якщо вона є)
		item.load_icon()
		if item.icon_texture:
			icon.texture = item.icon_texture

		# Заповнюємо назву предмета
		item_name.text = item.name
		print(item.name)

		# Заповнюємо назву слота
		slot_name.text = format_text(StatUpgrade.SLOT_TYPE.keys()[slot])
	
		# Заповнюємо статистику предмета як тултіп
		var stats_text = ""
		for stat in item.upgrade_array:
			var stat_name = StatUpgrade.UPGRADABLE_STATS.keys()[stat.stat_type - 1]
			var stat_value = stat.multiplier
			stats_text += format_text(stat_name) + ": " + format_stat_value(stat.stat_type, stat_value) + "\n"
		tooltip_text = stats_text.strip_edges()
		stats.text = ""
	else:
		item_name.text = "Empty"
		slot_name.text = format_text(Upgrade.SLOT_TYPE.keys()[slot])
		tooltip_text = ""
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

func _make_custom_tooltip(for_text: String) -> Control:
	if for_text.is_empty():
		return null
	var panel = PanelContainer.new()
	var style = StyleBoxFlat.new()
	style.bg_color = Color(0.1, 0.1, 0.1, 0.95)
	style.border_color = Color(1, 0.95, 0.7, 0.8)
	style.set_border_width_all(3)
	style.set_corner_radius_all(6)
	style.set_content_margin_all(16)
	panel.add_theme_stylebox_override("panel", style)
	var label = Label.new()
	label.text = for_text
	label.add_theme_font_size_override("font_size", 32)
	label.add_theme_color_override("font_color", Color(1, 0.95, 0.7, 1))
	panel.add_child(label)
	return panel

static func format_stat_value(stat_type: int, value: float) -> String:
	match stat_type:
		StatUpgrade.UPGRADABLE_STATS.MAX_HEALTH:
			return str(int(value))
		StatUpgrade.UPGRADABLE_STATS.CRITICAL_CHANCE, StatUpgrade.UPGRADABLE_STATS.DODGE_CHANCE:
			return str(int(value * 100)) + "%"
		_:
			return "x" + str(snapped(value, 0.01))
