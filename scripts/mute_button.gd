extends Button

# Кнопка звука. Иконка рисуется кодом (в духе остального проекта — без спрайтов).

const ICON_COLOR := Color("4a3b2e")

func _ready() -> void:
	custom_minimum_size = Vector2(72, 72)
	flat = true
	focus_mode = Control.FOCUS_NONE
	text = ""

	var sb_normal := StyleBoxFlat.new()
	sb_normal.bg_color = Color(1, 1, 1, 0.55)
	sb_normal.set_corner_radius_all(36)

	var sb_hover := sb_normal.duplicate()
	sb_hover.bg_color = Color(1, 1, 1, 0.75)

	var sb_pressed := sb_normal.duplicate()
	sb_pressed.bg_color = Color(1, 1, 1, 0.4)

	add_theme_stylebox_override("normal", sb_normal)
	add_theme_stylebox_override("hover", sb_hover)
	add_theme_stylebox_override("pressed", sb_pressed)
	add_theme_stylebox_override("focus", sb_normal)

	pressed.connect(_on_pressed)
	Game.muted_changed.connect(_on_muted_changed)

func _on_pressed() -> void:
	Game.toggle_mute()

func _on_muted_changed(_muted: bool) -> void:
	queue_redraw()

func _draw() -> void:
	var cx := size.x * 0.5 - 6.0
	var cy := size.y * 0.5

	var cone := PackedVector2Array([
		Vector2(cx - 20, cy - 7),
		Vector2(cx - 9, cy - 7),
		Vector2(cx + 5, cy - 19),
		Vector2(cx + 5, cy + 19),
		Vector2(cx - 9, cy + 7),
		Vector2(cx - 20, cy + 7),
	])
	draw_colored_polygon(cone, ICON_COLOR)

	if Game.muted:
		draw_line(Vector2(cx - 2, cy - 16), Vector2(cx + 22, cy + 16), ICON_COLOR, 5.0, true)
		draw_line(Vector2(cx - 2, cy + 16), Vector2(cx + 22, cy - 16), ICON_COLOR, 5.0, true)
	else:
		draw_arc(Vector2(cx + 5, cy), 13.0, -0.75, 0.75, 10, ICON_COLOR, 3.5, true)
		draw_arc(Vector2(cx + 5, cy), 20.0, -0.65, 0.65, 10, ICON_COLOR, 3.5, true)
