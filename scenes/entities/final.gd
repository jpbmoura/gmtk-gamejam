extends StaticBody2D

const CREDITS_SCENE := "res://scenes/menu/credits.tscn"

var _ativado := false

func _ready() -> void:
	$Trigger.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if _ativado:
		return
	if not body.is_in_group("player"):
		return
	_ativado = true
	Global.timer_running = false
	GameManager.run_active = false
	get_tree().change_scene_to_file(CREDITS_SCENE)
