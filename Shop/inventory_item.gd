extends TextureButton
class_name InventoryItem

signal inventory_btn_clicked(item: Upgrade)

@export var item: Upgrade

func _ready() -> void:
	pressed.connect(func():
		inventory_btn_clicked.emit(item)
	)

func update_ui():
	if !item:
		return
	
	item.load_icon()
	if item.icon_texture:
		texture_normal = item.icon_texture
