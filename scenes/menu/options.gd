extends Panel

signal closed

@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SfxSlider
@onready var fullscreen_check: CheckButton = %FullscreenCheck

func _ready() -> void:
	# reflete o estado atual sem disparar os sinais
	music_slider.set_value_no_signal(Settings.music_volume)
	sfx_slider.set_value_no_signal(Settings.sfx_volume)
	fullscreen_check.set_pressed_no_signal(Settings.fullscreen)

	music_slider.value_changed.connect(_on_music_changed)
	sfx_slider.value_changed.connect(_on_sfx_changed)
	fullscreen_check.toggled.connect(_on_fullscreen_toggled)
	%BackButton.pressed.connect(_on_back_pressed)

func _on_music_changed(value: float) -> void:
	Settings.music_volume = value
	Settings.set_bus_volume("Music", value)

func _on_sfx_changed(value: float) -> void:
	Settings.sfx_volume = value
	Settings.set_bus_volume("SFX", value)

func _on_fullscreen_toggled(pressed: bool) -> void:
	Settings.fullscreen = pressed
	Settings.apply_all()

func _on_back_pressed() -> void:
	Settings.save_settings()
	hide()
	closed.emit()
