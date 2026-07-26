extends CharacterBody2D

@export var ghost_trail_scene: PackedScene

@export_group("Movimento")
@export var speed := 300.0
@export var acceleration := 2500.0
@export var friction := 3000.0

@export_group("Pulo")
@export var jump_velocity := -600.0
@export var gravity_multiplier := 2.0
@export var fall_multiplier := 1.4
@export var max_jumps := 2
@export var double_jump_factor := 1.0
@export var coyote_time := 5
@export var jump_buffer_time := 0.12
@export var jump_cut := 0.45

@export_group("Parede")
@export var wall_slide_speed := 120.0
@export var wall_jump_push := 380.0
@export var wall_jump_height := -560.0
@export var wall_jump_lock := 0.14
@export var wall_coyote_time := 0.1

var jumps_left := 0
var coyote_timer := 0.0
var buffer_timer := 0.0
var wall_lock_timer := 0.0
var wall_coyote_timer := 0.0
var last_wall_normal := Vector2.ZERO
var dash_timer := 0.0
var dash_direction := 0.0
var dash_used := false
var dash_cooldown_timer := 0.0
var facing := -1
var was_on_floor := true
var dash_charges := 1

var ghost_timer: float = 0.0
var ghost_interval: float = 0.02

var DASH_TIME = 0.2
var DASH_SPEED = 800.0
var DASH_COOLDOWN = 2.3

func reset_dash_charges():
	if Global.more_dash:
		dash_charges = 2
	else:
		dash_charges = 1
		
func _ready() -> void:
	reset_dash_charges()
		
	add_to_group("player")

func teleport(pos: Vector2) -> void:
	global_position = pos
	velocity = Vector2.ZERO
	# --- limpa estado de movimento para não respawnar em dash/wall jump ---
	dash_timer = 0.0
	reset_dash_charges()
	wall_lock_timer = 0.0
	buffer_timer = 0.0
	coyote_timer = 0.0
	jumps_left = max_jumps


func _physics_process(delta: float) -> void:
	if !Global.control_enable:
		return
		
	var on_floor := is_on_floor()
	var on_wall := is_on_wall_only()
	# --- timers de chão ---
	if on_floor:
		if dash_cooldown_timer <= 2:
			reset_dash_charges()
		coyote_timer = coyote_time
		jumps_left = max_jumps
	else:
		coyote_timer -= delta
		if coyote_timer <= 0.0 and jumps_left == max_jumps:
			jumps_left -= 1

	# --- timers de parede ---
	if on_wall:
		last_wall_normal = get_wall_normal()
		wall_coyote_timer = wall_coyote_time
		jumps_left = max_jumps
	else:
		wall_coyote_timer -= delta

	wall_lock_timer -= delta

	if Input.is_action_just_pressed("ui_accept"):
		buffer_timer = jump_buffer_time
	else:
		buffer_timer -= delta

	# --- gravidade ---
	if not on_floor:
		var mult := gravity_multiplier
		if velocity.y > 0.0:
			mult *= fall_multiplier
		velocity += get_gravity() * (delta * mult)
		$AnimatedSprite2D/ParticleRunning.emitting = false
		$AnimatedSprite2D/ParticlePoison.emitting = false

	# --- deslizar na parede ---
	if on_wall and velocity.y > 0.0:
		velocity.y = minf(velocity.y, wall_slide_speed)

	# --- pulo de parede (checar ANTES do pulo normal) ---
	if buffer_timer > 0.0 and wall_coyote_timer > 0.0 and not on_floor:
		dash_timer = 0.0
		velocity.x = last_wall_normal.x * wall_jump_push
		velocity.y = wall_jump_height
		buffer_timer = 0.0
		wall_coyote_timer = 0.0
		coyote_timer = 0.0
		velocity.x = last_wall_normal.x * wall_jump_push
		velocity.y = wall_jump_height
		wall_lock_timer = wall_jump_lock
		jumps_left = max_jumps - 1
		$AnimatedSprite2D.flip_h = !$AnimatedSprite2D.flip_h
		facing = facing * -1

	# --- pulo normal / duplo ---
	elif buffer_timer > 0.0 and jumps_left > 0:
		buffer_timer = 0.0
		var ground_jump := coyote_timer > 0.0 and jumps_left == max_jumps
		coyote_timer = 0.0
		dash_timer = 0.0
		velocity.y = jump_velocity if ground_jump else jump_velocity * double_jump_factor
		jumps_left -= 1

	if Input.is_action_just_released("ui_accept") and velocity.y < 0.0:
		velocity.y *= jump_cut

	# --- dash ---
	# ui_right twice to dash
	if Input.is_action_just_pressed("dash") and dash_charges > 0:
		dash_charges -= 1
		dash_cooldown_timer = DASH_COOLDOWN
		SfxManager.play("dash")

		if Input.get_axis("ui_left", "ui_right"):
			dash_direction = Input.get_axis("ui_left", "ui_right")
		else:
			dash_direction = facing

		dash_timer = DASH_TIME

	if dash_timer > 0.0:
		dash_timer -= delta
		velocity.x = DASH_SPEED * dash_direction
		velocity.y = 0.0

	if dash_cooldown_timer > 0.0:
		dash_cooldown_timer -= delta

	# --- moving ---
	if wall_lock_timer <= 0.0:
		var direction := Input.get_axis("ui_left", "ui_right")
		if direction != 0:
			facing = direction
		if direction:
			velocity.x = move_toward(velocity.x, direction * speed * Global.speed_modifier, acceleration * delta)
			$AnimatedSprite2D/ParticlePoison.emitting = false
			if direction < 0.0:
				$AnimatedSprite2D.flip_h = false
				if on_floor:
					$AnimatedSprite2D/ParticleRunning.emitting = true
					$AnimatedSprite2D/ParticleRunning.position.x = 16
			else:
				$AnimatedSprite2D.flip_h = true
				if on_floor:
					$AnimatedSprite2D/ParticleRunning.emitting = true
					$AnimatedSprite2D/ParticleRunning.position.x = -16


		else:
			velocity.x = move_toward(velocity.x, 0.0, friction * delta)
			$AnimatedSprite2D/ParticleRunning.emitting = false
			$AnimatedSprite2D/ParticlePoison.emitting = true

		# --- animation ---
			# dash
	if dash_timer > 0.0:
		$AnimatedSprite2D.play("dash")
		ghost_timer -= delta
		if ghost_timer <= 0:
			ghost_timer = ghost_interval
			spawn_ghost_trail()
	else:
			# idle
		if velocity.x == 0.0 and on_floor:
			$AnimatedSprite2D.play("idle")
			# running
		elif velocity.x != 0.0 and on_floor:
			$AnimatedSprite2D.play("running")
			# jumping
		elif velocity.y < 0.0:
			$AnimatedSprite2D.play("jumping_air")
		# falling
		elif velocity.y > 0.0:
			$AnimatedSprite2D.play("falling_air")


	var fall_speed := velocity.y
	move_and_slide()

	# --- landing ---
	var now_on_floor := is_on_floor()
	if now_on_floor and not was_on_floor and fall_speed > 100.0:
		SfxManager.play("landing")
	was_on_floor = now_on_floor

func spawn_ghost_trail():
	var ghost = ghost_trail_scene.instantiate()
	get_parent().add_child(ghost)

	ghost.global_position = global_position
	ghost.setup($AnimatedSprite2D)
