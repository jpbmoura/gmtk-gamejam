# start_sign.gd
extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Global.start_timer(Global.start_time)
		set_deferred("monitoring", false)
		$Sprite2D.modulate = Color(0.5, 1, 0.5)   # placa fica verde, tipo "GO"
