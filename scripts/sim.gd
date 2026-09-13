extends Node2D

var _t := 0.0
var _started := false
var _flap_t := 0.0
var _measured := false

func _ready() -> void:
	add_child(preload("res://scenes/main.tscn").instantiate())

func _process(_delta: float) -> void:
	if _t > 8.0 and not _measured:
		_measured = true
		var go := Game.main.get_node_or_null("HUD/GameOver")
		if go:
			print("[sim] gameover pos=", go.position, " size=", go.size)
			print("[sim] panel global_pos=", go.get_node("Panel").global_position, " size=", go.get_node("Panel").size)
		else:
			print("[sim] gameover NOT FOUND under HUD")

func _physics_process(delta: float) -> void:
	_t += delta
	if _t > 1.0 and not _started and Game.state == Game.State.READY:
		_started = true
		Game.start_game()
		Game.main.pipes.start()
	if _started and Game.state == Game.State.PLAYING:
		_flap_t -= delta
		if _flap_t <= 0.0:
			_flap_t = 0.5 + randf() * 0.14
			Game.player._flap()
	if _t > 7.0 and Game.state != Game.State.OVER:
		Game.game_over()
	if _t > 8.6:
		print("[sim] quitting, state=", Game.state, " score=", Game.score)
		get_tree().quit()