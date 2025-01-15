extends Controller
class_name BeastTameressController

@export var max_consecutive_hits_can_take: int = 4
@export var animation_tree: AnimationTree

@onready var move_target: Marker2D = $MoveToMarker
@onready var consecutive_hits_reset_timer: Timer = %"Consecutive Hits Reset Timer"
@onready var phase_01: BTState = $LimboHSM/Phase_01

var blackboard: Blackboard
var consecutive_hits: int:
	set(new_value):
		var active_bb: Blackboard = hsm.get_active_state().blackboard
		if active_bb.has_var("consecutive_hits"):
			consecutive_hits = new_value
			active_bb.set_var("consecutive_hits", consecutive_hits)
			print(active_bb.get_var("consecutive_hits"))
			
			if active_bb.get_var("consecutive_hits") > max_consecutive_hits_can_take:
				consecutive_hits = 0
			else:
				if consecutive_hits != 0:
					consecutive_hits_reset_timer.start()

func _ready() -> void:
	consecutive_hits_reset_timer.timeout.connect(_on_consecutive_hits_reset_timer_timeout)
	
	hsm.initialize(self)
	hsm.set_active(true)
	hsm.change_active_state(phase_01)
	
	phase_01.blackboard.set_var("move_target", move_target)

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		move_target.global_position = get_global_mouse_position()
		print(move_target.global_position)

	if event.is_action_pressed("attack"):
		consecutive_hits += 1

func _on_consecutive_hits_reset_timer_timeout():
	consecutive_hits = 0
	print("Boss now can get even more punches!!!")

func get_target_move_position(distance: float):
	var viewport = get_viewport_rect()
	var actor_pos = actor.global_position
	var target_pos = target.global_position
	var new_x: float

	# Чітке визначення поточної відстані
	var current_distance = actor_pos.distance_to(target_pos)
	var direction = (target_pos - actor_pos).normalized()

	# Поріг для уникнення "трусіння"
	var tolerance = 2.0  # Збільшений поріг для точності

	# Якщо відстань у межах допустимого порогу, залишаємося на місці
	if abs(current_distance - distance) <= tolerance:
		print("На потрібній відстані")
		return actor_pos

	# Визначення напряму: рух до цілі або від неї
	if current_distance > distance:
		# Якщо занадто далеко, рухаємося ближче
		new_x = actor_pos.x + direction.x * (current_distance - distance)
	elif current_distance < distance:
		# Якщо занадто близько, рухаємося далі
		new_x = actor_pos.x - direction.x * (distance - current_distance)

	# Перевіряємо, чи є достатньо місця у протилежному напрямку
	if (new_x < 0 or new_x > viewport.size.x):
		# Якщо місця немає, коригуємо напрямок до таргету
		if current_distance > distance:
			new_x = actor_pos.x + direction.x * (current_distance - distance)
		else:
			new_x = actor_pos.x - direction.x * (distance - current_distance)

	# Обмежуємо нову позицію в межах екрану
	new_x = clamp(new_x, 0, viewport.size.x)

	# Оновлюємо позицію об'єкта
	move_target.global_position = Vector2(new_x, actor_pos.y)
	print("Рухаємося до:", move_target.global_position)
	return move_target.global_position
