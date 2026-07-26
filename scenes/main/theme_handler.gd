extends Area2D

var _ativado := false

func _ready() -> void:
	body_entered.connect(_on_entered)

func _on_entered(body: Node2D) -> void:
	if _ativado:
		return
	if body.is_in_group("player"):
		_ativado = true
		get_tree().get_first_node_in_group("musica").subir()