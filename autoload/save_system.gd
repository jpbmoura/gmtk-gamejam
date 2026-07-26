extends Node

signal coins_changed(total: int)
signal unlocks_changed()

const PATH := "user://borrowed_time.cfg"

var coins: int = 0
var upgrades: Dictionary = {}   # id da loja (String) -> nível (int)
var start_time_bonus: float = 0.0
var cheap_respawn: bool = false
var magnet: bool = false

var _save_queued := false

func _ready() -> void:
	load_game()

# Consulta

func has_upgrade(id: String) -> bool:
	return upgrades.get(id, 0) > 0


func level_of(id: String) -> int:
	return upgrades.get(id, 0)


func can_afford(price: int) -> bool:
	return coins >= price


# Moedas

func add_coins(amount: int) -> void:
	if amount <= 0:
		return
	coins += amount
	coins_changed.emit(coins)
	queue_save()

func spend_coins(amount: int) -> bool:
	if coins < amount:
		return false
	coins -= amount
	coins_changed.emit(coins)
	queue_save()
	return true

# Desbloqueios

func unlock(id: String) -> void:
	upgrades[id] = upgrades.get(id, 0) + 1
	unlocks_changed.emit()
	queue_save()

func add_start_time(seconds: float) -> void:
	start_time_bonus += seconds
	queue_save()

func set_flag(flag: StringName, value: bool) -> void:
	match flag:
		&"cheap_respawn": cheap_respawn = value
		&"magnet": magnet = value
		_: push_warning("SaveSystem: flag desconhecida '%s'" % flag)
	queue_save()

# Disco

## Agrupa várias mutações do mesmo frame numa única escrita.
func queue_save() -> void:
	if _save_queued:
		return
	_save_queued = true
	save_game.call_deferred()

func save_game() -> void:
	_save_queued = false
	var cfg := ConfigFile.new()
	cfg.set_value("meta", "coins", coins)
	cfg.set_value("meta", "upgrades", upgrades)
	cfg.set_value("meta", "start_time_bonus", start_time_bonus)
	cfg.set_value("meta", "cheap_respawn", cheap_respawn)
	cfg.set_value("meta", "magnet", magnet)
	cfg.save(PATH)

func load_game() -> void:
	var cfg := ConfigFile.new()
	if cfg.load(PATH) != OK:
		return
	coins = cfg.get_value("meta", "coins", 0)
	upgrades = cfg.get_value("meta", "upgrades", {})
	start_time_bonus = cfg.get_value("meta", "start_time_bonus", 0.0)
	cheap_respawn = cfg.get_value("meta", "cheap_respawn", false)
	magnet = cfg.get_value("meta", "magnet", false)

## Botão de "resetar progresso"
func wipe() -> void:
	coins = 0
	upgrades.clear()
	start_time_bonus = 0.0
	cheap_respawn = false
	magnet = false
	coins_changed.emit(coins)
	unlocks_changed.emit()
	save_game()
