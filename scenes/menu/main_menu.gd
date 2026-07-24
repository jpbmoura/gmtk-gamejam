extends Control

const GAME_SCENE := "res://scenes/levels/level_1.tscn"

@onready var options_menu: Control = %OptionsMenu
@onready var main_buttons: Control = %CenterContainer

func _ready() -> void:
	%StartButton.pressed.connect(_on_start_pressed)
	%OptionsButton.pressed.connect(_on_options_pressed)
	%QuitButton.pressed.connect(_on_quit_pressed)

	print("options_menu = ", options_menu)  # não pode ser <null>
	options_menu.hide()
	options_menu.closed.connect(_on_options_closed)

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(GAME_SCENE)

func _on_options_pressed() -> void:
	main_buttons.hide()
	options_menu.show()

func _on_options_closed() -> void:
	main_buttons.show()

func _on_quit_pressed() -> void:
	get_tree().quit()
