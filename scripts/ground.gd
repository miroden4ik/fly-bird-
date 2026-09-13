extends Node2D

const TILE_W := 256
const TILE_H := 120
const GRASS_H := 44

const GRASS_TOP := Color("c9f3a1")
const GRASS_LIGHT := Color("a8e07c")
const GRASS_BASE := Color("7fcb55")
const GRASS_DARK := Color("4c9836")
const DIRT := Color("b8793d")
const DIRT_DARK := Color("9e6a31")
const DIRT_LIGHT := Color("c98a4e")

var _tile: ImageTexture

func _ready() -> void:
	_tile = _make_tile()

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	var off: float = fposmod(Game.scroll_x, float(TILE_W))
	for i in range(-1, 5):
		draw_texture(_tile, Vector2(-off + i * TILE_W, 0))
	draw_rect(Rect2(0, 0, 720, 5), GRASS_TOP)

func _make_tile() -> ImageTexture:
	var img := Image.create(TILE_W, TILE_H, false, Image.FORMAT_RGBA8)
	img.fill(DIRT)

	var rng := RandomNumberGenerator.new()
	rng.seed = 21
	for i in 26:
		var cx := rng.randi_range(8, TILE_W - 8)
		var cy := rng.randi_range(GRASS_H + 14, TILE_H - 6)
		var r := rng.randi_range(2, 5)
		_blit_circle(img, cx, cy, r, DIRT_DARK)
		_blit_circle(img, cx - 1, cy - 1, maxi(1, r - 1), DIRT_LIGHT)

	for y in GRASS_H:
		var g: Color = GRASS_BASE.lerp(GRASS_LIGHT, float(y) / GRASS_H)
		for x in TILE_W:
			var v := 0.985 + 0.03 * sin(x * 0.55 + y * 2.1)
			img.set_pixel(x, y, Color(g.r * v, g.g * v, g.b * v))

	for x in TILE_W:
		img.set_pixel(x, 0, GRASS_TOP)
		img.set_pixel(x, 1, GRASS_LIGHT)
		img.set_pixel(x, GRASS_H - 1, GRASS_DARK)

	# Неровный низ травы
	for bx in range(0, TILE_W, 8):
		var h := 3 + int(snappedf(sin(bx * 0.45) * 2.5, 1.0))
		for dy in range(h):
			img.set_pixel(bx, GRASS_H + 2 + dy, GRASS_DARK)
	for bx in range(4, TILE_W, 8):
		var h := 3 + int(snappedf(sin(bx * 0.45 + 2.0) * 2.5, 1.0))
		for dy in range(h):
			img.set_pixel(bx, GRASS_H + 2 + dy, GRASS_DARK)

	return ImageTexture.create_from_image(img)

func _blit_circle(img: Image, cx: int, cy: int, r: int, color: Color) -> void:
	for y in range(cy - r, cy + r + 1):
		for x in range(cx - r, cx + r + 1):
			var dx := x - cx
			var dy := y - cy
			if dx * dx + dy * dy <= r * r and x >= 0 and x < img.get_width() and y >= 0 and y < img.get_height():
				img.set_pixel(x, y, color)