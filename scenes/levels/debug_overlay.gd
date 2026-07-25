extends CanvasLayer

@export var player: CharacterBody2D

const TILE := 32.0

var _label: Label
var _jump_from := Vector2.ZERO
var _peak := 0.0
var _was_floor := true
var _last_h := 0.0
var _last_d := 0.0
var _best_h := 0.0
var _best_d := 0.0
var _max_height := 0.0
var _max_speed := 0.0

# var is_dashing = player.is_dashing

func _ready() -> void:
	# get_tree().debug_collisions_hint = true
	_label = Label.new()
	_label.position = Vector2(8, 8)
	_label.add_theme_font_size_override("font_size", 14)
	_label.add_theme_color_override("font_color", Color.WHITE)
	_label.add_theme_color_override("font_outline_color", Color.BLACK)
	_label.add_theme_constant_override("outline_size", 4)
	add_child(_label)


func _process(_delta: float) -> void:
	if player == null:
		_label.text = "player não atribuído"
		return

	var vel: Vector2 = player.velocity
	var on_floor: bool = player.is_on_floor()

	if _was_floor and not on_floor:
		_jump_from = player.global_position
		_peak = player.global_position.y
	if not on_floor:
		_peak = minf(_peak, player.global_position.y)
	if not _was_floor and on_floor:
		_last_h = (_jump_from.y - _peak) / TILE
		_last_d = absf(player.global_position.x - _jump_from.x) / TILE
		_best_h = maxf(_best_h, _last_h)
		_best_d = maxf(_best_d, _last_d)
	_was_floor = on_floor
	_max_height = maxf(_max_height, _last_h)
	_max_speed = maxf(_max_speed, vel.length())

	_label.text = "\n".join([
		"vel      %6.0f , %6.0f px/s" % [vel.x, vel.y],
		"chão     %s" % ("sim" if on_floor else "não"),
		"último pulo  h %.2f  d %.2f  (tiles)" % [_last_h, _last_d],
		"RECORDE      h %.2f  d %.2f" % [_best_h, _best_d],
		"ALTURA MÁX    %.2f tiles" % _max_height,
		"VEL MÁX       %.0f px/s" % _max_speed,
		# "DASHING       %s" % ("sim" if is_dashing else "não")
	])


func _unhandled_input(e: InputEvent) -> void:
	if e is InputEventKey and e.pressed and e.keycode == KEY_0:
		_best_h = 0.0
		_best_d = 0.0
