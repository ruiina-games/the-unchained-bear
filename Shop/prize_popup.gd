extends TextureRect

@export var player_contoller: PlayerController
@export var wheel: SpinWheel

@onready var prize_name = %PrizeName
@onready var prize_icon = %PrizeIcon
@onready var prize_description = %PrizeDescription


func _ready():
	hide()
	wheel.receive_reward.connect(func(reward, item_name): receive_reward(reward, item_name))
	
func receive_reward(reward, item_name):
	show()
	if item_name == "UPGRADE":
		prize_name.text = reward.name + ", " + reward.get_rarity_name(reward.rarity)
		prize_icon.texture = load(reward.icon_folder_path + reward.get_rarity_name(reward.rarity).to_lower() + ".png")
		prize_description.text = reward.description
		player_contoller.actor.character_stats.apply_modifier(reward, true)
		player_contoller.actor.character_stats.stats_upgraded.emit()
	elif item_name == "TOKEN":
		prize_name.text = str(reward) + " "
		prize_icon.texture = load("res://assets/Store/Token.png")
		prize_description.text = "You can use these to re-roll the Wheel"
		player_contoller.actor.character_stats.money_dictionary[1] += reward
		player_contoller.actor.character_stats.stats_upgraded.emit()
	elif item_name == "TICKET":
		prize_name.text = str(reward) + " "
		prize_icon.texture = load("res://assets/Store/Ticket.png")
		prize_description.text = "You can use these to buy from the Teddy"
		player_contoller.actor.character_stats.money_dictionary[0] += reward
		player_contoller.actor.character_stats.stats_upgraded.emit()
	


func _on_button_pressed():
	hide()
