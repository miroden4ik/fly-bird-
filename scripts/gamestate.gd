extends Node

signal state_changed(state: int)
signal score_changed(score: int)
signal muted_changed(muted: bool)
signal paused_changed(paused: bool)

enum State { READY, PLAYING, OVER }
enum Sfx { SCORE, GAME_OVER, JUMP, HIT }

const PIPE_SPEED := 250.0
const SAVE_PATH := "user://flappy_bird.cfg"

var main: Node = null
var player: CharacterBody2D = null

var state: int = State.READY
var score: int = 0
var best: int = 0
var is_new_best: bool = false
var muted: bool = false
var scroll_x: float = 0.0
var paused: bool = false

var sounds: Array[AudioStream] = [
	load("res://assets/220173__gameaudio__spacey-1uppower-up.wav"), # Spacey 1up by GameAudio (CC0)
	load("res://assets/382310__mountain_man__game-over-arcade.wav"), # Game Over Arcade by Mountain_Man (CC0)
	load("res://assets/237422__plasterbrain__hover-1.ogg"), # Hover 1 by plasterbrain (CC0)
	load("res://assets/punch_trimmed.wav"), # punch.wav by Ekokubza123 (CC0)
]

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	best = _load_best()
	muted = _load_muted()

func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_GO_BACK_REQUEST:
			# Системная кнопка «Назад» на Android.
			if paused:
				set_paused(false)
			else:
				quit()
		NOTIFICATION_WM_WINDOW_FOCUS_OUT, NOTIFICATION_APPLICATION_PAUSED:
			# Автопауза при сворачивании — игра не «умирает» в фоне.
			if state == State.PLAYING:
				set_paused(true)

func start_game() -> void:
	score = 0
	scroll_x = 0.0
	is_new_best = false
	set_paused(false)
	set_state(State.PLAYING)

func set_state(new_state: int) -> void:
	state = new_state
	state_changed.emit(state)

func add_score() -> void:
	score += 1
	score_changed.emit(score)
	play_sound(Sfx.SCORE)

func game_over() -> void:
	if state == State.OVER:
		return
	set_paused(false)
	is_new_best = score > 0 and score > best
	best = maxi(best, score)
	_save_best()
	set_state(State.OVER)
	play_sound(Sfx.HIT)
	play_sound(Sfx.GAME_OVER)
	if main == null:
		return
	main.show_game_over()
	if player != null and is_instance_valid(player):
		main.show_player_dead(player)

func reset() -> void:
	score = 0
	scroll_x = 0.0
	is_new_best = false
	state = State.READY
	set_paused(false)
	get_tree().reload_current_scene()

func quit() -> void:
	get_tree().quit()

func toggle_pause() -> void:
	if state != State.PLAYING:
		return
	set_paused(not paused)

func set_paused(value: bool) -> void:
	if paused == value:
		return
	paused = value
	get_tree().paused = value
	paused_changed.emit(paused)

func toggle_mute() -> void:
	set_muted(not muted)

func set_muted(value: bool) -> void:
	if muted == value:
		return
	muted = value
	_save_muted()
	muted_changed.emit(muted)

func play_sound(type: int) -> void:
	if muted:
		return
	var ap := AudioStreamPlayer.new()
	add_child(ap)
	ap.stream = sounds[type]
	ap.finished.connect(ap.queue_free)
	match type:
		Sfx.SCORE:
			ap.volume_db = -8.0
		Sfx.GAME_OVER:
			pass
		Sfx.JUMP:
			ap.volume_db = -7.0
			ap.pitch_scale = randf_range(0.9, 1.2)
		Sfx.HIT:
			ap.volume_db = -12.0
	ap.play()

func _save_best() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH) # keep other keys (e.g. muted) intact
	cfg.set_value("stats", "best", best)
	cfg.save(SAVE_PATH)

func _load_best() -> int:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return 0
	return int(cfg.get_value("stats", "best", 0))

func _save_muted() -> void:
	var cfg := ConfigFile.new()
	cfg.load(SAVE_PATH) # keep other keys (e.g. best) intact
	cfg.set_value("stats", "muted", muted)
	cfg.save(SAVE_PATH)

func _load_muted() -> bool:
	var cfg := ConfigFile.new()
	if cfg.load(SAVE_PATH) != OK:
		return false
	return bool(cfg.get_value("stats", "muted", false))