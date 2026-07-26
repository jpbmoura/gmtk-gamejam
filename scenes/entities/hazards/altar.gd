extends Area2D

@export var sprite_texture: Texture2D = null
@export_enum("pray_1", "pray_2", "pray_3") var on_collission: String = ""
var player_in_range := false
var prayed = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	$Sprite.texture = sprite_texture

func _on_body_entered(body: Node2D):
	if body.is_in_group("player"):
		player_in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.is_in_group("player"):
		player_in_range = false

func _unhandled_input(event: InputEvent) -> void:
	if player_in_range and event.is_action_pressed("interact") and !prayed:
		Global.callv(on_collission, [])
		$PointLight2D.enabled = false
		prayed = true
