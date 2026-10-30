# POP DROP Gravity — ekonomia 0.21 beta-prep (30.10.2026)

## Monety i nagrody

Wynik, XP i waluta są oddzielne. Za każdy rzeczywisty POP gracz dostaje:

```
monety = max(3, round(sqrt(zdobytych_punktów_pop) * 0.50))
```

Dla 0 punktów: 0 monet. Dla 320: **9**; 560: **12**; 900: **15**; 9000: **47**; 90000: **150**. Nie ma limitu monet na rundę. Odbiór nagrody jest lokalnie odporny na duplikowanie tego samego identyfikatora zdarzenia. Wynik ten pochodzi z konfiguracji testowej; trzeba sprawdzić zachowanie graczy, a nie tylko botów.

Pierwszy udany zrzut każdego dnia odbiera nagrodę w cyklu 7 kolejnych dni: 20 / 30 / 50 / 70 / 90 / 120 / 150 monet. Dzień 7 odblokowuje **Gwiezdne Misie**. Misje i odznaki dają jednorazowe premie, liczone niezależnie od POP-ów.

## Moce i kontynuacja

| Moc | Cena w monetach | Funkcja |
|---|---:|---|
| Bomba | 160 | Usuwa kulki 3×3; skałom zabiera po jednym punkcie |
| Nowy Zestaw | 140 | Wymienia trzy proponowane kształty |
| Kontynuacja | 220 | Jeden ratunek na rundę, z zachowaniem wyniku |

Po wyczerpaniu ruchów kontynuacja jest dostępna za monety lub po prawdziwej reklamie nagradzanej, jeżeli plugin SDK i zgody pozwalają ją wyświetlić. Żadnych fikcyjnych nagród.

## Skórki i środowiska

Katalog zawiera 23 wpisy, w tym podstawowy wygląd i nagrodę za serię. 21 wyglądów kosztuje od **900** (Neon) do **6200** monet (Feniksy). W galerii są cztery podglądy na stronie, maksymalnie sześć stron. Kupiona skórka jest trwała i zmienia grafiki kulek, motyw świata i muzykę, bez zmiany zasad gry.

Światy: Dżungla, Ptasi, Mokradła, Safari, Las i Bajkowa Kraina. Skórki zwierzęce mają osobno zaprojektowane warianty kolorystyczne. Stare ID `capybara` jest zachowywane w zapisie i wyświetlane jako **Misie**, a `star_capybara` jako **Gwiezdne Misie**. Stary Kosmos został wycofany.

## Energia i reklamy

W **aktualnej becie** `Game.FREE_PLAY_BETA=true`: rozpoczęcie rundy nie kosztuje energii, nie trzeba czekać i nie zachęcamy do oglądania reklam za energię. Zapisy portfela nadal zawierają energię (maks. 5, regeneracja co 20 minut), aby później móc rzetelnie zbadać jej wpływ na retencję. Zmiana wymaga ponownej kalibracji.

Produkcja reklam wymaga kompatybilnego dodatku AdMob, prawidłowych jednostek, konfiguracji manifestu, UMP i weryfikacji callbacków. W `project.godot` reklamy i zdalny PostHog są domyślnie wyłączone.

## Balans, osiągnięcia i QA

- Rzadkie złote skały pojawiają się z szansą około 1/6 wśród nowych skał, mają 3 punkty życia i wypłacają 5–10 monet po zniszczeniu.
- Limit **12 równoczesnych skał** chroni długie sesje przed nieograniczonym zajmowaniem planszy.
- Fale przyspieszają 16 → 14 → 12 sekund, a nowa fala ma 4 → 5 → 6 kul; co piąta fala jest cięższa.
- Profil: dzienne misje, XP, 12 osiągnięć z kategoriami ikon.
- Godot CI: `tests/test_gravity_shop.gd`, `tests/test_gravity_balance.gd`, `tests/test_gravity_pressure.gd`, `tests/test_gravity_session.gd`, `tests/test_gravity_ads.gd`.
- Test botów nie pozwala jeszcze stwierdzić, ile minut zajmuje zdobycie Feniksa przeciętnemu człowiekowi. Po teście beta sprawdzić średni wynik/monety na sesję, progres do pierwszej skórki, D1/D7 i stosunek obejrzanych reklam do utraconych sesji.
