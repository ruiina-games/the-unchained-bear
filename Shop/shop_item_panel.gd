extends Panel
class_name ShopItemPanel

@export var item: ShopUpgrade  # Предмет, який продається
@export var player_stats: PlayerStats

@onready var item_name: Label = %ItemName
@onready var slot: Label = %Slot
@onready var rarity: Label = %Rarity
@onready var buy_button: TextureButton = %BuyButton
@onready var price: Label = %Price
@onready var currency: Label = %Currency

func _ready() -> void:
	update_ui()  # Оновлюємо інтерфейс при створенні панелі
	buy_button.pressed.connect(_on_buy_button_pressed)

# Оновлюємо інтерфейс на основі даних предмета
func update_ui() -> void:
	if item:
		# Заповнюємо назву предмета
		item_name.text = item.title

		# Заповнюємо слот (якщо є)
		if item.slot_type != Upgrade.SLOT_TYPE.NONE:
			slot.text = Upgrade.SLOT_TYPE.keys()[item.slot_type]
		else:
			slot.text = "Slot: N/A"
		
		rarity.text = Upgrade.RARITY.keys()[item.rarity]

		# Заповнюємо ціну
		price.text = str(item.cost)

		# Заповнюємо валюту
		currency.text = PlayerStats.MONEY.keys()[item.money_type]
		
		if item.icon_texture:
			buy_button.texture_normal = item.icon_texture

# Перевіряємо, чи може гравець купити предмет
func can_afford() -> bool:
	if item and player_stats:
		return player_stats.money_dictionary[item.money_type] >= item.cost
	return false

# Обробник натискання кнопки купівлі
func _on_buy_button_pressed() -> void:
	if item:
		print("Attempting to purchase: ", item.title)
		if ShopManager.purchase_item(item):  # Викликаємо метод покупки з ShopManager
			print("Purchase successful!")
			update_ui()  # Оновлюємо інтерфейс після покупки
		else:
			print("Purchase failed.")
