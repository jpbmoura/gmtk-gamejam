extends Area2D

@export var grupo_alvo := "player"

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group(grupo_alvo):
		MusicManager.subir()
		set_deferred("monitoring", false)