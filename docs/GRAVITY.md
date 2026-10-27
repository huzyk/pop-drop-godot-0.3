# POP DROP Gravity — prototyp mechaniki (gałąź `gravity-prototype`)

**To eksperyment z nowymi zasadami, a nie gotowa aktualizacja gry.** Oryginalny POP DROP pozostaje na gałęzi `main`.

## Jak uruchomić — bez nowego ZIP

1. Zamknij Godot, jeśli jest uruchomiony.
2. W **GitHub Desktop** wybierz repozytorium `pop-drop-godot-0.3`.
3. Kliknij **Fetch origin**.
4. Otwórz listę **Current branch**, znajdź **gravity-prototype**, wybierz **Switch branch**. Jeśli najpierw widzisz opcję **New branch**, sprawdź zakładkę z gałęziami zdalnymi, a nie twórz nowej.
5. Jeśli pojawi się **Pull origin**, kliknij.
6. Otwórz ten **sam projekt** w Godot 4.7.2 i wciśnij **F5**. Na tej gałęzi `project.godot` uruchamia `scenes/gravity.tscn`.

Po zakończeniu testów możesz ponownie przełączyć **Current branch → main**, żeby wrócić do poprzedniej gry. Nie twórz nowego projektu, nie importuj ponownie i nie kasuj żadnych plików.

## Zasady do przetestowania

- Plansza 8 × 8; 3 kolory, z góry spada **jeden mały kształt**.
- **75%** podstawowych losowań to pary dwóch kulek; ok. **15%** — trójki, **10%** — pojedyncza kulka. Gęsta plansza preferuje pojedyncze kulki.
- Widać aktualny kształt oraz dwa następne (podgląd).
- **Dotknij kolumny** na planszy, żeby zrzucić kształt; spadnie do swoich kolumn. Następny kształt automatycznie wchodzi do gry — **przycisk „Dalej” został usunięty**.
- **Przesuń palcem / myszką poziomo po planszy**, żeby wykonać obrót: w lewo = przeciwnie do wskazówek zegara, w prawo = zgodnie. Można też użyć dwóch przycisków pod planszą.
- Obracaj **ile chcesz, przed zrzutem lub po nim**, bez zużywania kształtów. Obroty mogą uruchamiać kaskady; gracz sam wybiera, kiedy znów coś zrzucić.
- Start jest bardziej żywy: **20 kulek** w przygotowanym układzie (bez gotowego match-3).
- Obrót obraca zawartość planszy o 90°, a następnie kulki opadają zgodnie z ekranową grawitacją. Kolorowe grupy **3+ sąsiadujących bokami kulek** znikają, a pozostałe spadają.
- Kolejne połączenia uruchamiają kaskady. Gracz powinien zrozumieć, jak obrót może je wywołać.
- 3 życia na rundę. Nie tracisz życia, jeśli kształt nie mieści się w danej chwili, **ale obrót mógłby zrobić dla niego miejsce**. Życie tracisz dopiero gdy żadne z przetestowanych położeń po obrocie nie daje możliwości zrzutu.
- Po 3. utraconym życiu pojawia się **TEST: +1 ŻYCIE**. To przycisk demonstracyjny, **nie reklama**. Reklam jeszcze nie zintegrowano.

## Zakres i ograniczenia

- Interfejs, zasady obrotu, grawitacja, dopasowania, kaskady, 7 języków interfejsu, rekord i demonstracyjne życie.
- Obroty są na razie **nielimitowane** (hipoteza do sprawdzenia). Wielokrotne kręcenie może nadmiernie ułatwiać grę — oceniamy to w testach.
- Tempo prototypu: zrzut ~0,19 s, obrót ~0,22 s, opadanie ~0,18 s oraz krótsze pauzy przy POP. Sterowanie działa po zwolnieniu palca/przycisku myszy, więc gest nie zrzuca przy okazji kształtu.
- To **prototyp oceny przyjemności z gry**. Nie zawiera jeszcze wspomagaczy Bomba / Spin / Laser / Undo / STAR MODE, nie ma AdMob ani docelowych animacji i audio.
- Fizyka jest **deterministyczna na siatce** (żadne losowe kolizje Rigidbody). Animacje przedstawiają obrót po łuku i opadanie.
- Nie uruchomiono jeszcze testów we własnym silniku Godot w środowisku tworzenia. Testy logiczne należy uruchomić na maszynie z Godot 4.7.2 i sprawdzić błędy konsoli.

## Test bez grafiki

Z katalogu repozytorium:

```powershell
godot --headless --path . --script res://tests/test_gravity_rules.gd
```

(Polecenie `godot` musi być dostępne w PATH lub zastąp je pełną ścieżką do pliku EXE.)

Test sprawdza zrzucanie pionowych i poziomych par, sprawdzanie legalnych ruchów, oba obroty, grawitację, match-3 i 300 symulowanych ruchów.

## Co oceniamy

Najpierw oceń, **czy wiesz przed ruchem, co chcesz osiągnąć**. Następnie, czy obrót daje satysfakcję i czy rozgrywka jest łatwa. Dopiero gdy te trzy rzeczy zadziałają, warto inwestować we wspomagacze, reklamowe ratunki i grafikę.
