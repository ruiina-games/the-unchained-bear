extends Character
class_name Monkey

signal ready_to_throw_object()

@onready var throwing_hand: Bone2D = %WristR
@export var object_to_throw_scene: PackedScene

# var object: RigidBody2D
var objects_container: Node2D

func _ready() -> void:
	super()
	
	if !animation_tree:
		animation_tree = %AnimationTree
		
	animation_tree.animation_finished.connect(func(anim_name: String):
		if anim_name.to_lower() == "take_object":
			%AnimationTree.set("parameters/StateMachine/conditions/idle", false)
			%AnimationTree.set("parameters/StateMachine/conditions/take", false)
			%AnimationTree.set("parameters/StateMachine/conditions/throw", true)
		if anim_name.to_lower() == "throw_object":
			%AnimationTree.set("parameters/StateMachine/conditions/idle", true)
			%AnimationTree.set("parameters/StateMachine/conditions/take", false)
			%AnimationTree.set("parameters/StateMachine/conditions/throw", false)
		)

func attack():
	if !object_to_throw_scene:
		return
	
	object = object_to_throw_scene.instantiate()
	object.node_to_attach_to = throwing_hand
	objects_container.add_child(object)
	object.hitbox.agent = self
	ready_to_throw_object.emit()
	
func get_ready_to_throw():
	%AnimationTree.set("parameters/StateMachine/conditions/idle", false)
	%AnimationTree.set("parameters/StateMachine/conditions/take", true)
	
func break_object():
	object.break_object()

func throw_object(direction :Vector2):
	print(direction)
	var force = direction * 2500
	if !object:
		return
	object.node_to_attach_to = null
	object.global_transform = throwing_hand.global_transform
	object.apply_impulse(force)
