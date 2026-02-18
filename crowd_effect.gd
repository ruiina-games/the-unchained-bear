extends Control
class_name CrowdEffect

@export var player_controller: PlayerController
@export var crowd_anim_player: AnimationPlayer

func _ready():
	GlobalSignals.hurt_triggered.connect(func(causer): if causer and causer.name == "BearNew": crowd_cheer())
	
func crowd_cheer():
	if crowd_anim_player.current_animation == "crowd_cheer":
		return
	
	var random_number = randi_range(0, 11)
	if random_number > 9:
		crowd_anim_player.play("crowd_cheer")
		crowd_anim_player.animation_finished.connect(func(anim_name): if anim_name == "crowd_cheer": crowd_anim_player.play("crowd_idle"))
		
