from PIL import Image, ImageDraw, ImageFont
import os

def make_icon(path, size, gradient=True, text="tD", text_color="white", bg_color=None):
    img = Image.new("RGBA", (size, size), (0,0,0,0))
    draw = ImageDraw.Draw(img)
    r = size // 5
    if bg_color:
        draw.rounded_rectangle([(0,0),(size-1,size-1)], radius=r, fill=bg_color)
    elif gradient:
        for y in range(size):
            t = y / size
            r_ = int(124 + (76 - 124) * t)
            g_ = int(58 + (29 - 58) * t)
            b_ = int(237 + (149 - 237) * t)
            draw.line([(0, y), (size, y)], fill=(r_, g_, b_, 255))
        mask = Image.new("L", (size, size), 0)
        md = ImageDraw.Draw(mask)
        md.rounded_rectangle([(0,0),(size-1,size-1)], radius=r, fill=255)
        img.putalpha(mask)
    try:
        font = ImageFont.truetype("arial.ttf", int(size * 0.38))
    except:
        font = ImageFont.load_default()
    bbox = draw.textbbox((0,0), text, font=font)
    tw = bbox[2] - bbox[0]
    th = bbox[3] - bbox[1]
    x = (size - tw) / 2 - bbox[0]
    y = (size - th) / 2 - bbox[1]
    draw.text((x, y), text, fill=text_color, font=font)
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

# Adaptive icon foreground (text only, transparent bg)
foreground_sizes = [
    ("android/app/src/main/res/mipmap-mdpi/ic_launcher_foreground.png", 108),
    ("android/app/src/main/res/mipmap-hdpi/ic_launcher_foreground.png", 162),
    ("android/app/src/main/res/mipmap-xhdpi/ic_launcher_foreground.png", 216),
    ("android/app/src/main/res/mipmap-xxhdpi/ic_launcher_foreground.png", 324),
    ("android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_foreground.png", 432),
]
for path, sz in foreground_sizes:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    make_icon(path, sz, gradient=False, bg_color=None)

# Adaptive icon background (solid purple)
bg_sizes = [
    ("android/app/src/main/res/mipmap-mdpi/ic_launcher_background.png", 108),
    ("android/app/src/main/res/mipmap-hdpi/ic_launcher_background.png", 162),
    ("android/app/src/main/res/mipmap-xhdpi/ic_launcher_background.png", 216),
    ("android/app/src/main/res/mipmap-xxhdpi/ic_launcher_background.png", 324),
    ("android/app/src/main/res/mipmap-xxxhdpi/ic_launcher_background.png", 432),
]
for path, sz in bg_sizes:
    os.makedirs(os.path.dirname(path), exist_ok=True)
    make_icon(path, sz, gradient=False, text="", bg_color="#4C1D95")

# Adaptive icon XML
os.makedirs("android/app/src/main/res/mipmap-anydpi-v26", exist_ok=True)
with open("android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml", "w") as f:
    f.write('''<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
    <background android:drawable="@mipmap/ic_launcher_background"/>
    <foreground android:drawable="@mipmap/ic_launcher_foreground"/>
</adaptive-icon>
''')

print("\nToutes les icones (adaptatives incluses) generees !")
