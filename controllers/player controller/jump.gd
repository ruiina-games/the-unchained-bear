extends PlayerState

var was_on_floor: bool = true
var is_falling :bool = false:
	set(value):
		if value == true and is_falling == false:
			is_falling = true
			state_machine.switch_state("land")
var previous_x_velocity: float 
func _enter() -> void:
	super()
	previous_x_velocity = controller.current_velocity.x
	controller.current_velocity.x = 0
	animation_tree.animation_finished.connect(func(anim_name: String):
		var anim_name_suffix = anim_name.substr(anim_name.length() - animation_state_name.length(), animation_state_name.length())
		if anim_name_suffix.to_lower() == animation_state_name.to_lower():
			controller.current_velocity.y = -controller.jump_force
			controller.current_velocity.x = previous_x_velocity
			state_machine.switch_state("fly")
		elif anim_name_suffix.to_lower() == "land":
			dispatch(state_machine.LANDED)
	)


func _update(delta: float) -> void:
	was_on_floor = character.is_on_floor()
	
	super(delta)
	
	if !was_on_floor and character.is_on_floor():
		is_falling = true
		controller.current_velocity = Vector2.ZERO
		character.velocity = Vector2.ZERO
		state_machine.switch_state("land")
