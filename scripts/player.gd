extends CharacterBody2D

const BirdArt := preload("res://scripts/bird_art.gd")

const GRAVITY := 1900.0
const JUMP_VELOCITY := -640.0
const MAX_FALL := 950.0
const BOB_Y := 430.0

var _t := 0.0
var _stretch := 0.0
var _beak := 0.0

func _ready() -> void:
	Game.player = self

func _physics_process(delta: float) -> void:
	_t += delta
	match Game.state:
		Game.State.READY:
			position.y = BOB_Y + sin(_t * 3.2) * 9.0
			rotation = lerp_angle(rotation, 0.0, minf(1.0, delta * 8.0))
			velocity = Vector2.ZERO
		Game.State.PLAYING:
			velocity.y = minf(velocity.y + GRAVITY * delta, MAX_FALL)
			move_and_slide()
			_stretch = maxf(0.0, _stretch - delta * 3.0)
			_beak = maxf(0.0, _beak - delta * 3.0)
			_tilt(delta)
			if get_slide_collision_count() > 0:
				Game.game_over()
		Game.State.OVER:
			pass
	queue_redraw()

func _tilt(delta: float) -> void:
	var target := -0.35 if velocity.y < -50.0 else remap(clampf(velocity.y, 0.0, MAX_FALL), 0.0, MAX_FALL, 0.2, 1.1)
	rotation = lerp_angle(rotation, target, minf(1.0, delta * 9.0))

func _unhandled_input(event: InputEvent) -> void:
	if Game.state != Game.State.PLAYING:
		return
	var tap := false
	if event is InputEventScreenTouch:
		tap = event.pressed
	elif event is InputEventMouseButton:
		tap = event.pressed and event.button_index == MOUSE_BUTTON_LEFT
	elif event is InputEventKey and event.is_action_pressed("jump"):
		tap = not event.is_echo()
	if tap:
		_flap()

func _flap() -> void:
	velocity.y = JUMP_VELOCITY
	_stretch = 1.0
	_beak = 1.0
	Game.play_sound(Game.Sfx.JUMP)

func _draw() -> void:
	BirdArt.draw(self, _t, {"stretch": _stretch, "beak": _beak, "dead": false, "wing_speed": 1.0})