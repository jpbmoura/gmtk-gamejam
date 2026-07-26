extends PanelContainer

signal buy_pressed(id: String)

# --- Cores (batem com o mockup do boticário) ---
const COLOR_NAME := Color("e8e4d8")
const COLOR_DESC := Color("9a9488")
const COLOR_LEVEL := Color("888888")
const COLOR_GOLD := Color("d4a94a")
const COLOR_GREEN := Color("8fae6a")
const COLOR_DISABLED := Color("6a7a55")

@onready var icon: TextureRect = %Icon
@onready var name_label: Label = %NameLabel
@onready var desc_label: Label = %DescLabel
@onready var level_label: Label = %LevelLabel
@onready var cost_badge: PanelContainer = %CostBadge
@onready var cost_label: Label = %CostLabel
@onready var sold_out_check: Label = %SoldOutCheck

var item_id: String
var _data: Dictionary


func setup(id: String, data: Dictionary) -> void:
	item_id = id
	_data = data
	if is_node_ready():
		refresh()


func _ready() -> void:
	gui_input.connect(_on_gui_input)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	if not _data.is_empty():
		refresh()


func refresh() -> void:
	if _data.is_empty():
		return

	var icon_path: String = _data.get("icon", "")
	if icon_path != "" and ResourceLoader.exists(icon_path):
		icon.texture = load(icon_path)
		icon.show()
	else:
		icon.hide()

	name_label.text = _data.get("name", "???")
	name_label.add_theme_color_override("font_color", COLOR_NAME)

	desc_label.text = _data.get("desc", "")
	desc_label.add_theme_color_override("font_color", COLOR_DESC)

	var lvl: int = Global.level_of(item_id)
	var max_lvl: int = _data.get("max_level", 1)

	if max_lvl > 1:
		level_label.text = "Nv %d / %d" % [lvl, max_lvl]
		level_label.show()
	else:
		# habilidade binária: o ✓ já diz se foi comprada, "Nv 0" só polui
		level_label.hide()
	level_label.add_theme_color_override("font_color", COLOR_LEVEL)

	var maxed: bool = lvl >= max_lvl
	var cost: int = _data.get("cost", 0)

	if maxed:
		cost_badge.hide()
		sold_out_check.show()
		modulate = Color(1, 1, 1, 0.55)
		name_label.add_theme_color_override("font_color", COLOR_DISABLED.lightened(0.3))
	else:
		cost_badge.show()
		sold_out_check.hide()
		modulate = Color.WHITE
		cost_label.text = str(cost)
		var affordable: bool = Global.can_afford(cost)
		cost_label.add_theme_color_override("font_color", COLOR_GOLD if affordable else COLOR_DISABLED)


func _on_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		var lvl: int = Global.level_of(item_id)
		var max_lvl: int = _data.get("max_level", 1)
		if lvl < max_lvl:
			buy_pressed.emit(item_id)


func _on_mouse_entered() -> void:
	if Global.level_of(item_id) < _data.get("max_level", 1):
		modulate = Color(1.12, 1.12, 1.12)


func _on_mouse_exited() -> void:
	refresh()  # restaura o modulate correto conforme o estado
