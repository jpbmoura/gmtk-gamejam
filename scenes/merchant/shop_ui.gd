# shop_ui.gd
extends CanvasLayer

@export var item_container: VBoxContainer
@export var coins_label: Label

const ITEM_SCENE := preload("res://scenes/ui/shop_item.tscn")


func _ready() -> void:
	hide()
	Global.coins_changed.connect(_update_coins)
	_build_items()

func toggle() -> void:
	visible = not visible
	if not is_inside_tree():
		return
	get_tree().paused = visible
	if visible:
		_refresh()

func close() -> void:
	visible = false
	if is_inside_tree():
		get_tree().paused = false

func _build_items() -> void:
	for id in Global.CATALOG:
		var item := ITEM_SCENE.instantiate()
		item.setup(id, Global.CATALOG[id])
		item.buy_pressed.connect(_on_buy)
		item_container.add_child(item)

	var close_btn := Button.new()
	close_btn.text = "Close (ESC)"
	close_btn.pressed.connect(close)
	item_container.add_child(close_btn)

func _on_buy(id: String) -> void:
	Global.buy(id, Global.CATALOG[id].cost)
	_refresh()

func _refresh() -> void:
	_update_coins(Global.coins)
	for item in item_container.get_children():
		if item.has_method("refresh"):
			item.refresh()   # cada item se atualiza sozinho

func _update_coins(total: int) -> void:
	coins_label.text = "Coins: %d" % total

func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		close()
		get_viewport().set_input_as_handled()
