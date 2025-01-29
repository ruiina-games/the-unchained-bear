extends Node2D
class_name Controller

@export var actor: Character
@export var target: Character
@export var hsm: LimboHSM
@export var hp_label: Label

var fighting_style: FightingStyle

var target_global_position: Vector2
var actor_global_position: Vector2

# Змінні для руху
var current_velocity: Vector2 = Vector2.ZERO
var tilt: float = 0.0
var direction: Vector2 = Vector2.RIGHT
var gravity: float = 75.0

func _ready() -> void:
	if !target:
		print("Target in " + name + " is missing. Unable to initialize character")
		get_tree().quit()
	if !actor:
		print("No actor in " + name)
		get_tree().quit()
		
	connect_signals()
	
	fighting_style = actor.character_stats.fighting_style
	init_state_machine()
	
	GlobalSignals.character_died.connect(func(character: Character):
		if character == target:
			target = null
			set_controller_inactive()
		)

func connect_signals():
	actor.got_knocked.connect(func(direction: Vector2, force: float):
		apply_knockback(direction, force)
	)
	actor.died.connect(func():
		kill_actor()
	)
	actor.got_stunned.connect(func(was_stunned: bool):
		set_stunned(was_stunned)
	)
	actor.effect_changes.connect(func(effect: Effect):
		process_effects(effect)
	)
	actor.character_stats.got_hit.connect(func():
		actor.get_hurt()
	)

func set_controller_inactive():
	pass

func kill_actor():
	pass

func init_state_machine() -> void:
	pass

# TODO: Тут викликаєш візуальні ефекти/партікли на кожен з Effect.
# Ця функція викликається лише коли ефект вмикається або вимикається.
# Тому треба придумати якийсь переключатель.
func process_effects(effect: Effect):
	if effect is FireEffect:
		var duration_timer = Timer.new()
		duration_timer.wait_time = effect.duration
		add_child(duration_timer)
		duration_timer.start()
		
		duration_timer.timeout.connect(func():
			for particle in actor.fire_folder.get_children():
				particle.emitting = false
			)
		for particle in actor.fire_folder.get_children():
			if particle.emitting == true:
				particle.lifetime += effect.duration
				
			particle.lifetime = effect.duration
			particle.emitting = true

	elif effect is BleedingEffect:
		for particle in actor.blood_folder.get_children():
			await get_tree().create_timer(0.2).timeout
			particle.emitting = true
	elif effect is SlowEffect:
		pass
	elif effect is StunEffect:
		var duration_timer = Timer.new()
		duration_timer.wait_time = effect.duration
		add_child(duration_timer)
		duration_timer.start()
		
		duration_timer.timeout.connect(func():
			for particle in actor.stun_folder.get_children():
				particle.emitting = false
			)
		
		for particle in actor.stun_folder.get_children():
			particle.emitting = true
	elif effect is Knockback:
		pass

func set_stunned(stunned: bool):
	pass
	# current_velocity = Vector2.ZERO
	# actor.can_move = !stunned

func _process(delta: float) -> void:
	if !target:
		return
	
	target_global_position = target.global_position
	actor_global_position = actor.global_position
	
	if hp_label and actor.character_stats:
		hp_label.text = str(actor.character_stats.current_health)

func _physics_process(delta: float):
	if actor.global_position.y >= GlobalVariables.FLOOR_HEIGHT:
		actor.global_position.y = GlobalVariables.FLOOR_HEIGHT
		actor.is_on_floor = true
	else:
		current_velocity.y += GlobalVariables.GRAVITY
		actor.is_on_floor = false

func get_hsm():
	if hsm:
		return hsm
	else:
		print("error")
		return

func apply_knockback(direction, force):
	var initial_velocity = actor.velocity

	var original_scale = actor.scale  # Збереження початкового напрямку
	var original_rotation = actor.rotation
	actor.can_move = false
	var knockback_duration: float = 0.3  # Duration of the knockback effect
	var elapsed_time: float = 0.0
	
	while elapsed_time < knockback_duration:
		var knockback_force = lerp(force, 0.0, elapsed_time / knockback_duration)
		current_velocity = knockback_force * direction
		elapsed_time += get_physics_process_delta_time()
		await get_tree().process_frame
		actor.velocity = current_velocity
		actor.move_and_slide()

	actor.velocity = initial_velocity
	actor.reset_scale(original_scale, original_rotation)
	actor.can_move = true
