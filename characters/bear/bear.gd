extends Character
class_name Bear

@export_category("Attack")
@export var frames_to_activate_attack_for: int = 6

@onready var hitbox_collision_shape: CollisionShape2D = $Hitbox/CollisionShape2D

enum STYLES_ID {
	FREESTYLE = 0,
	BOXING = 1,
	LUMBERJACK = 2,
	LEGHAND = 3
}

func attack() -> void:
	hitbox_collision_shape.disabled = false

	# Чекаємо 3 кадри (можна змінити кількість за потреби)
	for i in range(frames_to_activate_attack_for):
		await get_tree().process_frame

	hitbox_collision_shape.disabled = true
