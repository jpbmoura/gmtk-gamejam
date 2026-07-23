extends Node

signal coins_changed(total: int)
signal unlocks_changed()

const PATH := "user://borrowed_time.cfg"

enum Verb {DASH, DOUBLE_JUMP, WALL_JUMP}

var coins: int = 0
var permanent_verbs: Array[int] = []
var start_time_bonus: float = 0.0
var cheap_respawn: bool = false
var magnet: bool = false

func _ready() -> void:
	load_game()

# Consulta

func has_permanent(verb: int) -> bool:
	return verb in permanent_verbs


func can_afford(price: int) -> bool:
	return coins >= price


# Moedas

func add_coins(amount: int) -> void:
	if amount <= 0:
		return
	coins += amount
	coins_changed.emit(coins)
	save_game()

func spend_coins(amount: int) -> bool:
	if coins < amount:
		return false
	coins -= amount
	coins_changed.emit(coins)
	save_game()
	return true

# Desbloqueios

func unlock_verb(verb: int) -> void:
	if verb in permanent_verbs:
		return
	permanent_verbs.append(verb)
	unlocks_changed.emit()
	save_game()

func add_start_time(seconds: float) -> void:
	start_time_bonus += seconds
	save_game()

func set_flag(flag: StringName, value: bool) -> void:
	match flag:
		&"cheap_respawn": cheap_respawn = value
		&"magnet": magnet = value
		_: push_warning("SaveSystem: flag desconhecida '%s'" % flag)
	save_game()

# Disco

func save_game() -> void:
	var cfg := ConfigFile.new()
	cfg.set_value("meta", "coins", coins)
	cfg.set_value("meta", "verbs", permanent_verbs)
	cfg.set_value("meta", "start_time_bonus", start_time_bonus)
	cfg.set_value("meta", "cheap_respawn", cheap_respawn)
	cfg.set_value("meta", "magnet", magnet)
	cfg.save(PATH)

func load_game() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return
	coins = cfg.get_value("meta", "coins", 0)
	var raw: Array = cfg.get_value("meta", "verbs", [])
	permanent_verbs.assign(raw)
	start_time_bonus = cfg.get_value("meta", "start_time_bonus", 0.0)
	cheap_respawn = cfg.get_value("meta", "cheap_respawn", false)
	magnet = cfg.get_value("meta", "magnet", false)

## Botão de "resetar progresso" 
func wipe() -> void:
	coins = 0
	permanent_verbs.clear()
	start_time_bonus = 0.0
	cheap_respawn = false
	magnet = false
	coins_changed.emit(coins)
	unlocks_changed.emit()
	save_game()