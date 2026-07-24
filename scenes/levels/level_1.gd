extends Node2D

@export var spawn: Marker2D
@export var player: CharacterBody2D

func _ready() -> void:
	player.global_position = spawn.global_position
