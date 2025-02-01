extends Node2D

signal next_stage
signal run_out_of_items

@export var shop_items_amount: int = 6  # Кількість предметів у магазині
@export var teddy: Teddy
@export var wheel: SpinWheel

@export var shop_item_panel_scene: PackedScene  # Сцена для панелі предмета
@export var slot_container_scene: PackedScene
@export var inventory_item_scene: PackedScene

@onready var shop_grid: GridContainer = %ShopGrid  # GridContainer для панелей
@onready var player_controller = $PlayerController
@onready var animation_player = $AnimationPlayer
@onready var hint_label = %HintLabel
@onready var question_label = %QuestionLabel
@onready var inventory = $CanvasLayer/Inventory
@onready var inv_label = %InvLabel
@onready var shop: Control = %Shop
@onready var equiped_container: VBoxContainer = %EquipedContainer
@onready var inventory_grid_container: GridContainer = %InventoryGridContainer

@onready var head_slot: SlotContainer = %HeadSlot
@onready var body_slot: SlotContainer = %BodySlot
@onready var legs_slot: SlotContainer = %LegsSlot
@onready var fighting_style: SlotContainer = %FightingStyle

var player_stats: PlayerStats
var shop_active: bool = false
var if_on_exit: bool = false
var if_on_inventory: bool = false
var inventory_is_open: bool = false
var transition_completed: bool = false

func _ready():
	inventory.hide()
	inv_label.hide()
	player_stats = player_controller.actor.character_stats
	wheel.current_chatacter_stats = player_stats
	wheel.place_resources()
	transition_completed = false
	animation_player.play("APPEAR")
	player_controller.hp_bar_container.visible = false

	# Створюємо панелі для магазину
	create_shop_panels()
	create_item_slots()
	fill_the_inventory()
	
	player_stats.inventory_updated.connect(func():
		create_item_slots()
		fill_the_inventory()
	)
	
	ShopManager.assortment_updated.connect(func():
		delete_shop_panels()
		create_shop_panels()
	)
	
func fill_the_inventory():
	for item in inventory_grid_container.get_children():
		item.queue_free()
	
	if !player_stats:
		return
		
	var inventory: Array[Upgrade] = player_stats.inventory
	for item in inventory:
		var inventory_item_scene_instance: InventoryItem = inventory_item_scene.instantiate()
		inventory_item_scene_instance.item = item
		inventory_item_scene_instance.inventory_btn_clicked.connect(func(item):
			player_stats.equip_upgrade(item)
		)
		inventory_grid_container.add_child(inventory_item_scene_instance)
		inventory_item_scene_instance.update_ui()
		
func create_item_slots():
	if !slot_container_scene:
		print("no ", slot_container_scene)
		return
		
	for slot in equiped_container.get_children():
		match slot.slot:
			Upgrade.SLOT_TYPE.HEAD:
				head_slot.item = player_stats.head_slot
			Upgrade.SLOT_TYPE.BODY:
				head_slot.item = player_stats.body_slot
			Upgrade.SLOT_TYPE.LEGS:
				head_slot.item = player_stats.legs_slot
			Upgrade.SLOT_TYPE.FIGHTING_STYLE:
				head_slot.item = player_stats.fighting_style
		slot.update_ui()

# Створюємо панелі для магазину
func create_shop_panels():
	var upgrades_arr: Array[ShopUpgrade] = ShopManager.get_shop_assortment(shop_items_amount)
	
	# Забезпечуєм, що кількість предметів достатня для того, аби їх вивести
	if upgrades_arr.size() < shop_items_amount:
		shop_items_amount = upgrades_arr.size()
		
		if shop_items_amount == 0:
			print("items finished")
			run_out_of_items.emit()
		
	for i in range(shop_items_amount):
		# Створюємо нову панель
		var shop_item_panel: ShopItemPanel = shop_item_panel_scene.instantiate()
		shop_item_panel.player_stats = player_stats
		shop_grid.add_child(shop_item_panel)

		var item: ShopUpgrade = upgrades_arr[i]

		# Призначаємо предмет панелі
		shop_item_panel.item = item
		shop_item_panel.update_ui()  # Оновлюємо інтерфейс панелі

		# Підключаємо сигнали
		item.connect("updated", Callable(shop_item_panel, "update_ui"))
	
func delete_shop_panels():
	for child in %ShopGrid.get_children():
		child.queue_free()
	
# Решта коду залишається без змін
func connect_signals(main: Node):
	connect("next_stage", Callable(main, "_on_next_stage"))

func _on_shop_area_body_entered(body):
	shop_active = true
	hint_label.visible = true

func _on_shop_area_body_exited(body):
	shop_active = false
	hint_label.visible = false

func _on_wheel_area_body_entered(body):
	wheel.area_entered = true
	hint_label.visible = true

func _on_wheel_area_body_exited(body):
	wheel.area_entered = false
	hint_label.visible = false

func _unhandled_input(event):
	if shop_active:
		if event.is_action_pressed("interact"):
			%Shop.visible = true
			teddy.animation_player.play("greetings")
		elif event.is_action_pressed("pause"):
			%Shop.visible = false

	if event.is_action_pressed("interact") and if_on_exit:
		animation_player.play("DISSAPEAR")
		
	if event.is_action_pressed("inv"):
		if if_on_inventory and !inventory_is_open:
			inventory.show()
			player_controller.process_mode = Node.PROCESS_MODE_DISABLED
			%Camera2D.position = Vector2(1019, -287)
			%Camera2D.zoom = Vector2(0.4, 0.4)
			inventory_is_open = true
		elif inventory_is_open:
			inventory.hide()
			player_controller.process_mode = Node.PROCESS_MODE_ALWAYS
			%Camera2D.position = Vector2(24, -367)
			%Camera2D.zoom = Vector2(0.34, 0.34)
			inventory_is_open = false

func _on_next_stage_area_body_entered(body):
	if_on_exit = true
	question_label.show()

func _on_next_stage_area_body_exited(body):
	if_on_exit = false
	if question_label:
		question_label.hide()

func transition_complete():
	transition_completed = true
	next_stage.emit()

func _on_inventory_area_body_entered(body):
	if_on_inventory = true
	inv_label.show()

func _on_inventory_area_body_exited(body):
	if_on_inventory = false
	inv_label.hide()

func _on_leave_inventory_button_pressed():
	inventory.hide()
	player_controller.process_mode = Node.PROCESS_MODE_ALWAYS
	%Camera2D.position = Vector2(24, -367)
	%Camera2D.zoom = Vector2(0.34, 0.34)
	inventory_is_open = false
