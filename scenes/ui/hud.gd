# hud.gd — num CanvasLayer com a barra de tempo e o contador de coins
extends CanvasLayer

## Cor da barra cheia e cor no fim do tempo; o meio é interpolado.
const COLOR_TIME_OK := Color(0.83137256, 0.6627451, 0.2901961)
const COLOR_TIME_LOW := Color(0.7529412, 0.22745098, 0.16862746)
## Abaixo desta fração do tempo total a barra começa a avermelhar.
const DANGER_FRACTION := 0.34

@onready var time_bar: ProgressBar = %TimeBar
@onready var coins_label: Label = %CoinsLabel

var _fill: StyleBoxFlat

func _ready() -> void:
	%CoinIcon.play();
	# duplica o StyleBox pra tingir a barra sem afetar outras instâncias
	_fill = time_bar.get_theme_stylebox("fill").duplicate()
	time_bar.add_theme_stylebox_override("fill", _fill)
	time_bar.max_value = Global.start_time

	Global.time_changed.connect(_on_time_changed)
	Global.coins_changed.connect(_on_coins_changed)
	time_bar.hide()
	_on_coins_changed(Global.coins)


func _on_time_changed(seconds: float) -> void:
	time_bar.show()
	time_bar.value = clampf(seconds, 0.0, time_bar.max_value)
	# ervas podem passar do tempo inicial: a barra satura em cheia
	var fraction := clampf(seconds / time_bar.max_value, 0.0, 1.0)
	_fill.bg_color = COLOR_TIME_LOW.lerp(COLOR_TIME_OK, minf(fraction / DANGER_FRACTION, 1.0))

func _on_coins_changed(total: int) -> void:
	coins_label.text = str(total)
	var tween := create_tween()
	coins_label.scale = Vector2(1.3, 1.3)
	tween.tween_property(coins_label, "scale", Vector2.ONE, 0.15)
