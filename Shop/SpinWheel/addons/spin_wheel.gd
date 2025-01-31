extends Control
class_name SpinWheel

@export var is_spin: bool = false
@export var speed: int = 10
@export var power: int = 2
@export var reward_position = 0

var area_entered: bool = false

signal receive_reward(item)

var rewards = [
	{
		"name": "Dark blue",
		"from": 0,
		"to": 45,
	},
	{
		"name": "Dark green",
		"from": 45,
		"to": 90,
	},
	{
		"name": "Blue",
		"from": 90,
		"to": 135,
	},
	{
		"name": "Yellow",
		"from": 135,
		"to": 180,
	},
	{
		"name": "Purple",
		"from": 180,
		"to": 225,
	},
	{
		"name": "Green",
		"from": 225,
		"to": 270,
	},
	{
		"name": "Orange",
		"from": 270,
		"to": 315,
	},
	{
		"name": "Pink",
		"from": 315,
		"to": 360,
	}
	]

func _unhandled_input(event):
	if area_entered:
		if event.is_action_pressed("interact"):
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

				for item in rewards:
					if reward_position >= item.from - 22.5 and reward_position <= item.to - 22.5:
						# print(item.name)
						#signal for another scene
						receive_reward.emit(item)
				tween.tween_property(%front, "rotation_degrees", reward_position +  360 * speed * power , 3).set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_CIRC)
				tween.finished
