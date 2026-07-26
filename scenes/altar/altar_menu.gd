extends CanvasLayer

signal upgrade_selected

@onready var buttons = [
	$Panel/VBoxContainer/Button1,
	$Panel/VBoxContainer/Button2,
	$Panel/VBoxContainer/Button3
]

var current_upgrades = []

func _ready():
	$Panel/VBoxContainer/Button1.pressed.connect(_on_button_pressed.bind(0))
	$Panel/VBoxContainer/Button2.pressed.connect(_on_button_pressed.bind(1))
	$Panel/VBoxContainer/Button3.pressed.connect(_on_button_pressed.bind(2))

func open():
	visible = true
	Global.control_enable = false

	current_upgrades = AltarManager.get_random_upgrades()

	for i in range(3):
		var upgrade = current_upgrades[i]
		var button = buttons[i]

		button.text = "%s\n\n%s\n\nCost: %s seconds" % [
			upgrade.title,
			upgrade.description,
			upgrade.price
		]

	$Panel/VBoxContainer/Button1.grab_focus()

func _choose(index):
	AltarManager.apply_upgrade(current_upgrades[index].id)

	get_tree().paused = false
	visible = false

	upgrade_selected.emit()
	

func _on_button_pressed(index:int):
	var upgrade = current_upgrades[index]
	AltarManager.apply_upgrade(upgrade.id)
	get_tree().paused = false
	Global.control_enable = true
	queue_free()
