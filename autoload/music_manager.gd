extends Node

const MUSICA := preload("res://assets/audio/music/skeleton.mp3")

const VOL_BAIXO := -18.0
const VOL_ALTO := 0.0

const FADE_SUBIDA := 0.8
const FADE_DESCIDA := 2.0

var _player: AudioStreamPlayer
var _tween: Tween

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS

	_player = AudioStreamPlayer.new()
	_player.stream = MUSICA
	_player.volume_db = VOL_BAIXO
	add_child(_player)
	_player.play()

func subir() -> void:
	_fade_para(VOL_ALTO, FADE_SUBIDA)

func abaixar() -> void:
	_fade_para(VOL_BAIXO, FADE_DESCIDA)

func _fade_para(db: float, duracao: float) -> void:
	if is_equal_approx(_player.volume_db, db):
		return
	if _tween and _tween.is_valid():
		_tween.kill()
	_tween = create_tween()
	_tween.tween_property(_player, "volume_db", db, duracao)