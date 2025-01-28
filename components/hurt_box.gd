extends Area2D
class_name Hurtbox

@export var agent: Character
@export var health_component: HealthComponent

func _ready() -> void:
	connect("area_entered", on_hurtbox_entered)
	connect("area_exited", on_hurtbox_exited)

func on_hurtbox_entered(area: Area2D):
	if area is Hitbox:
		var enemy_hitbox: Hitbox = area
		var enemy: Character = enemy_hitbox.agent
		var thrown_object: ThrowingObject  = enemy_hitbox.object
		
		health_component.apply_damage(enemy, thrown_object)
		
		GlobalSignals.hurt_triggered.emit(enemy)
		
func on_hurtbox_exited(area: Area2D):
	pass
