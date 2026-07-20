#!/usr/bin/env python3
"""submil アプリアイコン候補ジェネレータ (1024x1024, light/dark/tinted)."""
from PIL import Image, ImageDraw
import math
import os

SIZE = 1024
SS = 4  # supersample
S = SIZE * SS
OUT = os.path.join(os.path.dirname(__file__), "icons")
os.makedirs(OUT, exist_ok=True)


def lerp(a, b, t):
    return tuple(int(a[i] + (b[i] - a[i]) * t) for i in range(3))


def gradient_bg(c_top, c_bottom):
    img = Image.new("RGB", (S, S))
    d = ImageDraw.Draw(img)
    for y in range(S):
        d.line([(0, y), (S, y)], fill=lerp(c_top, c_bottom, y / S))
    return img


def rline(d, pts, width, fill):
    """round-capped polyline"""
    d.line(pts, fill=fill, width=width, joint="curve")
    r = width // 2
    for p in (pts[0], pts[-1]):
        d.ellipse([p[0] - r, p[1] - r, p[0] + r, p[1] + r], fill=fill)


def yen(d, cx, cy, h, width, fill):
    """¥ グリフを手描き (h=全高)"""
    top = cy - h / 2
    mid = cy + h * 0.02          # V の合流点
    bot = cy + h / 2
    arm = h * 0.42               # V の開き幅
    rline(d, [(cx - arm, top), (cx, mid)], width, fill)
    rline(d, [(cx + arm, top), (cx, mid)], width, fill)
    rline(d, [(cx, mid), (cx, bot)], width, fill)
    bw = h * 0.34
    y1 = mid + h * 0.13
    y2 = y1 + h * 0.19
    rline(d, [(cx - bw, y1), (cx + bw, y1)], width, fill)
    rline(d, [(cx - bw, y2), (cx + bw, y2)], width, fill)


def check(d, cx, cy, scale, width, fill):
    pts = [(cx - 0.42 * scale, cy + 0.02 * scale),
           (cx - 0.10 * scale, cy + 0.34 * scale),
           (cx + 0.46 * scale, cy - 0.30 * scale)]
    rline(d, pts, width, fill)


def finish(img, name):
    img = img.resize((SIZE, SIZE), Image.LANCZOS)
    img.save(os.path.join(OUT, name + ".png"))


# ---------- 案A: ¥ + チェックバッジ (teal→green) ----------
def cand_a(variant):
    if variant == "light":
        bg = gradient_bg((16, 150, 145), (46, 190, 120))
        glyph, badge_bg, badge_fg = (255, 255, 255), (255, 255, 255), (22, 160, 133)
    elif variant == "dark":
        bg = gradient_bg((8, 60, 58), (14, 82, 52))
        glyph, badge_bg, badge_fg = (120, 235, 190), (120, 235, 190), (8, 60, 58)
    else:  # tinted: グレースケール
        bg = gradient_bg((40, 40, 40), (12, 12, 12))
        glyph, badge_bg, badge_fg = (235, 235, 235), (235, 235, 235), (30, 30, 30)
    d = ImageDraw.Draw(bg)
    yen(d, S * 0.46, S * 0.47, S * 0.52, int(S * 0.075), glyph)
    bc = (S * 0.735, S * 0.72)
    br = S * 0.155
    d.ellipse([bc[0] - br, bc[1] - br, bc[0] + br, bc[1] + br], fill=badge_bg)
    check(d, bc[0], bc[1] - S * 0.005, br * 1.05, int(S * 0.045), badge_fg)
    finish(bg, f"A-{variant}")


# ---------- 案B: カードスタック + チェック (indigo→violet) ----------
def cand_b(variant):
    if variant == "light":
        bg = gradient_bg((78, 84, 200), (143, 84, 233))
        c_back2, c_back1 = (255, 255, 255, 70), (255, 255, 255, 140)
        c_front, c_check = (255, 255, 255, 255), (94, 92, 230)
    elif variant == "dark":
        bg = gradient_bg((30, 32, 78), (52, 30, 88))
        c_back2, c_back1 = (200, 200, 255, 50), (200, 200, 255, 100)
        c_front, c_check = (205, 200, 255, 255), (40, 36, 96)
    else:
        bg = gradient_bg((40, 40, 40), (12, 12, 12))
        c_back2, c_back1 = (235, 235, 235, 60), (235, 235, 235, 120)
        c_front, c_check = (235, 235, 235, 255), (25, 25, 25)
    bg = bg.convert("RGBA")
    layer = Image.new("RGBA", (S, S), (0, 0, 0, 0))
    d = ImageDraw.Draw(layer)
    w, h = S * 0.60, S * 0.40
    rad = int(S * 0.055)
    for (dy, col) in [(-S * 0.16, c_back2), (-S * 0.08, c_back1), (0, c_front)]:
        cx, cy = S * 0.5, S * 0.55 + dy
        d.rounded_rectangle([cx - w / 2, cy - h / 2, cx + w / 2, cy + h / 2],
                            radius=rad, fill=col)
    check(d, S * 0.5, S * 0.55, S * 0.30, int(S * 0.055), c_check)
    bg.alpha_composite(layer)
    finish(bg.convert("RGB"), f"B-{variant}")


# ---------- 案C: ルーペ + ¥ (blue→cyan) ----------
def cand_c(variant):
    if variant == "light":
        bg = gradient_bg((0, 110, 230), (0, 190, 214))
        ring, glyph = (255, 255, 255), (255, 255, 255)
    elif variant == "dark":
        bg = gradient_bg((6, 40, 84), (4, 70, 80))
        ring, glyph = (140, 220, 255), (140, 220, 255)
    else:
        bg = gradient_bg((40, 40, 40), (12, 12, 12))
        ring, glyph = (235, 235, 235), (235, 235, 235)
    d = ImageDraw.Draw(bg)
    cx, cy = S * 0.46, S * 0.44
    r = S * 0.27
    lw = int(S * 0.055)
    d.ellipse([cx - r, cy - r, cx + r, cy + r], outline=ring, width=lw)
    # ハンドル
    ang = math.radians(45)
    hx1 = cx + (r + lw * 0.2) * math.cos(ang)
    hy1 = cy + (r + lw * 0.2) * math.sin(ang)
    hx2 = cx + (r + S * 0.20) * math.cos(ang)
    hy2 = cy + (r + S * 0.20) * math.sin(ang)
    rline(d, [(hx1, hy1), (hx2, hy2)], int(S * 0.075), ring)
    yen(d, cx, cy + S * 0.01, r * 1.05, int(S * 0.042), glyph)
    finish(bg, f"C-{variant}")


for v in ("light", "dark", "tinted"):
    cand_a(v)
    cand_b(v)
    cand_c(v)
print("done:", sorted(os.listdir(OUT)))
