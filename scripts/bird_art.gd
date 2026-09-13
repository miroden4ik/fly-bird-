# Мультяшная отрисовка птички. Вызывается из _draw() любого CanvasItem.
# opts: stretch (squash&stretch 0..1), beak (0..1), dead (bool), wing_speed.

const OUTLINE := Color("4a3b2e")
const BODY := Color("ffd94a")
const WING := Color("f4b83c")
const WING_DARK := Color("d99b2d")
const BELLY := Color("fff3d4")
const BEAK := Color("ff8a3d")
const BEAK_DARK := Color("e8691f")
const CHEEK := Color(1.0, 0.52, 0.6, 0.55)
const WHITE := Color("ffffff")
const PUPIL := Color("2f2f38")
const EYE_DARK := Color("3a2c22")

static func draw(item: CanvasItem, t: float, opts: Dictionary) -> void:
	var stretch: float = opts.get("stretch", 0.0)
	var beak_open: float = opts.get("beak", 0.0)
	var dead: bool = opts.get("dead", false)
	var wing_speed: float = opts.get("wing_speed", 1.0)

	# Хвост
	item.draw_circle(Vector2(-38, -4), 9.0, OUTLINE)
	item.draw_circle(Vector2(-38, -4), 7.0, WING)
	item.draw_circle(Vector2(-32, 12), 8.0, OUTLINE)
	item.draw_circle(Vector2(-32, 12), 6.0, WING)

	# Хохолок
	item.draw_circle(Vector2(-14, -40), 8.5, OUTLINE)
	item.draw_circle(Vector2(-14, -40), 6.5, BODY)
	item.draw_circle(Vector2(-24, -36), 6.0, OUTLINE)
	item.draw_circle(Vector2(-24, -36), 4.5, BODY)

	# Тело со squash&stretch
	item.draw_set_transform(Vector2.ZERO, 0.0, Vector2(1.0 + stretch * 0.13, 1.0 - stretch * 0.07))
	item.draw_circle(Vector2.ZERO, 44.0, OUTLINE)
	item.draw_circle(Vector2.ZERO, 41.0, BODY)
	item.draw_circle(Vector2(0, 15), 24.0, BELLY)
	item.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

	# Крыло
	var wing_rot := -0.4 + sin(t * wing_speed * 9.0) * 0.5
	if dead:
		wing_rot = -0.95
	_oval(item, -12, -2, 15.0, 9.5, OUTLINE, wing_rot)
	_oval(item, -12, -2, 12.5, 7.0, WING, wing_rot)
	_oval(item, -12, 3, 9.0, 2.2, WING_DARK, wing_rot)

	# Клюв
	var open := beak_open * 5.0
	_tri(item, PackedVector2Array([Vector2(34, -4 - open), Vector2(52, 5 - open * 0.5), Vector2(34, 10)]), BEAK_DARK)
	_tri(item, PackedVector2Array([Vector2(34, -2 - open), Vector2(49, 5 - open * 0.5), Vector2(34, 9)]), BEAK)
	_tri(item, PackedVector2Array([Vector2(33, 8), Vector2(47, 13), Vector2(33, 17)]), BEAK_DARK)
	_tri(item, PackedVector2Array([Vector2(33, 9), Vector2(45, 13), Vector2(33, 16)]), BEAK)

	# Глаз
	if dead:
		item.draw_line(Vector2(8, -20), Vector2(22, -6), OUTLINE, 5.0)
		item.draw_line(Vector2(22, -20), Vector2(8, -6), OUTLINE, 5.0)
	else:
		item.draw_circle(Vector2(15, -13), 13.5, EYE_DARK)
		item.draw_circle(Vector2(15, -13), 11.5, WHITE)
		item.draw_circle(Vector2(17, -13), 6.5, PUPIL)
		item.draw_circle(Vector2(19.5, -15.5), 2.6, WHITE)

	# Румянец
	if not dead:
		item.draw_circle(Vector2(17, 11), 6.0, CHEEK)

static func _oval(item: CanvasItem, cx: float, cy: float, rx: float, ry: float, color: Color, rot: float = 0.0) -> void:
	item.draw_set_transform(Vector2(cx, cy), rot, Vector2(rx, ry))
	item.draw_circle(Vector2.ZERO, 1.0, color)
	item.draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

static func _tri(item: CanvasItem, points: PackedVector2Array, color: Color) -> void:
	item.draw_colored_polygon(points, color)