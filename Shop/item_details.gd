extends CanvasLayer
class_name ItemDetails

@onready var item: ShopUpgrade

@onready var item_name = %ItemName
@onready var slot = %Slot
@onready var rarity = %Rarity
@onready var texture_rect = %TextureRect
@onready var item_stat = %ItemStat
@onready var description = %Description
@onready var item_price = %ItemPrice



signal item_bought()


func _ready():
	fill_data()

func _on_buy_item_button_pressed():
	if item:
		print("Attempting to purchase: ", item.title)
		if ShopManager.purchase_item(item):  # Викликаємо метод покупки з ShopManager
			print("Purchase successful!")
			item_bought.emit()
			queue_free()
		else:
			print("Purchase failed.")

func _on_cancel_buy_item_button_pressed():
	queue_free()

func fill_data():
	if item:
		item_name.text = item.title
		
		var stats_text = ""
		for stat in item.upgrade_array:
			var stat_name = StatUpgrade.UPGRADABLE_STATS.keys()[stat.stat_type - 1]
			var stat_value = stat.multiplier
			stats_text += format_text(stat_name) + ": " + format_multiplier_text(stat_value) + "\n"
		item_stat.text = stats_text
		
		slot.text = Upgrade.SLOT_TYPE.keys()[item.slot_type] + ", "
		rarity.text = Upgrade.RARITY.keys()[item.rarity]
		texture_rect.texture = item.icon_texture
		description.text = item.description
		item_price.text = str(item.cost)

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
	
