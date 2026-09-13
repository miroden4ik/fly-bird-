extends Node2D

const SKY_W := 720.0
const SKY_H := 1280.0

var _sky: GradientTexture2D
var _clouds: Array[Dictionary] = []

func _ready() -> void:
	_build_sky()
	var rng := RandomNumberGenerator.new()
	rng.seed = 7
	for i in 14:
		_clouds.append({
			"x": rng.randf_range(0, SKY_W),
			"y": rng.randf_range(90, 860),
			"s": rng.randf_range(0.55, 1.35),
			"p": rng.randf_range(0.08, 0.2),
		})

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	draw_texture_rect(_sky, Rect2(0, 0, SKY_W, SKY_H), false)

	# Солнце
	var sun := Vector2(590, 250)
	draw_circle(sun, 118, Color(1, 0.93, 0.55, 0.10))
	draw_circle(sun, 90, Color(1, 0.93, 0.55, 0.16))
	draw_circle(sun, 66, Color("ffe27a"))
	draw_circle(sun, 56, Color("fff086"))

	_hills()

	# Облака
	for c in _clouds:
		var drift: float = fmod(Game.scroll_x * float(c.p), 920.0)
		var x := float(c.x) - drift
		if x < -230.0:
			x += 920.0
		if x > SKY_W + 60.0:
			x -= 920.0
		_cloud(x, float(c.y), float(c.s))

func _hills() -> void:
	var back := Color("a9e07c")
	var front := Color("8fd463")
	draw_circle(Vector2(-160, 1140), 250, back)
	draw_circle(Vector2(120, 1118), 230, back)
	draw_circle(Vector2(420, 1148), 280, back)
	draw_circle(Vector2(700, 1122), 240, back)
	draw_circle(Vector2(-40, 1170), 270, front)
	draw_circle(Vector2(260, 1148), 260, front)
	draw_circle(Vector2(560, 1158), 270, front)
	draw_circle(Vector2(820, 1140), 250, front)

func _cloud(x: float, y: float, s: float) -> void:
	var shade := Color("dff3ff")
	var white := Color("ffffff")
	_oval(x - 34 * s, y + 9 * s, 22 * s, 15 * s, shade)
	_oval(x, y, 30 * s, 21 * s, shade)
	_oval(x + 30 * s, y + 11 * s, 20 * s, 13 * s, shade)
	_oval(x - 12 * s, y - 9 * s, 20 * s, 15 * s, shade)
	_oval(x + 18 * s, y - 7 * s, 18 * s, 13 * s, shade)
	_oval(x - 12 * s, y - 3 * s, 24 * s, 10 * s, white)
	_oval(x + 14 * s, y - 2 * s, 18 * s, 9 * s, white)

func _oval(cx: float, cy: float, rx: float, ry: float, color: Color) -> void:
	draw_set_transform(Vector2(cx, cy), 0.0, Vector2(rx, ry))
	draw_circle(Vector2.ZERO, 1.0, color)
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

func _build_sky() -> void:
	var grad := Gradient.new()
	grad.colors = PackedColorArray([Color("8ee9ff"), Color("c9f4ff"), Color("eefcff")])
	grad.offsets = PackedFloat32Array([0.0, 0.55, 1.0])
	_sky = GradientTexture2D.new()
	_sky.gradient = grad
	_sky.fill_from = Vector2(0, 0)
	_sky.fill_to = Vector2(0, 1)
	_sky.width = 4
	_sky.height = 64