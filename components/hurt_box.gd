extends Area2D
class_name Hurtbox

@export var agent: Node2D
@export var health_component: HealthComponent

func _ready() -> void:
	connect("area_entered", on_hurtbox_entered)
	connect("area_exited", on_hurtbox_exited)

func on_hurtbox_entered(area: Area2D):
	print(area)
	if area is Hitbox:
		var enemy_hitbox: Hitbox = area
		
		# Agent that got hit
		var hit_agent = enemy_hitbox.agent
		
		# var enemy_damage_component: DamageComponent = enemy_hitbox.damage_component
		# var damage_causer = enemy_damage_component.damage_causer

		# Якщо перевірка пройдена, застосовуємо пошкодження
		# health_component.apply_damage(enemy_damage_component)

func on_hurtbox_exited(area: Area2D):
	pass
