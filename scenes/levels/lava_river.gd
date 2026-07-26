@tool
extends Node2D

@export var lava_tile: PackedScene
@export var width := 2000.0:
	set(value):
		width = value
		_rebuild()
@export var tile_width := 32.0:
	set(value):
		tile_width = value
		_rebuild()
@export var randomize_frames := true:
	set(value):
		randomize_frames = value
		_rebuild()

func _ready() -> void:
	_rebuild()

func _rebuild() -> void:
	if not is_node_ready() or lava_tile == null:
		return

	# limpa tiles antigos antes de recriar
	for child in get_children():
		child.queue_free()

	var count := int(ceil(width / tile_width))
	for i in count:
		var tile := lava_tile.instantiate() as AnimatedSprite2D
		add_child(tile)
		tile.position.x = i * tile_width

		if randomize_frames and tile.sprite_frames:
			# cada tile começa num frame diferente → superfície não pulsa junta
			var anim := tile.sprite_frames.get_animation_names()[0]
			var total := tile.sprite_frames.get_frame_count(anim)
			tile.play(anim)
			tile.frame = randi() % total
		else:
			tile.play()
