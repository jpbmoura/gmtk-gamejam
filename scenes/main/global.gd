extends Node

signal coins_changed(total: int)
signal upgrade_bought(id: String)
signal time_changed(seconds_left: float)
signal player_died

const CATALOG := {
	"double_jump": {
		"name": "Double Jump",
		"desc": "Earns the ability to jump again in mid-air",
		"cost": 5,
		"max_level": 1,
		"icon": "res://assets/icons/Icon16.png",
	},
	"wall_jump": {
		"name": "Wall Jump",
		"desc": "Slide down walls and jump off them",
		"cost": 15,
		"max_level": 1,
		"icon": "res://assets/icons/Icon33.png",
	},
	"dash": {
		"name": "Dash",
		"desc": "Burst forward at high speed",
		"cost": 15,
		"max_level": 1,
		"icon": "res://assets/icons/Icon44.png",
	},
}

@export var start_time := 30.0
var time_left := 0.0
var timer_running := false
var timer_started := false
var herb_count: int = 0
var herb_value = 5
var control_enable = true
var speed_modifier = 1
var more_jumps = 0;
var more_dash = false;

# Habilidades emprestadas pelo altar: valem só até o fim da run.
# As compradas na loja vivem no SaveSystem e são permanentes.
var run_dash := false
var run_double_jump := false
var run_wall_jump := false

## A carteira é permanente: mora no SaveSystem, não zera com a run.
var coins: int:
	get: return SaveSystem.coins

func reset_values():
	time_left = 0.0
	timer_running = false
	timer_started = false
	herb_count = 0
	herb_value = 5
	control_enable = true
	speed_modifier = 1
	more_jumps = 0;
	more_dash = false;
	run_dash = false
	run_double_jump = false
	run_wall_jump = false

# Habilidades

func can_dash() -> bool:
	return run_dash or has("dash")

func can_double_jump() -> bool:
	return run_double_jump or has("double_jump")

func can_wall_jump() -> bool:
	return run_wall_jump or has("wall_jump")

func altar_herb_upgrade():
	herb_value = 10
	
func altar_speed_upgrade():
	speed_modifier = 1.3

func add_herb(val:int = 1):
	herb_count += val
	add_time(herb_value)
	
func altar_dash_upgrade():
	more_dash = true;
	
func altar_give_dash_upgrade():
	run_dash = true

func altar_give_double_jump_upgrade():
	run_double_jump = true

func altar_give_wall_jump_upgrade():
	run_wall_jump = true


func remove_herb(val:int = 1):
	if herb_count - val < 0:
		herb_count = 0
		pass
	herb_count -= val

func add_coins(amount: int) -> void:
	SaveSystem.add_coins(amount)
	coins_changed.emit(SaveSystem.coins)

func can_afford(cost: int) -> bool:
	return SaveSystem.can_afford(cost)

func buy(id: String, cost: int) -> bool:
	if not CATALOG.has(id):
		return false
	if level_of(id) >= int(CATALOG[id].max_level):
		return false
	if not SaveSystem.spend_coins(cost):
		return false
	SaveSystem.unlock(id)
	coins_changed.emit(SaveSystem.coins)
	upgrade_bought.emit(id)
	return true

func has(id: String) -> bool:
	return SaveSystem.has_upgrade(id)

func level_of(id: String) -> int:
	return SaveSystem.level_of(id)

## Apaga todo o progresso permanente (carteira + habilidades compradas).
func reset() -> void:
	SaveSystem.wipe()
	coins_changed.emit(SaveSystem.coins)

func start_stage() -> void:
	time_left = start_time
	timer_running = true
	time_changed.emit(time_left)

func add_time(seconds: float) -> void:
	time_left += seconds
	time_changed.emit(time_left)
	
func remove_time(seconds: float) -> void:
	time_left -= seconds
	time_changed.emit(time_left)

func tick(delta: float) -> void:
	if not timer_running:
		return
	time_left -= delta
	time_changed.emit(time_left)
	if time_left <= 0.0:
		end_run()

## Único ponto de fim de run: vale tanto pro tempo esgotado quanto pra morte.
## Zera o cronômetro e avisa quem recarrega a fase; o timer só volta a correr
## quando o player cruzar a placa de início de novo.
func end_run() -> void:
	time_left = 0.0
	timer_running = false
	timer_started = false
	time_changed.emit(time_left)
	player_died.emit()
	reset_values()

func start_timer(seconds: float) -> void:
	if timer_started:
		return          # já começou, ignora
	timer_started = true
	time_left = seconds
	timer_running = true
	time_changed.emit(time_left)
