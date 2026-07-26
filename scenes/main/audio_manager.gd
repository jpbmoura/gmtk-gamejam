extends AudioStreamPlayer

const VOL_BAIXO := -30.0
const VOL_ALTO := -15.0
const FADE := 0.8

var _tween: Tween

func _ready() -> void:
	volume_db = VOL_BAIXO
	if not playing:
		play()
	GameManager.player_died.connect(_baixar)
	GameManager.run_started.connect(_baixar)

func subir() -> void:
	_fade(VOL_ALTO)

func _baixar() -> void:
	_fade(VOL_BAIXO)

func _fade(alvo: float) -> void:
	if _tween:
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(self, "volume_db", alvo, FADE)