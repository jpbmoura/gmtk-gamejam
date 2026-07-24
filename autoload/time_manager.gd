extends Node

signal time_changed(seconds: float)
signal time_spent(amount: float, reason: String)
signal time_gained(amount: float, reason: String)
signal run_ended(stats: Dictionary)

const BASE_START := 45.0
const DRAIN_PER_SECOND := 1.0
const DEATH_COST := 3.0
const DEATH_COST_CHEAP := 1.0

var time_left: float = 0.0
var running: bool = false

var _spent: float = 0.0
var _gained: float = 0.0
var _deaths: int = 0
var _elapsed: float = 0.0

func _process(delta: float) -> void:
    if not running:
      return
    _elapsed += delta
    time_left -= DRAIN_PER_SECOND * delta
    time_changed.emit(time_left)
    if time_left <= 0.0:
        time_left = 0.0
        end_run()

# Ciclos da Run

func start_run() -> void:
    time_left = BASE_START # add any bonuses here
    _spent = 0.0
    _gained = 0.0
    _deaths = 0
    _elapsed = 0.0
    running = true
    time_changed.emit(time_left)

func end_run() -> void:
    if not running:
      return
    running = false
    run_ended.emit({
        "spent": _spent,
        "gained": _gained,
        "deaths": _deaths,
        "elapsed": _elapsed
    })

# Economia

func spend(amount: float, reason: String = "") -> bool:
    if amount <= 0.0:
        return true
    if amount > time_left:
        return false
    time_left -= amount
    _spent += amount
    time_spent.emit(amount, reason)
    time_changed.emit(time_left)
    return true

func gain(amount: float, reason: String = "") -> void:
    if amount <= 0.0:
        return
    time_left += amount
    _gained += amount
    time_gained.emit(amount, reason)
    time_changed.emit(time_left)

func register_death() -> void:
    _deaths += 1
    var cost := DEATH_COST_CHEAP if SaveSystem.cheap_respawn else DEATH_COST
    time_left -= cost
    _spent += cost
    time_spent.emit(cost, "death")
    time_changed.emit(time_left)
    if time_left <= 0.0:
        time_left = 0.0
        end_run()

# Consulta

func tension() -> float:
    return clampf(1.0 - (time_left / 20.0), 0.0, 1.0)


func elapsed() -> float:
    return _elapsed
