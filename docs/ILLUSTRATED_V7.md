# POP DROP — Illustrated UI 0.13.1

The current gameplay renderer is `scripts/gravity_illustrated.gd`. It retains all model/economy logic in `gravity_game.gd` while using a commissioned static scene background plus independently composited glass marbles and rocks. `gravity_studio.gd` is retained as a shared component renderer for profile/shop/modals and all purchased skin types.

## Visual integrity fixes

- The 8×8 ceramic matrix was rebuilt with exact coordinates, without duplicate/ghost rows and jagged AI joins.
- Model, tapping and artwork share `BOARD=(88,292,536,536)` and `CELL=67`. Changing one requires changing both and tests.
- Preview silhouettes use bounded sprite metrics and must never obscure the label at the base of a card; selected card has an author-designed outline sprite.
- Decorative stars and progress in the initial illustration are *not* awarded gameplay state; that row displays live GROUP/MOVE/HEIGHT values. Empty booster inventory is marked `+` to indicate it opens the shop.
- Separate 256×256 RGBA WebP sprites are loaded with filtering for smooth small-size edges; game objects remain individually animated sprites, not a static screenshot.
- Never stack the original V6 procedural board/HUD over the illustrated artwork. Avoid manufacturing a new UI by drawing outlines over baked UI.

## QA

Test `test_illustrated_art.gd` plus all current gameplay tests and capture all 5 450×800 Godot screenshots. Evaluate both initial screenshot and a screenshot of a 3-high piece against actual touch bounds.

## Limitations

Some Polish strings (top-level menu labels) and decorative details are baked into the supplied illustration. A full multilingual launch requires splitting and repainting these areas as separate material sprites rather than pretending the text is localized. The conceptual illustration is not a screen-by-screen exact specification of the underlying gameplay mechanics.
