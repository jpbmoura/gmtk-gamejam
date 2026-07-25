extends Area2D

@export var sprite_texture: Texture2D = null
@export var amplitude: float = 20.0
@export var frequency: float = 3.0
@export_enum("add_herb", "remove_herb") var on_collission: String = ""
@export var particle_on: bool = true
@export var particle_color: Color = Color(0.97,0.97,0,1)
@onready var start_y: float = $Sprite.position.y
var time_passed: float = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("body_entered", Callable(self, "_on_body_entered"))
	$Sprite.texture = sprite_texture
	$Sprite/Particles.emitting = particle_on
	$Sprite/Particles.color = particle_color

func _process(delta: float) -> void:
	# --- Animação ---
	time_passed += delta
	var wave := (sin(time_passed * frequency) + 1.0) * 0.5
	$Sprite.position.y = start_y - (wave * amplitude)
	
func _on_body_entered(body: Node2D):
	Global.call(on_collission)
	queue_free()
