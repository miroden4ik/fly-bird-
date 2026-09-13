#!/usr/bin/env python3
"""Генерация Android-иконок (adaptive icon + legacy) для Flappy Bird.

Нарисовано в стиле игры (процедурно): жёлтая птичка, небо, труба.
Выводит в assets/icons:
  icon.png               — legacy 512x512
  adaptive_foreground.png — 432x432 (безопасная зона 66%)
  adaptive_background.png — 432x432
"""

import os
from PIL import Image, ImageDraw

OUT = os.path.normpath(os.path.join(os.path.dirname(__file__), "..", "assets", "icons"))
ICON_DIR = OUT
os.makedirs(ICON_DIR, exist_ok=True)

SKY_TOP = (142, 233, 255)
SKY_BOTTOM = (238, 252, 255)
GROUND = (127, 203, 85)
DARK = (74, 59, 46)
BODY = (255, 217, 74)
WING = (244, 184, 60)
BELLY = (255, 243, 212)
BEAK = (255, 138, 61)
BEAK_DARK = (232, 105, 31)
PIPE = (111, 198, 90)
PIPE_BORDER = (46, 106, 37)


def draw_scene(size: int, safe: float = 0.0) -> Image.Image:
    img = Image.new("RGBA", (size, size))
    d = ImageDraw.Draw(img)

    for y in range(size):
        t = y / max(1, size - 1)
        r = int(SKY_TOP[0] + (SKY_BOTTOM[0] - SKY_TOP[0]) * t)
        g = int(SKY_TOP[1] + (SKY_BOTTOM[1] - SKY_TOP[1]) * t)
        b = int(SKY_TOP[2] + (SKY_BOTTOM[2] - SKY_TOP[2]) * t)
        d.line([(0, y), (size, y)], fill=(r, g, b, 255))

    s = size / 512.0
    off = int(safe * size)

    d.rectangle([0, int(size - 96 * s), size, size], fill=GROUND)

    px0 = int(size * 0.10) + off // 2
    pw = int(92 * s)
    cap_h = int(56 * s)
    top_h = int(size * 0.52)
    d.rectangle([px0, -10, px0 + pw, top_h], fill=PIPE)
    cap_x0 = px0 - int(16 * s)
    cap_x1 = px0 + pw + int(16 * s)
    d.rectangle([cap_x0, -10, cap_x1, top_h + cap_h],
                fill=PIPE, outline=PIPE_BORDER, width=int(6 * s))
    d.rectangle([px0 + int(8 * s), -10, px0 + int(16 * s), top_h], fill=(60, 140, 52))

    cx = size * 0.60
    cy = size * 0.58
    r = int(78 * s)

    for ex, ey, er in [(-r * 0.72, -r * 0.08, r * 0.22),
                       (-r * 0.60, r * 0.30, r * 0.19)]:
        d.ellipse([cx + ex - er, cy + ey - er, cx + ex + er, cy + ey + er], fill=DARK)
        d.ellipse([cx + ex - er + 2 * s, cy + ey - er + 2 * s,
                   cx + ex + er + 2 * s, cy + ey + er + 2 * s], fill=WING)

    for ex, ey, er in [(-r * 0.28, -r * 0.95, r * 0.19),
                       (-r * 0.50, -r * 0.82, r * 0.14)]:
        d.ellipse([cx + ex - er, cy + ey - er, cx + ex + er, cy + ey + er], fill=DARK)
        d.ellipse([cx + ex - er + 2 * s, cy + ey - er + 2 * s,
                   cx + ex + er + 2 * s, cy + ey + er + 2 * s], fill=BODY)

    d.ellipse([cx - r, cy - r, cx + r, cy + r], fill=DARK)
    d.ellipse([cx - r + 3 * s, cy - r + 3 * s, cx + r - 3 * s, cy + r - 3 * s], fill=BODY)
    d.ellipse([cx - r * 0.45, cy + r * 0.15, cx + r * 0.78, cy + r * 0.88], fill=BELLY)

    d.polygon([(cx + r * 0.78, cy - r * 0.12), (cx + r * 1.42, cy + r * 0.10),
               (cx + r * 0.78, cy + r * 0.30)], fill=BEAK_DARK)
    d.polygon([(cx + r * 0.78, cy - r * 0.06), (cx + r * 1.32, cy + r * 0.10),
               (cx + r * 0.78, cy + r * 0.24)], fill=BEAK)

    ex = cx + r * 0.34
    ey = cy - r * 0.32
    er = r * 0.30
    d.ellipse([ex - er, ey - er, ex + er, ey + er], fill=DARK)
    er = r * 0.24
    d.ellipse([ex - er, ey - er, ex + er, ey + er], fill=(255, 255, 255, 255))
    er = r * 0.13
    d.ellipse([ex - er + 2 * s, ey - er + 2 * s, ex + er + 2 * s, ey + er + 2 * s],
              fill=(47, 47, 56, 255))

    wcx = cx - r * 0.15
    wcy = cy + r * 0.05
    d.pieslice([wcx - r * 0.7, wcy - r * 0.45, wcx + r * 0.5, wcy + r * 0.45],
               200, 360, fill=DARK)
    d.pieslice([wcx - r * 0.7 + 3 * s, wcy - r * 0.45 + 3 * s,
                wcx + r * 0.5 + 3 * s, wcy + r * 0.45 + 3 * s],
               200, 360, fill=WING)
    return img


legacy = draw_scene(512)
legacy.save(os.path.join(ICON_DIR, "icon.png"))
print("icon.png ok")

bg = draw_scene(432, safe=0.0)
bg.save(os.path.join(ICON_DIR, "adaptive_background.png"))
fg = draw_scene(432, safe=0.30)
fg.save(os.path.join(ICON_DIR, "adaptive_foreground.png"))
print("adaptive foreground/background ok")

print("done")