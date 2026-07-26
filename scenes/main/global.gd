extends Node

signal coins_changed(total: int)
signal upgrade_bought(id: String)
signal time_changed(seconds_left: float)
signal player_died

const CATALOG := {
	"double_jump": {
		"name": "Double Jump",
		"desc": "Earns the ability to jump again in mid-air",
		"cost": 15,
		"max_level": 1,
		"icon": "res://assets/icons/Icon16.png",
	},
	"speed": {
		"name": "SpeedUp",
		"desc": "+15% speed",
		"cost": 10,
		"max_level": 3,
		"icon": "res://assets/icons/Icon33.png",
	},
	"higher_jump": {
		"name": "Higher Jump",
		"desc": "+15% jump height",
		"cost": 12,
		"max_level": 2,
		"icon": "res://assets/icons/Icon44.png",
	},
}

@export var start_time := 30.0
var time_left := 0.0
var timer_running := false
var timer_started := false
var herb_count: int = 0
var coins := 0
var upgrades: Dictionary = {}
var herb_value = 5
var control_enable = true
var speed_modifier = 1
var more_jumps = 0;
var more_dash = false;

func reset_values():
	time_left = 0.0
	timer_running = false
	timer_started = false
	herb_count = 0
	coins = 0
	herb_value = 5
	control_enable = true
	speed_modifier = 1
	more_jumps = 0;
	more_dash = false;

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
	# PRECISA ACIONAR A FLAG DE QUE TEM O UPGRADE COMPRADO (ELA AINDA NÃO EXISTE EU ACHO)
	# LEMBRA DE RESETAR QUANDO A RUN ACABAR NA FUNC reset_values
	return
	
func altar_give_double_jump_upgrade():
	# PRECISA ACIONAR A FLAG DE QUE TEM O UPGRADE COMPRADO (ELA AINDA NÃO EXISTE EU ACHO)
	# LEMBRA DE RESETAR QUANDO A RUN ACABAR NA FUNC reset_values
	return
	
func altar_give_wall_jump_upgrade():
	# PRECISA ACIONAR A FLAG DE QUE TEM O UPGRADE COMPRADO (ELA AINDA NÃO EXISTE EU ACHO)
	# LEMBRA DE RESETAR QUANDO A RUN ACABAR NA FUNC reset_values
	return


func remove_herb(val:int = 1):
	if herb_count - val < 0:
		herb_count = 0
		pass
	herb_count -= val

func add_coins(amount: int) -> void:
	coins += amount
	coins_changed.emit(coins)

func can_afford(cost: int) -> bool:
	return coins >= cost

func buy(id: String, cost: int) -> bool:
	if not can_afford(cost):
		return false
	coins -= cost
	upgrades[id] = upgrades.get(id, 0) + 1
	coins_changed.emit(coins)
	upgrade_bought.emit(id)
	return true

func has(id: String) -> bool:
	return upgrades.get(id, 0) > 0

func level_of(id: String) -> int:
	return upgrades.get(id, 0)

func reset() -> void:
	coins = 0
	upgrades.clear()
	coins_changed.emit(coins)

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
		time_left = 0.0
		timer_running = false
		player_died.emit()
		timer_started = false
		reset_values()

func start_timer(seconds: float) -> void:
	if timer_started:
		return          # já começou, ignora
	timer_started = true
	time_left = seconds
	timer_running = true
	time_changed.emit(time_left)
