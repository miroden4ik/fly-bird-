extends Node2D

const PIPE_SCENE := preload("res://scenes/pipe.tscn")
const SPAWN_INTERVAL := 1.55

var _timer := 0.0
var _started := false

func start() -> void:
	_started = true
	_timer = 0.0
	_spawn()

func _physics_process(delta: float) -> void:
	if not _started or Game.state != Game.State.PLAYING:
		return
	Game.scroll_x += Game.PIPE_SPEED * delta
	_timer += delta
	if _timer >= SPAWN_INTERVAL:
		_timer = 0.0
		_spawn()

func _spawn() -> void:
	add_child(PIPE_SCENE.instantiate())