extends Node2D
class_name Controller

@export var actor: Character
@export var target: Character
@export var hsm: LimboHSM
@export var hp_bar: ProgressBar

var fighting_style: FightingStyle
var _effect_timers: Dictionary = {}

var target_global_position: Vector2
var actor_global_position: Vector2

# Змінні для руху
@export_category("Knockback")
@export var knockback_duration: float = 0.3
@export var max_knockback_speed: float = 3000.0
@export var post_knockback_recovery: float = 0.2

var current_velocity: Vector2 = Vector2.ZERO
var tilt: float = 0.0
var direction: Vector2 = Vector2.RIGHT
var gravity: float = 75.0

func _ready() -> void:
	if !actor:
		push_warning("No actor in " + name)
		return

	connect_signals()

	fighting_style = actor.character_stats.fighting_style
	init_state_machine()

	GlobalSignals.character_died.connect(func(character: Character):
		if character == target:
			target = null
			set_controller_inactive()
		)

	set_hp_label(actor.character_stats.current_health)

func connect_signals():
	actor.got_knocked.connect(func(direction: Vector2, force: float):
		apply_knockback(direction, force)
	)
	actor.died.connect(func():
		disable_all_effects()
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
	actor.character_stats.hp_changed.connect(func(new_hp: int):
		set_hp_label(new_hp)
	)
	if target:
		target.died.connect(func():
			finish_round()
			disable_all_effects()
		)

func disable_all_effects():
	if !is_instance_valid(actor):
		return
	for effect in actor.effects_dic:
		if actor.effects_dic[effect] == true:
			actor.deactivate_effect(effect)

func set_controller_inactive():
	pass

func finish_round():
	actor.round_finished = true

func kill_actor():
	pass

func init_state_machine() -> void:
	pass

# TODO: Тут викликаєш візуальні ефекти/партікли на кожен з Effect.
# Ця функція викликається лише коли ефект вмикається або вимикається.
# Тому треба придумати якийсь переключатель.
func _create_particle_timer(effect: Effect, particles: Array, duration: float):
	# Clean up existing timer for this effect
	if _effect_timers.has(effect):
		var old_timer = _effect_timers[effect]
		if is_instance_valid(old_timer):
			old_timer.stop()
			old_timer.queue_free()
		_effect_timers.erase(effect)

	var duration_timer = Timer.new()
	duration_timer.wait_time = duration
	duration_timer.one_shot = true
	add_child(duration_timer)
	_effect_timers[effect] = duration_timer
	duration_timer.start()

	duration_timer.timeout.connect(func():
		for p in particles:
			if is_instance_valid(p):
				p.emitting = false
		duration_timer.queue_free()
		_effect_timers.erase(effect)
	)

func process_effects(effect: Effect):
	if !is_instance_valid(actor):
		return
	var effect_active = actor.effects_dic[effect]
	if effect is FireEffect:
		var particles = actor.fire_folder.get_children()
		for particle in particles:
			if effect_active:
				particle.lifetime = effect.duration
				particle.emitting = true
			else:
				particle.emitting = false
		if effect_active:
			_create_particle_timer(effect, particles, effect.duration)

	elif effect is BleedingEffect:
		for particle in actor.blood_folder.get_children():
			if effect_active:
				await get_tree().create_timer(0.2).timeout
				particle.emitting = true
			else:
				particle.emitting = false

	elif effect is SlowEffect:
		var particles = actor.slow_folder.get_children()
		for particle in particles:
			if effect_active:
				particle.lifetime = effect.duration
				particle.emitting = true
			else:
				particle.emitting = false
		if effect_active:
			_create_particle_timer(effect, particles, effect.duration)

	elif effect is StunEffect:
		var particles = actor.stun_folder.get_children()
		for particle in particles:
			if effect_active:
				particle.emitting = true
			else:
				particle.emitting = false
		if effect_active:
			_create_particle_timer(effect, particles, effect.duration)

	elif effect is Knockback:
		pass

func set_stunned(stunned: bool):
	pass
	# current_velocity = Vector2.ZERO
	# actor.can_move = !stunned

func set_hp_label(new_hp: int):
	if hp_bar:
		hp_bar.max_value = actor.character_stats.max_health
		hp_bar.value = new_hp
		hp_bar.step = 1

func _process(delta: float) -> void:
	if !target:
		return
	
	target_global_position = target.global_position
	actor_global_position = actor.global_position

func _physics_process(delta: float):
	if !actor:
		return
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
	var original_scale = actor.scale  # Збереження початкового масштабу
	var original_transform = actor.transform
	var original_rotation = actor.rotation  # Збереження початкового обертання
	actor.can_move = false

	var elapsed_time: float = 0.0

	while elapsed_time < knockback_duration:
		var knockback_force = lerp(force, 0.0, elapsed_time / knockback_duration)
		current_velocity = knockback_force * direction
		current_velocity = current_velocity.limit_length(max_knockback_speed)
		elapsed_time += get_physics_process_delta_time()
		await get_tree().process_frame
		actor.velocity = current_velocity
		actor.move_and_slide()

	# Відновлення стану персонажа
	if !is_instance_valid(actor):
		return
	actor.velocity = initial_velocity
	actor.rotation = 0  # Повернути обертання до нормального стану
	# actor.scale = Vector2(1, 1)  # Повернути масштаб до нормального стану
	actor.reset_scale(original_scale, original_rotation)
	await get_tree().create_timer(post_knockback_recovery).timeout
	if !is_instance_valid(actor):
		return
	actor.can_move = true
