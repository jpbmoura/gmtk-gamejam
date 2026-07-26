extends Node2D

@export var spawn: Marker2D
@export var player: CharacterBody2D


func _ready() -> void:
	player.global_position = spawn.global_position
	Global.player_died.connect(_on_player_died)

func _process(delta: float) -> void:
	Global.tick(delta)

func _on_player_died() -> void:                # a função — precisa existir!
	get_tree().reload_current_scene()
