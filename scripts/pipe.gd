extends Node2D

const BODY_W := 100.0
const CAP_W := 148.0
const CAP_H := 74.0
const HALF_LEN := 720.0
const X_SPAWN := 820.0
const X_DESPAWN := -180.0

const PIPE_BODY_DARK := Color("3c8c34")
const PIPE_BODY_LIGHT := Color("8edb78")
const PIPE_EDGE_SHADOW := Color(0.0, 0.22, 0.05, 0.22)
const PIPE_EDGE_LIGHT := Color(1.0, 1.0, 1.0, 0.22)
const PIPE_INNER_SHADOW := Color(0.0, 0.25, 0.06, 0.12)
const PIPE_CAP := Color("6fc65a")
const PIPE_CAP_BORDER := Color("2e6a25")

var _gap := 220.0
var _grad_top: GradientTexture2D
var _grad_bottom: GradientTexture2D
var _cap_style: StyleBoxFlat

func _ready() -> void:
	_gap = _random_gap()
	var dy := _random_height(_gap)
	position = Vector2(X_SPAWN, 640.0 + dy)
	_build_materials()
	_setup_collisions()
	$ScoreArea.body_entered.connect(_on_score_area, ConnectFlags.CONNECT_ONE_SHOT)

func _physics_process(delta: float) -> void:
	if Game.state != Game.State.PLAYING:
		return
	position.x -= Game.PIPE_SPEED * delta
	if position.x <= X_DESPAWN:
		queue_free()

func _setup_collisions() -> void:
	var hgap := _gap * 0.5
	($Top as StaticBody2D).position = Vector2(0, -(HALF_LEN + hgap) * 0.5)
	var sh_top := RectangleShape2D.new()
	sh_top.size = Vector2(BODY_W, HALF_LEN - hgap)
	$Top/Shape.shape = sh_top
	($Bottom as StaticBody2D).position = Vector2(0, (HALF_LEN + hgap) * 0.5)
	var sh_bot := RectangleShape2D.new()
	sh_bot.size = Vector2(BODY_W, HALF_LEN - hgap)
	$Bottom/Shape.shape = sh_bot

func _draw() -> void:
	var hgap := _gap * 0.5
	var body_h := HALF_LEN - hgap

	# Верхняя труба
	var top_body := Rect2(-BODY_W * 0.5, -HALF_LEN, BODY_W, body_h)
	draw_texture_rect(_grad_top, top_body, false)
	_draw_body_details(top_body)
	var top_cap := Rect2(-CAP_W * 0.5, -hgap - CAP_H, CAP_W, CAP_H)
	draw_style_box(_cap_style, top_cap)
	_draw_cap_highlight(top_cap, -1.0)

	# Нижняя труба
	var bot_body := Rect2(-BODY_W * 0.5, hgap, BODY_W, body_h)
	draw_texture_rect(_grad_bottom, bot_body, false)
	_draw_body_details(bot_body)
	var bot_cap := Rect2(-CAP_W * 0.5, hgap, CAP_W, CAP_H)
	draw_style_box(_cap_style, bot_cap)
	_draw_cap_highlight(bot_cap, 1.0)

func _draw_body_details(rect: Rect2) -> void:
	draw_rect(Rect2(rect.position.x + 7, rect.position.y, 5, rect.size.y), PIPE_EDGE_SHADOW)
	draw_rect(Rect2(rect.position.x + BODY_W - 13, rect.position.y, 5, rect.size.y), PIPE_EDGE_LIGHT)
	draw_rect(Rect2(rect.position.x + BODY_W * 0.5 - 26, rect.position.y, 9, rect.size.y), PIPE_INNER_SHADOW)

func _draw_cap_highlight(cap: Rect2, dir: float) -> void:
	if dir > 0.0:
		draw_rect(Rect2(cap.position.x + 6, cap.position.y, cap.size.x - 12, 6), Color(1, 1, 1, 0.3))
		draw_rect(Rect2(cap.position.x + 6, cap.position.y + cap.size.y - 8, cap.size.x - 12, 8), Color(0.1, 0.35, 0.1, 0.25))
	else:
		draw_rect(Rect2(cap.position.x + 6, cap.position.y + cap.size.y - 6, cap.size.x - 12, 6), Color(1, 1, 1, 0.3))
		draw_rect(Rect2(cap.position.x + 6, cap.position.y, cap.size.x - 12, 8), Color(0.1, 0.35, 0.1, 0.25))

func _on_score_area(_body: Node2D) -> void:
	Game.add_score()

func _random_gap() -> float:
	var max_gap := 420.0 - snappedi(Game.score, 10) * 5.0
	return randf_range(190.0, max(190.0, max_gap))

func _random_height(gap: float) -> float:
	var max_height := (640.0 - 90.0) - gap * 0.5
	var dir := 1.0 if randi() % 2 == 0 else -1.0
	return randf_range(0.0, max(0.0, max_height)) * dir

func _build_materials() -> void:
	_grad_top = _make_grad(PIPE_BODY_DARK, PIPE_BODY_LIGHT)
	_grad_bottom = _make_grad(PIPE_BODY_LIGHT, PIPE_BODY_DARK)
	_cap_style = StyleBoxFlat.new()
	_cap_style.bg_color = PIPE_CAP
	_cap_style.set_corner_radius_all(20)
	_cap_style.set_border_width_all(5)
	_cap_style.border_color = PIPE_CAP_BORDER

func _make_grad(a: Color, b: Color) -> GradientTexture2D:
	var g := Gradient.new()
	g.colors = PackedColorArray([a, b])
	g.offsets = PackedFloat32Array([0.0, 1.0])
	var t := GradientTexture2D.new()
	t.gradient = g
	t.fill_from = Vector2(0, 0)
	t.fill_to = Vector2(0, 1)
	t.width = 4
	t.height = 128
	return t