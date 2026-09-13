extends Node2D

const GAME_OVER_SCENE := preload("res://scenes/game_over.tscn")
const PLAYER_DEAD_SCENE := preload("res://scenes/player_dead.tscn")

@onready var player: CharacterBody2D = $Player
@onready var pipes: Node2D = $Pipes
@onready var score_label: Label = $HUD/ScoreLabel
@onready var ready_ui: Control = $HUD/ReadyUI
@onready var hint: Label = $HUD/ReadyUI/Hint

var _game_over_screen: Control = null

func _ready() -> void:
	Game.main = self
	Game.state_changed.connect(_on_state_changed)
	Game.score_changed.connect(_on_score_changed)

func _process(_delta: float) -> void:
	if Game.state == Game.State.READY and is_instance_valid(hint):
		var a := 0.55 + 0.45 * sin(Time.get_ticks_msec() / 170.0)
		hint.modulate.a = a

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.is_echo():
		if event.keycode == KEY_ESCAPE or event.keycode == KEY_BACKSPACE:
			Game.quit()
	if event.is_action_pressed("mute") and not event.is_echo():
		Game.toggle_mute()

func _unhandled_input(event: InputEvent) -> void:
	if not _is_tap_action(event):
		return
	match Game.state:
		Game.State.READY:
			Game.start_game()
			pipes.start()
		Game.State.OVER:
			Game.reset()

func _is_tap_action(event: InputEvent) -> bool:
	if event is InputEventScreenTouch:
		return event.pressed
	if event is InputEventMouseButton:
		return event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	if event is InputEventKey:
		return event.is_action_pressed("jump") and not event.is_echo()
	return false

func _on_state_changed(state: int) -> void:
	match state:
		Game.State.PLAYING:
			ready_ui.hide()
		Game.State.OVER:
			show_game_over()

func _on_score_changed(value: int) -> void:
	score_label.text = str(value)
	score_label.pivot_offset = score_label.size * 0.5
	score_label.scale = Vector2.ONE * 1.4
	var tw := create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	tw.tween_property(score_label, "scale", Vector2.ONE, 0.18)

func show_game_over() -> void:
	if _game_over_screen != null:
		return
	var scr := GAME_OVER_SCENE.instantiate()
	$HUD.add_child(scr)
	scr.setup(Game.score, Game.best, Game.is_new_best)
	_game_over_screen = scr

func show_player_dead(dead_player: CharacterBody2D) -> void:
	var dead := PLAYER_DEAD_SCENE.instantiate()
	add_child(dead)
	dead.global_position = dead_player.global_position
	dead.rotation = dead_player.rotation
	dead.linear_velocity = Vector2(-60, -240)
	dead.angular_velocity = 2.2
	dead_player.queue_free()