# POP DROP Gravity 0.14 alpha — szybsze fale i więcej skał

## Tempo fal

Odstępy **maleją**, nie rosną. Pierwsza fala po 12 sekundach, następnie po 11, 10, 9 i 8 sekundach (od piątej fali stale co 8 sekund).

| Fala | Przerwa po poprzedniej | Liczba kulek | Przeszkody |
|---:|---:|---:|---|
| 1 | 12 s | 6 | +1 skała |
| 2 | 11 s | 6 | +2 skały |
| 3 | 10 s | 7 | +2 skały |
| 4 | 9 s | 7 | +2 skały |
| 5 | 8 s | 7 | +2 skały |
| 6+ | 8 s | 8 | +2 skały |

Skały pojawiają się tylko na wolnych polach, a maksymalny limit wynosi **8**. Są podatne na trzy osobne POP-y w sąsiedztwie lub bombę; obracają się wraz z planszą i nie spadają pod wpływem grawitacji. W ten sposób zmiana orientacji planszy pozostaje decyzją taktyczną.

Nowe rzędy napierają od dołu. Pełny górny rząd przed falą kosztuje życie, a ratunek usuwa kulki, ale nie skały. Gra zatrzymuje licznik podczas animacji i otwartych menu. Zapisy starszych rund zachowują się, ale odliczanie po wznowieniu jest ograniczane do nowego tempa.

## Interfejs i moce

Od wersji 0.14 są tylko dwie moce: **Bomba** i **Zamień zestaw**. Magiczny Kolor usunięto z gry oraz sklepu. Nieużyte zapasy tej mocy ze starych zapisów zamieniane są jednorazowo na 220 monet za sztukę. Ilustrowane oznaczenia A–H i 1–8 oraz stary środkowy przycisk są zasłaniane dedykowaną warstwą wektorową `assets/illustrated_v7/clean_hud_overlay.svg`.

## Testy

```sh
godot --headless --path . --script res://tests/test_gravity_pressure.gd
godot --headless --path . --script res://tests/test_gravity_shop.gd
godot --headless --path . --script res://tests/test_illustrated_art.gd
```

Balans 12/11/10/9/8 s i ośmiu skał to hipoteza do testów mobilnych, a nie potwierdzona metrykami retencja.
