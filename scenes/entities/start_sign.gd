# start_sign.gd
extends Area2D


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	Global.time_changed.connect(_check_timer_finished)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		Global.start_timer(Global.start_time)
		set_deferred("monitoring", false)
		$Sprite2D.modulate = Color(0.5, 1, 0.5)   # placa fica verde, tipo "GO"

func _check_timer_finished(time_left):
	if time_left <= 0:
		set_deferred("monitoring", true)
