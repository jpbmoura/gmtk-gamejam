# credits.gd
extends Control

const MENU_SCENE := "res://scenes/menu/main_menu.tscn"

const FADE := 0.8 # duração de cada fade-in
const HOLD_TITLE := 1.4
const HOLD_NAMES := 2.6
const HOLD_ASSETS := 2.2
const HOLD_THANKS := 3.0
const FADE_OUT := 1.0

@onready var content: CenterContainer = %CenterContainer
@onready var survived: Label = %SurvivedLabel
@onready var names_box: VBoxContainer = %NamesBox
@onready var assets_box: VBoxContainer = %AssetsBox
@onready var thanks: Label = %ThanksLabel

func _ready() -> void:
	var tw := create_tween()
	tw.tween_property(survived, "modulate:a", 1.0, FADE)
	tw.tween_interval(HOLD_TITLE)
	tw.tween_property(names_box, "modulate:a", 1.0, FADE)
	tw.tween_interval(HOLD_NAMES)
	tw.tween_property(assets_box, "modulate:a", 1.0, FADE)
	tw.tween_interval(HOLD_ASSETS)
	tw.tween_property(thanks, "modulate:a", 1.0, FADE)
	tw.tween_interval(HOLD_THANKS)
	tw.tween_property(content, "modulate:a", 0.0, FADE_OUT)
	tw.tween_callback(_voltar_ao_menu)

func _voltar_ao_menu() -> void:
	get_tree().change_scene_to_file(MENU_SCENE)
