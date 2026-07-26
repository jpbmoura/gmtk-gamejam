extends Area2D

@export var rotation_speed: float = 16.0
@export var move_distance: float = 0.0
@export var move_speed: float = 60.0

var _start_x: float
var _dir: float = 1.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	_start_x = global_position.x

func _process(delta: float) -> void:
	$Sprite2D.rotation += rotation_speed * delta

	if move_distance > 0.0:
		global_position.x += _dir * move_speed * delta
		if absf(global_position.x - _start_x) >= move_distance:
			_dir *= -1.0

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("player"):
		GameManager.kill_player()