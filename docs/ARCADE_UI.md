# POP DROP Gravity 0.9 — arcade UI art direction

The gameplay interface is drawn natively with GDScript inside `scripts/gravity_game.gd`; no screenshots baked into the scene. All existing gameplay systems remain intact.

## Art direction

- Dark sapphire/cosmic background with restrained magenta, cyan and gold accents.
- Carefully layered glass panels (single edges, subtle highlights/shadows).
- Brand and currency navigation on the top row: coin balance, shop, profile, settings, language.
- Score, wave progress/timer and lives in one equal-height HUD row.
- Main 8×8 board with a clean 576×576 footprint, glossy marbles, a slim luminous bezel, readable stone durability.
- Dedicated bottom tray: status and charged group; separate enlarged shape selector; two large asymmetric color-coded rotate controls; smaller consumables beneath.
- Popup overlays reuse the unified panel style.
- Existing price, marbles, shop UI, physics, tutorial, telemetry and localized gameplay texts remain functional.

## Touch geometry — logical screen 720×1280

All sizes are in logical Godot coordinates. The viewport uses `_scale()` and `_offset()` to center/scalably render on other screen ratios. The same rectangles are used in hit tests and draw functions.

| Region | Coordinates |
| --- | --- |
| Header and controls | y = 37..126 |
| Score / wave / hearts | y = 133..223 |
| Board (8×8) | x = 72..648, y = 244..820 |
| Status | x = 28..692, y = 829..883 |
| Shape labels | y = 905 |
| Shape cards (3) | x = 28, 257, 486; y = 912..1018 |
| Rotate left | x = 30..345, y = 1052..1146 |
| Rotate right | x = 375..690, y = 1052..1146 |
| Bomb boost | x = 99..338, y = 1173..1236 |
| Time boost | x = 382..621, y = 1173..1236 |

The shapes finish at y=1018. The rotate buttons start at y=1052, leaving a **34-unit unobstructed gap**. Boosts are separated from the rotation controls by 27 units. This solves the previous crowding problem with real hit-target geometry, not only background visuals.

## Tests

```bash
godot --headless --path . --script res://tests/test_gravity_layout.gd
```

The test verifies view geometry, non-overlapping touch zones, their separation and mapping to the 8×8 grid. Run CI's gameplay and scene smoke tests as well.

## Design review needed after merge

Play the Android and Windows versions in a real Godot window before shipping. Review legibility of the shop/profile/settings icons, text fit in the seven current locales, frame-rate of the procedural glow, button hit-size in narrow aspect ratios, and whether the top/side backgrounds remain tasteful. Generated concept art is reference only, not baked into actual gameplay.
