extends CharacterBody2D
class_name Character

@export var character_stats: CharacterStats
# @export var movement_stats: MovementStats
@export var animation_tree :AnimationTree

@export_category("Attack")
@export var hitbox: Hitbox
@export var frames_to_activate_attack_for: int = 6

@export_category("Health")
@export var health_component: HealthComponent
@export var hurtbox: Hurtbox

func _ready() -> void:
	# Initializing current health with max health considering we create a character with full HP
	if character_stats:
		character_stats.current_health = character_stats.max_health
		#health_component.character_stats = character_stats

func get_anim_tree():
	if animation_tree:
		return animation_tree
		
func attack() -> void:
	if !hitbox:
		print(name + " doesn't have hitbox assigned attack won't infict any damage")
		return
		
	var collision_shape: CollisionShape2D
	
	for child in hitbox.get_children():
		if child is CollisionShape2D:
			collision_shape = child
			break
			
	if !collision_shape:
		return
	
	collision_shape.disabled = false

	# Чекаємо 3 кадри (можна змінити кількість за потреби)
	for i in range(frames_to_activate_attack_for):
		await get_tree().process_frame

	collision_shape.disabled = true

func adjust_scale_for_direction(direction):
	if direction.x > 0:
		transform.x.x = -1
	elif direction.x < 0:
		transform.x.x = 1
