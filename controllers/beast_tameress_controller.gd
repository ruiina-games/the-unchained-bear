extends Controller
class_name BeastTameressController

@export var max_consecutive_hits_can_take: int = 4
@export var animation_tree: AnimationTree
@export var attack_range: float = 1500

@onready var consecutive_hits_reset_timer: Timer = %"Consecutive Hits Reset Timer"
@onready var phase_01: BTState = $LimboHSM/Phase_01

@onready var label: Label = %Label

var blackboard: Blackboard
var consecutive_hits: int:
	set(new_value):
		var active_bb: Blackboard = hsm.get_active_state().blackboard
		if active_bb.has_var("consecutive_hits"):
			consecutive_hits = new_value
			active_bb.set_var("consecutive_hits", consecutive_hits)
			# print(active_bb.get_var("consecutive_hits"))
			
			if active_bb.get_var("consecutive_hits") > max_consecutive_hits_can_take:
				consecutive_hits = 0
			else:
				if consecutive_hits != 0:
					consecutive_hits_reset_timer.start()

func _ready() -> void:
	super()
	consecutive_hits_reset_timer.timeout.connect(_on_consecutive_hits_reset_timer_timeout)
	
	hsm.initialize(self)
	hsm.set_active(true)
	hsm.change_active_state(phase_01)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("attack"):
		consecutive_hits += 1

func _on_consecutive_hits_reset_timer_timeout():
	consecutive_hits = 0
	print("Boss now can get even more punches!!!")

func get_target_move_position():
	if !target:
		return Vector2.ZERO
	
	var viewport = get_viewport_rect()
	var actor_pos = actor.global_position
	var target_pos = target.global_position

	# Визначення напрямку від боса до гравця
	var direction_to_target = actor_pos.direction_to(target_pos)

	# Розрахунок цільової позиції, яка знаходиться на відстані attack_range від target
	var target_position: Vector2 = calculate_target_position(actor_pos, target_pos, direction_to_target)

	# Перевіряємо, чи цільова позиція знаходиться в межах viewport
	if target_position.x <= -2000 || target_position.x >= 2000:
		direction_to_target = -direction_to_target
		target_position = calculate_target_position(actor_pos, target_pos, direction_to_target)
	
	return target_position

func calculate_target_position(
	actor_pos: Vector2,
	target_pos: Vector2,
	direction_to_target: Vector2
) -> Vector2:
	# Нормалізуємо напрямок, щоб отримати одиничний вектор
	var dir = direction_to_target.normalized()
	# Віднімаємо від x координати цілі (target_pos.x) 
	# нормалізований напрямок, помножений на attack_range
	var new_x = target_pos.x + dir.x * attack_range
	var new_y = actor_pos.y  # або target_pos.y, залежно від того, чого хочете досягти
	
	return Vector2(new_x, new_y)
	
func look_at_target(target_position: Vector2):
	var look_at_direction = actor.global_position.direction_to(target_position)
	actor.adjust_scale_for_direction(look_at_direction)

func attack_notify(inform_text: String, inform_duration: float):
	label.text = inform_text
	await get_tree().create_timer(inform_duration).timeout
	label.text = ""
	
func apply_knockback(direction, force):
	direction = direction.normalized()
	var knockback_duration: float = 0.3  # Duration of the knockback effect
	var elapsed_time: float = 0.0
	var initial_velocity = actor.velocity

	while elapsed_time < knockback_duration:
		var knockback_force = lerp(force, 0.0, elapsed_time / knockback_duration)
		actor.velocity = direction * knockback_force
		elapsed_time += get_physics_process_delta_time()
		await get_tree().process_frame
		actor.move_and_slide()

	actor.velocity = initial_velocity
	print(name + " is knocked back with force: " + str(force))
