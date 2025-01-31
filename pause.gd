extends CanvasLayer
class_name Pause

@onready var general_volume_slider = %GeneralVolumeSlider
@onready var music_volume_slider = %MusicVolumeSlider
@onready var sfx_volume_slider = %SFXVolumeSlider
@onready var options_menu = $OptionsMenu

func _ready():
	options_menu.hide()
	
	general_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	music_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Music")))
	sfx_volume_slider.value = db_to_linear(AudioServer.get_bus_volume_db(AudioServer.get_bus_index("SFX")))

	# Підключаємо сигнали слайдерів до функцій
	general_volume_slider.connect("value_changed", Callable(self, "_on_general_volume_changed"))
	music_volume_slider.connect("value_changed", Callable(self, "_on_music_volume_changed"))
	sfx_volume_slider.connect("value_changed", Callable(self, "_on_effects_volume_changed"))

func _unhandled_input(event):
	if event.is_action_pressed("pause") and get_tree().paused == true:
		get_parent().get_tree().paused = false
		hide()
	
func _on_general_volume_changed(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(value))

func _on_music_volume_changed(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Music"), linear_to_db(value))

func _on_effects_volume_changed(value: float):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("SFX"), linear_to_db(value))

func db_to_linear(db_value: float) -> float:
	return (db_value + 40) / 40  # Перетворюємо діапазон -40 dB до 0 dB у 0-1

func linear_to_db(linear_value: float) -> float:
	return linear_value * 40 - 40  # Перетворюємо 0-1 у діапазон -40 до 0 dB


func _on_options_button_pressed():
	options_menu.visible = !options_menu.visible


func _on_resume_button_pressed():
	$"..".is_paused = !$"..".is_paused
	get_parent().get_tree().paused = false
	hide()


func _on_exit_button_pressed():
	get_tree().quit()
