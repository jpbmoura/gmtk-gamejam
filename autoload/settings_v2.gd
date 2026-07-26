extends Node

const SAVE_PATH := "user://settings.cfg"

var music_volume: float = 1.0
var sfx_volume: float = 1.0
var fullscreen: bool = false

func _ready() -> void:
	load_settings()
	apply_all()

func set_bus_volume(bus_name: String, linear: float) -> void:
	var idx := AudioServer.get_bus_index(bus_name)
	print("bus '", bus_name, "' idx = ", idx, " volume = ", linear)
	if idx == -1:
		push_warning("Bus não encontrado: %s" % bus_name)
		return
	AudioServer.set_bus_mute(idx, is_zero_approx(linear))
	AudioServer.set_bus_volume_db(idx, linear_to_db(linear))

func apply_all() -> void:
	set_bus_volume("Music", music_volume)
	set_bus_volume("SFX", sfx_volume)
	DisplayServer.window_set_mode(
		DisplayServer.WINDOW_MODE_FULLSCREEN if fullscreen
		else DisplayServer.WINDOW_MODE_WINDOWED
	)

func save_settings() -> void:
	var config := ConfigFile.new()
	config.set_value("audio", "music", music_volume)
	config.set_value("audio", "sfx", sfx_volume)
	config.set_value("video", "fullscreen", fullscreen)
	config.save(SAVE_PATH)

func load_settings() -> void:
	var config := ConfigFile.new()
	if config.load(SAVE_PATH) != OK:
		return  # primeira execução, usa os defaults
	music_volume = config.get_value("audio", "music", 1.0)
	sfx_volume = config.get_value("audio", "sfx", 1.0)
	fullscreen = config.get_value("video", "fullscreen", false)
