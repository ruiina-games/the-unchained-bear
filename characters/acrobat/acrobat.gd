extends Character
class_name Acrobat

signal ready_to_throw_object()

@onready var throwing_hand: Bone2D = %WristR
@export var object_to_throw_scene: PackedScene

# var object: RigidBody2D
var objects_container: Node2D

func ready_to_throw():
	ready_to_throw_object.emit()

func break_object():
	object.break_object()

func throw_object(direction: Vector2, container: Node2D):
	var object = object_to_throw_scene.instantiate()
	container.add_child(object)
	object.hitbox.agent = self

	# Визначаємо базову силу кидка
	var base_force = Vector2()  # Початкова сила
	var torque = 0  # Крутний момент
	var random_factor = 1.0  # Рандомний фактор для варіативності

	match character_stats.fighting_style.combo_count:
		0:
			# Найлегший прямий кидок
			base_force = direction * 5000  # Менша сила
			torque = 250  # Невелике крутіння
		1:
			# Середньої сили прямий кидок
			base_force = direction * 7500  # Середня сила
			torque = 500  # Невелике крутіння
		2:
			# Найпотужніший кидок
			base_force = direction * 9000  # Велика сила
			torque = 800  # Сильне крутіння
		3:
			# Кидок сильно вгору з невеликим горизонтальним рухом
			var upward_force = Vector2(0, -1) * 12000  # Сила вгору
			var side_force = direction * 400  # Невелика сила вбік
			base_force = upward_force + side_force  # Комбінуємо сили
			torque = 300  # Сильне крутіння
			random_factor = randf_range(0.4, 1.6)  # Рандомний фактор для варіативності
			if object is Keglia:
				object.set_on_fire()

	# Застосовуємо рандомний фактор до сили та крутіння
	base_force *= random_factor
	torque *= random_factor

	# Встановлюємо початкову позицію та імпульс
	object.node_to_attach_to = null
	object.global_transform = throwing_hand.global_transform
	object.damage = character_stats.fighting_style.get_damage()
	object.apply_impulse(base_force)
	object.apply_torque_impulse(torque)

func charge():
	character_stats.fighting_style.combo_count = -2
	var og_frames: int = frames_to_activate_attack_for
	frames_to_activate_attack_for = 30
	attack()
	frames_to_activate_attack_for = og_frames
