extends Node2D

@onready var cheat_lvl_selection = $CheatLvlSelection
@onready var pause = $Pause


@export var beast_tameress_scene: PackedScene
@export var duo_animals_scene: PackedScene
@export var acrobat_scene: PackedScene

@export var initial_cutscene_scene: PackedScene
@export var prison_cutscene_scene: PackedScene
@export var shop_scene: PackedScene

@onready var beast_tameress_btn: Button = %beast_tameress_btn
@onready var duo_animals_btn: Button = %duo_animals_btn
@onready var acrobat_btn: Button = %acrobat_btn

var current_level: Node2D
var current_scene: PackedScene

var is_paused: bool = false

# Індекс поточного рівня
var current_level_index: int = 0


# Послідовність сцен
@onready var level_sequence: Array = [
	initial_cutscene_scene,
	shop_scene,
	beast_tameress_scene,
	shop_scene,
	duo_animals_scene,
	shop_scene,
	acrobat_scene
]

func _ready() -> void:
	%FinalCurtain.hide()
	load_scene(level_sequence[0])
	
	GlobalSignals.ready_to_transit.connect(func(agent):
		print(agent)
		if agent is Bear:
			_on_player_died()
		else:
			_on_boss_died()
		)
	
	pause.hide()
	cheat_lvl_selection.hide()
	beast_tameress_btn.pressed.connect(func():
		add_level(beast_tameress_scene)
		)
	duo_animals_btn.pressed.connect(func():
		add_level(duo_animals_scene)
		)
	acrobat_btn.pressed.connect(func():
		add_level(acrobat_scene)
		)


func load_scene(scene: PackedScene):
	if current_level:
		current_level.queue_free()  # Видаляємо поточну сцену

	current_scene = scene  # Оновлюємо current_scene
	current_level = scene.instantiate()  # Створюємо нову сцену
	call_deferred("add_child", current_level)  # Додаємо її до дерева сцен

	# Підключаємо сигнали для нової сцени
	if current_level.has_method("connect_signals"):
		current_level.connect_signals(self)

# Функція для переходу до наступної сцени
func go_to_next_scene():
	current_level_index += 1
	if current_level_index < level_sequence.size():
		load_scene(level_sequence[current_level_index])
	else:
		print("Гра завершена!")  # Тут можна додати логіку завершення гри

# Обробка сигналу завершення катсцени
func _on_cutscene_ended():
	go_to_next_scene()

# Обробка сигналу переходу до наступного етапу
func _on_next_stage():
	go_to_next_scene()

# Обробка сигналу смерті гравця
func _on_player_died():
	load_scene(prison_cutscene_scene)
	current_level_index = 0

# Обробка сигналу смерті боса
func _on_boss_died():
	if current_level_index < level_sequence.size() - 1:
		await get_tree().create_timer(3.0)
		load_scene(shop_scene)
		
		# Оновлюємо індекс, щоб після магазину перейти на наступний рівень
		current_level_index += 1
	else:
		%FinalCurtain.show()
		%PauseAnimationPlayer.play("GAME_COMPLETED")
		get_tree().paused = true
		
		
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("restart"):
		# Перевіряємо, чи current_level ініціалізований
		if current_level != null:
			# Перевіряємо, чи поточний рівень дозволяє рестарт
			if _is_restart_allowed():
				if current_level:
					current_level.queue_free()
				add_level(current_scene)
				GlobalSignals.stop_slow_motion.emit()
				GlobalSignals.reset_stats_all.emit()
			else:
				print(current_level)
				print("Restart is not allowed on this level.")
		else:
			print("Current level is not set. Cannot restart.")
	elif event.is_action_pressed("lvl_selection"):
		show_cheat_lvl_selection()
		GlobalSignals.stop_slow_motion.emit()
		GlobalSignals.reset_stats_all.emit()
	elif event.is_action_pressed("pause"):
		toggle_pause()
		
func add_level(scene_to_spawn: PackedScene):
	current_scene = scene_to_spawn
	current_level = scene_to_spawn.instantiate()
	add_child(current_level)
	cheat_lvl_selection.hide()

func show_cheat_lvl_selection():
	if current_level:
		current_level.queue_free()
	cheat_lvl_selection.show()

func toggle_pause():
	is_paused = !is_paused
	if is_paused:
		pause_game()
	else:
		resume_game()

func pause_game():
	get_tree().paused = true
	%PauseAnimationPlayer.speed_scale = 2.0
	%PauseAnimationPlayer.play("APPEAR")
	pause.show()

func resume_game():
	%PauseAnimationPlayer.speed_scale = 3.0
	%PauseAnimationPlayer.play_backwards("APPEAR")
	await get_tree().create_timer(1.0).timeout
	get_tree().paused = false
	pause.hide()

func _is_restart_allowed() -> bool:
	# Перевіряємо, чи current_level ініціалізований
	if current_level == null:
		return false

	# Перевіряємо, чи поточний рівень є одним із дозволених
	var allowed_levels = [beast_tameress_scene, duo_animals_scene, acrobat_scene]
	return current_scene in allowed_levels


func _on_exit_button_pressed():
	get_tree().quit()


func _on_restart_button_pressed():
	current_level_index = 0
	load_scene(level_sequence[current_level_index])
	%FinalCurtain.hide()
