extends CharacterBody2D
class_name Character

@export var character_stats: CharacterStats
# @export var movement_stats: MovementStats
@export var animation_tree :AnimationTree
@export var shader_material: ShaderMaterial

func _ready() -> void:
	apply_shader_to_polygons($Polygons)
	# Initializing current health with max health considering we create a character with full HP
	if character_stats:
		character_stats.current_health = character_stats.max_health

func get_anim_tree():
	if animation_tree:
		return animation_tree
		
func attack() -> void:
	pass

func adjust_scale_for_direction(direction):
	if direction.x > 0:
		transform.x.x = -1
	elif direction.x < 0:
		transform.x.x = 1

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
