extends Node

signal run_started()
signal player_died()
signal coins_collected(total_run: int)

const LEVEL_SCENE := "res://scenes/Level.tscn"
const MENU_SCENE := "res://scenes/Menu.tscn"

var run_active: bool = false
var coins_this_run: int = 0
var spawn_position: Vector2 = Vector2.ZERO
var checkpoint_position: Vector2 = Vector2.ZERO

var _dying: bool = false

func _ready() -> void:
    TimeManager.run_ended.connect(_on_run_ended)

# Ciclo da Run

func start_run() -> void:
    coins_this_run = 0
    checkpoint_position = spawn_position
    _dying = false
    run_active = true
    get_tree().change_scene_to_file(LEVEL_SCENE)
    await get_tree().process_frame
    TimeManager.start_run()
    run_started.emit()
 
 
func go_to_menu() -> void:
    run_active = false
    TimeManager.end_run()
    get_tree().change_scene_to_file(MENU_SCENE)

# Morte e Respawn

func kill_player() -> void:
    if not run_active or _dying:
        print(">>> kill_player BLOQUEADO: run_active=", run_active, " _dying=", _dying)
        return
    _dying = true
    TimeManager.register_death()
    var players := get_tree().get_nodes_in_group("player")
    if not players.is_empty() and players[0].has_method("teleport"):
      players[0].teleport(checkpoint_position)
    print(">>> player_died EMITIDO")
    player_died.emit()
    await get_tree().process_frame
    _dying = false

# Mundo

func set_spawn(pos: Vector2) -> void:
    spawn_position = pos
    if checkpoint_position == Vector2.ZERO:
      checkpoint_position = pos
  
 
func set_checkpoint(pos: Vector2) -> void:
    checkpoint_position = pos
 
 
func add_coin(amount: int = 1) -> void:
    coins_this_run += amount
    coins_collected.emit(coins_this_run)

# Fim da Run

func _on_run_ended(_stats: Dictionary) -> void:
    run_active = false
    SaveSystem.add_coins(coins_this_run)
