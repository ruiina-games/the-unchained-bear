extends RigidBody2D
class_name ThrowingObject

@onready var hitbox: Hitbox = $Hitbox
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var damage: Damage
var was_thrown: bool = false
var force: Vector2 = Vector2.ZERO
var node_to_attach_to: Node2D

func _physics_process(delta: float) -> void:
	if !node_to_attach_to:
		return
	global_position = node_to_attach_to.global_position

func break_object():
	animated_sprite_2d.play("break")
	animated_sprite_2d.animation_finished.connect(func():
		queue_free()
		)
