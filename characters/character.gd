extends CharacterBody2D
class_name Character

signal got_knocked()
signal got_hit()

signal got_stunned(was_stunned: bool)
signal effect_changes(effect: Effect)
signal died()

@export var character_stats: CharacterStats
@export var animation_tree :AnimationTree
@export var shader_material: ShaderMaterial

@export_category("Attack")
@export var hitbox: Hitbox
@export var frames_to_activate_attack_for: int = 6

@export_category("Health")
@export var health_component: HealthComponent
@export var hurtbox: Hurtbox

@export_category("FX Markers Folders")
@export var blood_folder: Node2D
@export var fire_folder: Node2D
@export var stun_folder: Node2D

var effects_dic: Dictionary

var can_move: bool = true
var is_dead: bool = false
var is_on_floor: bool = false
var object: ThrowingObject = null

func _ready() -> void:
	apply_shader_to_polygons($Polygons)
	# Initializing current health with max health considering we create a character with full HP
	if character_stats:
		character_stats.current_health = character_stats.max_health
		
		if !character_stats.reserve_copy:
			character_stats.reserve_copy = character_stats.duplicate()
		
	if !health_component:
		return
		
	health_component.got_hit.connect(func(enemy):
		get_hurt()
	)
	
	GlobalSignals.reset_stats_all.connect(func():
		character_stats.reset()
	)

func activate_effect(effect: Effect):
	effects_dic[effect] = true
	effect_changes.emit(effect)

func deactivate_effect(effect: Effect):
	effects_dic[effect] = false
	effect_changes.emit(effect)

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

func apply_shader_to_polygons(node: Node):
	if !shader_material:
		return
	
	if node is Polygon2D:
		node.material = shader_material
	for child in node.get_children():
		apply_shader_to_polygons(child)

func perform_kick():
	if !character_stats:
		return
	
	character_stats.fighting_style.combo_count = -1
	attack()
	
func dodge_attack():
	pass
