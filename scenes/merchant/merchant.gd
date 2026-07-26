# merchant.gd
extends Area2D

@export var shop_ui: CanvasLayer   # arraste a UI da loja aqui

var player_in_range := false

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	$Prompt.hide()
	$Balloon.show()
	_bob_balloon()

## Flutuação sutil pra chamar atenção de longe.
func _bob_balloon() -> void:
	var base_y: float = $Balloon.position.y
	var tween := create_tween().set_loops()
	tween.tween_property($Balloon, "position:y", base_y - 5.0, 1.2) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Balloon, "position:y", base_y, 1.2) \
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = true
		$Balloon.hide()
		$Prompt.show()

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false
		$Prompt.hide()
		$Balloon.show()
		shop_ui.close()

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact"):
		if shop_ui == null:
			return
		shop_ui.toggle()
		$Prompt.visible = player_in_range and not shop_ui.visible
