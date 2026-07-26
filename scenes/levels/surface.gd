# lava_surface.gd — no nó Surface (Sprite2D)
extends Sprite2D

@export var scroll_speed := 30.0

func _process(delta: float) -> void:
	region_rect.position.x += scroll_speed * delta
