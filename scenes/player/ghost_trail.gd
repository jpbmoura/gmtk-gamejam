extends Node2D

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
var mat : ShaderMaterial

func setup(original_sprite: AnimatedSprite2D):
	global_position = original_sprite.global_position

	sprite.sprite_frames = original_sprite.sprite_frames
	sprite.animation = original_sprite.animation
	sprite.frame = original_sprite.frame
	sprite.flip_h = original_sprite.flip_h
	sprite.flip_v = original_sprite.flip_v
	sprite.scale = original_sprite.scale

	if sprite.material:
		sprite.material = sprite.material.duplicate()

	mat = sprite.material as ShaderMaterial

	if mat:
		mat.set_shader_parameter("colorize_color", Color(0.0, 0.5, 1.0))
		mat.set_shader_parameter("alpha", 0.6)

	fade_out()

func _ready():
	pass

func fade_out():
	var tween = create_tween()
	tween.tween_property(sprite, "modulate:a", 0, 0.4).set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(mat, "shader_parameter/alpha", 0.0, 0.3).set_trans(Tween.TRANS_LINEAR)
	tween.tween_callback(self.queue_free)
