extends BaseResource
class_name Upgrade

signal updated()

enum RARITY {
	COMMON = 0,
	UNCOMMON,
	RARE,
	MYTHICAL,
	LEGENDARY
}

enum SLOT_TYPE {
	NONE,  # Не призначено для слота
	HEAD,  # Голова
	BODY,  # ТілоStatStat
	LEGS,   # Ноги
	FIGHTING_STYLE
}

# @export var upgrade_multi_step: float = 1.0
@export var slot_type: SLOT_TYPE = SLOT_TYPE.NONE  # Тип слота для цього апгрейду
@export var icon_folder_path: String  # Шлях до папки з іконками
@export var rarity: RARITY = RARITY.COMMON
@export var default_icon: Texture2D  # Резервна іконка

var icon_texture: Texture2D  # Текстура для зображення рідкості

func initialize_upgrade():
	update_rarity()
	load_icon()  # Завантажуємо іконку при ініціалізації

func load_icon():
	var icon_name = get_rarity_name(rarity).to_lower() + ".png"
	var icon_path = icon_folder_path.path_join(icon_name)
	
	if ResourceLoader.exists(icon_path):
		icon_texture = load(icon_path)
	else:
		print("[", name, "] ", "Icon not found for rarity: ", get_rarity_name(rarity), " at path: ", icon_path)
		icon_texture = default_icon  # Використовуємо резервну іконку

# Повертаємо назву рідкості як рядок
func get_rarity_name(rarity_value: RARITY) -> String:
	return RARITY.keys()[rarity_value]

# Interface
func apply_legendary_effect():
	pass
func update_rarity():
	pass
