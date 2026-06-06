from PIL import Image, ImageDraw
import os

C_BG = (11, 12, 16)
C_CYAN = (0, 242, 254)
C_BLUE = (79, 172, 254)

def make_icon(path, size):
    img = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)

    g = size / 100.0

    # Background rounded rect
    r = int(20 * g)
    draw.rounded_rectangle([(0, 0), (size - 1, size - 1)], radius=r, fill=C_BG + (255,))
    # Subtle border
    for i in range(1, -1, -1):
        alpha = 18 + i * 8
        draw.rounded_rectangle(
            [(i, i), (size - 1 - i, size - 1 - i)], radius=r - i,
            outline=(255, 255, 255, alpha), width=1
        )

    # Gradient for loop/arrow
    def grad_line(y1, y2):
        return tuple(int(a + (b - a) * (i / max(y2 - y1, 1))) for i in range(y2 - y1 + 1)
                     for a, b in zip(C_CYAN, C_BLUE))

    # Loop: open arc (left side, opens to top-right)
    cx, cy = 50 * g, 52 * g
    lw = int(5 * g)

    # --- Loop shape (left arc + right arrow) ---
    pts = []

    # Lower curve (bottom of loop)
    for a in range(180, 280):
        rad = a * 3.14159 / 180
        r_loop = 22 * g
        x = cx - r_loop * 0.5 + r_loop * 1.2 * (1 + (a - 180) / 100) * 0.5
        y = cy + r_loop * (1 if a < 230 else 0.7 + 0.3 * (280 - a) / 50)
        pts.append((x, y))

    # Right side: arrow going up-right
    arrow_start = pts[-1]
    ax, ay = arrow_start
    tip_x = ax + 32 * g
    tip_y = ay - 28 * g

    # Main line to tip
    steps = 12
    for i in range(steps):
        t = (i + 1) / steps
        pts.append((ax + (tip_x - ax) * t, ay + (tip_y - ay) * t))

    # Arrow head
    head_size = 10 * g
    ah1 = (tip_x - head_size * 0.7, tip_y + head_size * 0.5)
    ah2 = (tip_x - head_size * 0.5, tip_y - head_size * 0.3)
    pts.append((tip_x, tip_y))
    pts.append(ah1)
    pts.append(ah2)

    # Upper curve (top of loop, returning to left)
    for a in range(310, 420):
        rad = a * 3.14159 / 180
        r_loop = 22 * g
        t = (a - 310) / 110
        x = cx - r_loop * 0.5 + r_loop * 1.2 * (1 - t) * 0.5
        y = cy - r_loop * (0.8 - t * 0.3)
        pts.append((x, y))

    if len(pts) > 1:
        color_prog = [(int(C_CYAN[j] + (C_BLUE[j] - C_CYAN[j]) * (i / len(pts)))) for i in range(len(pts)) for j in range(3)]
        color_prog = [(color_prog[i * 3], color_prog[i * 3 + 1], color_prog[i * 3 + 2]) for i in range(len(pts))]

        for i in range(len(pts) - 1):
            ci = color_prog[i]
            draw.line([pts[i], pts[i + 1]], fill=ci + (255,), width=lw)

        # Glow
        for i in range(len(pts) - 1):
            ci = color_prog[i]
            draw.line([pts[i], pts[i + 1]], fill=ci + (60,), width=lw + 6)

    # Small accent dot (new start / habit trigger)
    dot_r = int(4 * g)
    draw.ellipse(
        [cx - dot_r - 10 * g, cy + 10 * g - dot_r,
         cx - dot_r - 10 * g + dot_r * 2, cy + 10 * g - dot_r + dot_r * 2],
        fill=C_CYAN + (255,)
    )

    img.save(path, "PNG")
    print(f"  {path} ({size}x{size})")


os.makedirs("assets/icons", exist_ok=True)
make_icon("assets/icons/icon-1024.png", 1024)

sizes = [
    ("android/app/src/main/res/mipmap-mdpi/ic_launcher.png", 48),
    ("android/app/src/main/res/mipmap-hdpi/ic_launcher.png", 72),
    ("android/app/src/main/res/mipmap-xhdpi/ic_launcher.png", 96),
    ("android/app/src/main/res/mipmap-xxhdpi/ic_launcher.png", 144),
    ("android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png", 192),
    ("ios/Runner/Assets.xcassets/AppIcon.appiconset/icon-1024.png", 1024),
    ("web/icons/icon-192.png", 192),
    ("web/icons/icon-512.png", 512),
]
for path, sz in sizes:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    make_icon(path, sz)

# Adaptive icon foreground (transparent bg)
foreground_sizes = [
    ("android/app/src/main/res/mipmap-mdpi/ic_launcher_foreground.png", 108),
    ("android/app/src/main/res/mipmap-hdpi/ic_launcher_foreground.png", 162),
    ("android/app/src/main/res/mipmap-xhdpi/ic_launcher_foreground.png", 216),
    ("android/app/src/main/res/mipmap-xxhdpi/ic_launcher_foreground.png", 324),
    ("android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground.png", 432),
]
for path, sz in foreground_sizes:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    make_icon(path, sz)

# Adaptive icon background (dark)
bg_sizes = [
    ("android/app/src/main/res/mipmap-mdpi/ic_launcher_background.png", 108),
    ("android/app/src/main/res/mipmap-hdpi/ic_launcher_background.png", 162),
    ("android/app/src/main/res/mipmap-xhdpi/ic_launcher_background.png", 216),
    ("android/app/src/main/res/mipmap-xxhdpi/ic_launcher_background.png", 324),
    ("android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_background.png", 432),
]
for path, sz in bg_sizes:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    bg = Image.new("RGBA", (sz, sz), C_BG + (255,))
    bg.save(path, "PNG")
    print(f"  {path} ({sz}x{sz})")

os.makedirs("android/app/src/main/res/mipmap-anydpi-v26", exist_ok=True)
with open("android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml", "w") as f:
    f.write('''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
''')

print("\nToutes les icones generees !")
