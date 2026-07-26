extends Node

enum Upgrade {
	DASH,
	DOUBLE_JUMP,
	WALL_JUMP,
	DASH_2,
	CHEAP_DEATH,
	SPEED,
	MAGNET,
	DENSITY
}

var upgrades = [
	{
		"id": Upgrade.DASH,
		"title": "Dash",
		"description": "Provides dash in this run",
		"price": 5
	},
	{
		"id": Upgrade.DOUBLE_JUMP,
		"title": "Double Jump",
		"description": "Provides double jump in this run",
		"price": 5
	},
	{
		"id": Upgrade.WALL_JUMP,
		"title": "Wall Jump",
		"description": "Provides wall jump in this run",
		"price": 5
	},
	{
		"id": Upgrade.DASH_2,
		"title": "Overload",
		"description": "Dash with 2 charges",
		"price": 5
	},
	{
		"id": Upgrade.SPEED,
		"title": "Hurry",
		"description": "+30% running speed",
		"price": 5
	},
	{
		"id": Upgrade.DENSITY,
		"title": "Fresh",
		"description": "Herbs now give 10 seconds",
		"price": 5
	}
]

func get_random_upgrades(amount := 3):
	# AQUI TEM QUE COLOCARA LÓGICA PRA NÃO PEGAR OS UPGRADES DE EMPRÉSTIMO CASO JÁ TENHA ELES COMPRADO
	var pool = upgrades.duplicate()
	pool.shuffle()
	return pool.slice(0, amount)

func apply_upgrade(id):
	Global.remove_time(upgrades[id].price)
	match id:
		Upgrade.DASH:
			Global.altar_give_dash_upgrade()
		Upgrade.DOUBLE_JUMP:
			Global.altar_give_double_jump_upgrade()
		Upgrade.WALL_JUMP:
			Global.altar_give_wall_jump_upgrade()
		Upgrade.DASH_2:
			Global.altar_dash_upgrade()
		Upgrade.SPEED:
			Global.altar_speed_upgrade()
		Upgrade.DENSITY:
			Global.altar_herb_upgrade()
