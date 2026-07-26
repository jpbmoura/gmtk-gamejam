extends Node

const SFX := {
	"jump": "res://assets/audio/sfx/jump.wav",
	"dash": "res://assets/audio/sfx/swoosh.mp3",
	"death": "res://assets/audio/sfx/death.mp3",
  "landing": "res://assets/audio/sfx/landing.mp3",
  "collect": "res://assets/audio/sfx/collect.mp3"
}

func _ready() -> void:
	GameManager.player_died.connect(func() -> void: play("death"))

func play(key: String, pitch: float = 1.0) -> void:
	var path: String = SFX.get(key, "")
	if path.is_empty() or not ResourceLoader.exists(path):
		return
	var p := AudioStreamPlayer.new()
	p.stream = load(path)
	p.pitch_scale = pitch
	add_child(p)
	p.finished.connect(p.queue_free)
	p.play()