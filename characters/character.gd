extends CharacterBody2D
class_name Character

signal got_knocked()

@export var character_stats: CharacterStats
# @export var movement_stats: MovementStats
@export var animation_tree :AnimationTree
@export var shader_material: ShaderMaterial

@export_category("Attack")
@export var hitbox: Hitbox
@export var frames_to_activate_attack_for: int = 6

@export_category("Health")
@export var health_component: HealthComponent
@export var hurtbox: Hurtbox

var can_move: bool = true

func _ready() -> void:
	apply_shader_to_polygons($Polygons)
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
	
func set_stunned(stunned: bool):
	if animation_tree:
		# animation_tree.set("parameters/stunned", stunned)
		if stunned:
			print(name + " is stunned!")
		else:
			print(name + " is no longer stunned!")

func apply_knockback(direction: Vector2, force: float):
	got_knocked.emit(direction, force)

func reset_scale(original_scale, original_rotation):
	scale = original_scale
	rotation = original_rotation
	rotation = 0  # Скидаємо будь-який попередній нахил

func get_hurt():
	if !animation_tree:
		return
	animation_tree.set("parameters/OneShot/request", AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE)


func _unhandled_input(event):
	if event.is_action_pressed("attack"):
		get_hurt()

func apply_shader_to_polygons(node: Node):
	if !shader_material:
		return
	
	if node is Polygon2D:
		node.material = shader_material
	for child in node.get_children():
		apply_shader_to_polygons(child)
