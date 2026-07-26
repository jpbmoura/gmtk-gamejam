extends Area2D

@export var spawn: Marker2D

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	body.velocity = Vector2.ZERO
	body.global_position = spawn.global_position
	GameManager.player_died.emit()
