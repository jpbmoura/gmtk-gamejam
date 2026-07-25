extends Node

signal coins_changed(total: int)
signal upgrade_bought(id: String)


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


var herb_count: int = 0
var coins := 0
var upgrades: Dictionary = {}   # id -> nível comprado

func add_herb(val:int = 1):
	herb_count += val

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
