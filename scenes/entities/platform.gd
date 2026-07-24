@tool
extends StaticBody2D

@export var size := Vector2(832, 64):
	set(value):
		size = value
		_update_size()

func _ready() -> void:
	_update_size()

func _update_size() -> void:
	if not is_node_ready():
		return
	$ColorRect.size = size
	$ColorRect.position = -size * 0.5
	$CollisionShape2D.shape.size = size
