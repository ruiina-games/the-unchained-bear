extends Control
class_name SpinWheel

@export var is_spin: bool = false
@export var speed: int = 10
@export var power: int = 2
@export var reward_position = 0


@onready var dark_green_slot = %DarkGreenSlot
@onready var dark_blue_slot = %DarkBlueSlot
@onready var pink_slot = %PinkSlot
@onready var orange_slot = %OrangeSlot
@onready var green_slot = %GreenSlot
@onready var purple_slot = %PurpleSlot
@onready var blue_slot = %BlueSlot
@onready var yellow_slot = %YellowSlot



var area_entered: bool = false
var current_chatacter_stats: PlayerStats

signal receive_reward(item, item_name)

@onready var rewards = [
	{
		"name": "Dark green",
		"from": 0,
		"to": 45,
		"reward": null,
		"slot": dark_green_slot
	},
	{
		"name": "Yellow",
		"from": 45,
		"to": 90,
		"reward": null,
		"slot": yellow_slot
	},
	{
		"name": "Blue",
		"from": 90,
		"to": 135,
		"reward": null,
		"slot": blue_slot
	},
	{
		"name": "Purple",
		"from": 135,
		"to": 180,
		"reward": null,
		"slot": purple_slot
	},
	{
		"name": "Green",
		"from": 180,
		"to": 225,
		"reward": null,
		"slot": green_slot
	},
	{
		"name": "Orange",
		"from": 225,
		"to": 270,
		"reward": null,
		"slot": orange_slot
	},
	{
		"name": "Pink",
		"from": 270,
		"to": 315,
		"reward": null,
		"slot": pink_slot
	},
	{
		"name": "Dark Blue",
		"from": 315,
		"to": 360,
		"reward": null,
		"slot": dark_blue_slot
	}
	]

func place_resources():
	var indices = []
	var attempts = 0
	var resources = UpgradeManager.get_temporary_upgrades_pool(4, current_chatacter_stats)
	var tickets_array = BonusManager.generate_tickets(2)
	var tokens_array = BonusManager.generate_tokens(2)
	
	while indices.size() < 4 and attempts < 100:  # Запобігаємо нескінченному циклу
		var index = randi() % rewards.size()
		
		# Перевіряємо, чи індекс відповідає умовам
		var valid = true
		
		for i in indices:
			if abs(i - index) <= 0.5:  # Перевіряємо проміжок у один елемент
				valid = false
				break
		
		if valid:
			indices.append(index)
		
		attempts += 1
		
	if indices.size() < 4:
		print("Не вдалося знайти 4 слоти з проміжками для resources.")
		return
		
	# Розміщуємо ресурси на вибрані позиції
	for i in range(indices.size()):
		rewards[indices[i]]["reward"] = resources[i]
		rewards[indices[i]]["name"] = "UPGRADE"
		rewards[indices[i]]["slot"].texture = load(resources[i].icon_folder_path + resources[i].get_rarity_name(resources[i].rarity).to_lower() + ".png")
	
	var remaining_indices = []  # Індекси, які залишилися
	for i in range(rewards.size()):
		if not indices.has(i):  # Якщо слот не зайнятий resources
			remaining_indices.append(i)
	
	# Розподіляємо tickets_array і tokens_array
	for i in range(remaining_indices.size()):
		var index = remaining_indices[i]
		if i < tickets_array[0].size():  # Спочатку tickets_array
			# Вибираємо випадкову нагороду з tickets_array[0]
			var random_reward_index = randi() % tickets_array[0].size()
			rewards[index]["reward"] = tickets_array[0][random_reward_index]
			rewards[index]["name"] = "TICKET"
			rewards[index]["slot"].texture = load("res://assets/Upgrades/RoflTicket.png")
		else:  # Потім tokens_array
			# Вибираємо випадкову нагороду з tokens_array[1]
			var token_index = i - tickets_array[0].size()
			var random_reward_index = randi() % tokens_array[1].size()
			rewards[index]["reward"] = tokens_array[1][random_reward_index]
			rewards[index]["name"] = "TOKEN"
			rewards[index]["slot"].texture = load("res://assets/Upgrades/RoflZheton.png")

func _unhandled_input(event):
	if area_entered:
		if event.is_action_pressed("interact"):
			place_resources()
			if is_spin == false:
				is_spin = true
				var tween = get_tree().create_tween().set_parallel(true)
				tween.connect("finished", func():
					#after tween finish animation, this function is call
					var old_rotation_degrees = %front.rotation_degrees
					#set is_spin = false to tell for user can press again
					is_spin = false
					if old_rotation_degrees > 360:
						#This part is to fix the error that when rotating the steamer once, it will not rotate counterclockwise
						var rad_ = fmod(old_rotation_degrees, 360)
						%front.rotation_degrees = rad_
					)
				reward_position = randi_range(0, 360) #random position from 0 to 360 degrees


				tween.tween_property(%front, "rotation_degrees", reward_position +  360 * speed * power , 3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
				tween.finished.connect(func(): 
					for item in rewards:
						if reward_position >= item.from and reward_position <= item.to:
							if !item.reward:
								print("WOMP WOMP")
							else:
								print(item.reward, item.name)
								#signal for another scene
								receive_reward.emit(item.reward, item.name)
						)
