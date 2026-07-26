# hud.gd — num CanvasLayer com um Label filho
extends CanvasLayer

@onready var time_label: Label = %TimeLabel
@onready var coins_label: Label = %CoinsLabel

func _ready() -> void:
	%CoinIcon.play();
	Global.time_changed.connect(_on_time_changed)
	Global.coins_changed.connect(_on_coins_changed)
	time_label.hide()
	_on_coins_changed(Global.coins)


func _on_time_changed(seconds: float) -> void:
	time_label.show()
	var m := int(seconds) / 60
	var s := int(seconds) % 60
	time_label.text = "%d:%02d" % [m, s]
	time_label.modulate = Color.RED if seconds < 5.0 else Color.WHITE

func _on_coins_changed(total: int) -> void:
	coins_label.text = str(total)
	var tween := create_tween()
	coins_label.scale = Vector2(1.3, 1.3)
	tween.tween_property(coins_label, "scale", Vector2.ONE, 0.15)
