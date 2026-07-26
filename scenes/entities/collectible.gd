extends Area2D

@export var amplitude: float = 20.0
@export var frequency: float = 3.0
@export_enum("add_herb", "remove_herb", "add_coins") var on_collission: String = ""
@export var particle_on: bool = true
@export var particle_color: Color = Color(0.97, 0.97, 0, 1)
@export var collect_sound: String = "collect"

@onready var start_y: float = $Sprite.position.y

var time_passed: float = 0.0

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	$Sprite.play()
	$Sprite/Particles.emitting = particle_on
	$Sprite/Particles.color = particle_color

func _process(delta: float) -> void:
	time_passed += delta
	var wave := (sin(time_passed * frequency) + 1.0) * 0.5
	$Sprite.position.y = start_y - (wave * amplitude)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("player"):
		return
	if on_collission != "" and Global.has_method(on_collission):
		Global.callv(on_collission, [1])
		SfxManager.play("collect")
	queue_free()
