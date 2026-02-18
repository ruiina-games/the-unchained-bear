extends Node2D

@export var player_controller_scene: PackedScene = preload("res://controllers/player controller/player_controller.tscn")
@export var beast_tameress_scene: PackedScene = preload("res://controllers/ai_controllers/beast tameress/beast_tameress_controller.tscn")
@export var animals_duo_scene: PackedScene = preload("res://controllers/ai_controllers/beast tameress/animals_trio_controller.tscn")
@export var acrobat_scene: PackedScene = preload("res://controllers/acrobat controller/acrobat_controller.tscn")

var player_controller: PlayerController
var current_boss: Controller
var god_mode: bool = false
var one_hit_kill: bool = false

@onready var effects_controller: Node2D = $EffectsController
@onready var camera: Camera2D = $Camera2D
@onready var object_spawner: Node2D = $ObjectSpawner
@onready var debug_ui: CanvasLayer = $DebugUI
@onready var stats_label: Label = $DebugUI/Panel/VBox/StatsLabel

func _ready() -> void:
	_spawn_player()
	_setup_debug_ui()
	_update_stats_display()

func _process(_delta: float) -> void:
	_update_stats_display()

func _spawn_player() -> void:
	player_controller = player_controller_scene.instantiate()
	player_controller.position = Vector2(-1273, 380)
	add_child(player_controller)

	effects_controller.player_controller = player_controller
	effects_controller.main_camera = camera
	effects_controller.initialize()

func _despawn_boss() -> void:
	if current_boss:
		current_boss.queue_free()
		current_boss = null

func _spawn_boss(scene: PackedScene, offset: Vector2 = Vector2(1208, 398)) -> void:
	_despawn_boss()

	current_boss = scene.instantiate()
	current_boss.position = offset

	# Wire up target references
	if current_boss.has_node("BeastTamer"):
		current_boss.target = player_controller.actor
	elif current_boss.get("target") != null:
		current_boss.target = player_controller.actor

	if "objects_container" in current_boss:
		current_boss.objects_container = object_spawner

	add_child(current_boss)

func _setup_debug_ui() -> void:
	# Spawn buttons
	_connect_btn("SpawnBeastTameress", func(): _spawn_boss(beast_tameress_scene))
	_connect_btn("SpawnAnimalsDuo", func(): _spawn_boss(animals_duo_scene))
	_connect_btn("SpawnAcrobat", func(): _spawn_boss(acrobat_scene))

	# Toggle buttons
	_connect_btn("GodMode", _toggle_god_mode)
	_connect_btn("OneHitKill", _toggle_one_hit_kill)
	_connect_btn("ResetHP", _reset_hp)

	# Effect buttons
	_connect_btn("ApplyFire", func(): _apply_effect_to_player("fire"))
	_connect_btn("ApplyBleed", func(): _apply_effect_to_player("bleed"))
	_connect_btn("ApplyStun", func(): _apply_effect_to_player("stun"))
	_connect_btn("ApplySlow", func(): _apply_effect_to_player("slow"))

func _connect_btn(btn_name: String, callback: Callable) -> void:
	var btn = debug_ui.find_child(btn_name, true, false)
	if btn:
		btn.focus_mode = Control.FOCUS_NONE
		btn.pressed.connect(callback)

func _toggle_god_mode() -> void:
	god_mode = !god_mode
	if god_mode:
		player_controller.actor.character_stats.current_health = player_controller.actor.character_stats.max_health
	var btn = debug_ui.find_child("GodMode", true, false)
	if btn:
		btn.text = "God Mode: ON" if god_mode else "God Mode: OFF"

func _toggle_one_hit_kill() -> void:
	one_hit_kill = !one_hit_kill
	if one_hit_kill:
		player_controller.actor.character_stats.attack_power_multiplier = 100.0
	else:
		player_controller.actor.character_stats.attack_power_multiplier = player_controller.actor.character_stats.reserve_copy.attack_power_multiplier
	var btn = debug_ui.find_child("OneHitKill", true, false)
	if btn:
		btn.text = "One-Hit Kill: ON" if one_hit_kill else "One-Hit Kill: OFF"

func _reset_hp() -> void:
	var stats = player_controller.actor.character_stats
	stats.current_health = stats.max_health
	stats.hp_changed.emit(stats.current_health)

func _apply_effect_to_player(effect_type: String) -> void:
	# This is a simplified effect trigger for testing
	# In production, effects come from enemy attacks
	pass

func _update_stats_display() -> void:
	if !stats_label or !player_controller:
		return

	var stats = player_controller.actor.character_stats
	stats_label.text = "HP: %d/%d\nATK: %.2f\nCrit%%: %.1f%%\nDodge%%: %.1f%%\nSpeed: %.2f\nResist: %.2f" % [
		stats.current_health,
		stats.max_health,
		stats.attack_power_multiplier,
		stats.critical_chance * 100,
		stats.dodge_chance * 100,
		stats.movement_speed_multiplier,
		stats.status_resist_multiplier
	]

func _unhandled_input(event: InputEvent) -> void:
	if god_mode and player_controller:
		var stats = player_controller.actor.character_stats
		if stats.current_health < stats.max_health:
			stats.current_health = stats.max_health
			stats.hp_changed.emit(stats.current_health)
