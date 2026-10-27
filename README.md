# POP DROP — grywalny prototyp Godot 0.3

**Własny projekt gry**, napisany w GDScript. Wersja do testów na komputerze i późniejszego przeniesienia na Androida. Nie jest to kod ze znalezionych szablonów Unity/GitHub.

## Uruchomienie (Windows)

1. Wypakuj całe archiwum ZIP.
2. Uruchom **Godot 4.7.2** (plik bez dopisku `console`).
3. Kliknij **Importuj / Import** i wybierz **`project.godot`** z tego katalogu.
4. Kliknij **Edytuj / Edit**, a następnie **F5** (Uruchom projekt).
5. Gra otworzy się w pionowym oknie. Nie przejmuj się pustym widokiem sceny 3D w edytorze — kliknij zakładkę **2D**, a grę testuj przez F5.

## Jak grać

- Wybierz jeden z **trzech kształtów** na dole. Możesz dotknąć kształtu i następnie komórki planszy **albo przeciągnąć** go na planszę.
- Połącz **minimum trzy kulki tego samego koloru, stykające się bokami**. Wszystkie kulki takiej grupy znikają.
- Po czyszczeniu pozostałe kulki **opadają**, co może uruchomić kolejne kaskady.
- Gdy nie można położyć żadnego z pozostałych kształtów, tracisz jedno z trzech żyć i odzyskujesz trochę wolnej przestrzeni. Trzecia utrata życia kończy rundę.
- **Ponowne życie** możesz brać nieograniczoną liczbę razy przez przewidzianą w grze nagrodę za obejrzenie reklamy. **W tej wersji reklamy NIE SĄ podłączone** — przycisk prowadzi do jawnego, natychmiastowego *trybu testowego nagrody*.

## Wspomagacze

| Nazwa | Działanie |
| --- | --- |
| **Bomba** | Usuwa wszystkie kulki w obszarze 3×3 wokół wskazanego pola |
| **Spin** | Wymienia aktualny zestaw trzech kształtów na nowy |
| **Młotek** | Usuwa wskazaną kulkę |
| **Rainbow** | Usuwa wszystkie kulki w kolorze wskazanej kulki |
| **Laser** | Usuwa **rząd i kolumnę** wskazanego pola |
| **Cofnij** | Cofa ostatni ruch, przywracając planszę, wynik i zestaw |
| **STAR MODE** | Przez **15 sekund** każdy postawiony kształt usuwa cały rząd i kolumnę w miejscu upuszczenia, niezależnie od kolorów |

Na starcie otrzymujesz testowe ładunki. Gdy ich zabraknie, można przyznać kolejny ładunek przyciskiem testowej nagrody. Docelowo nagroda będzie przyznawana **dopiero po potwierdzeniu obejrzenia reklamy przez AdMob**.

## Wersje językowe

**Polski, English, Español, Português (Brasil), Deutsch, Français, Русский**.

Gra wybiera język systemowy spośród siedmiu, a w prawym górnym rogu można go przełączyć. Każdy język zawiera 49 przetłumaczonych kluczy w `localization.json`. Jeśli języka nie ma na liście, uruchamia się angielski.

## Generator i balans

- Plansza 8×8, start z kilkoma parami kolorowych kulek.
- Generator buduje **3 kształty** i analizuje **18 kandydatów na każdy slot** pod kątem wolnych pozycji, potencjalnych dopasowań i kaskad.
- Wybiera z kilku dobrych kandydatów, więc zestawy nie są zawsze identyczne.
- Na początku są 3 kolory, po 36 położonych kształtach dochodzi czwarty.
- Prostsze kształty częściej pojawiają się przy zagęszczonej planszy.
- **Nie ma narzuconego czasu zgonu ani ukrytego pogarszania układów po reklamacie lub reklamie**. Czas rund i częstotliwość komunikatów wymagają dostrojenia na realnych testerach.

## Co jest, a czego jeszcze nie ma

**Zrobione:** grywalna logika, stylizowany interfejs, mysz i dotyk, 7 języków, 7 wspomagaczy, 3 życia, wielokrotne testowe ratunki, osobne zapisy rekordów bez / z ratunkami, efekty cząsteczkowe, symulacyjny generator.

**Jeszcze nie:** rzeczywisty AdMob, ekran zarządzania zgodami (UMP), finalna oprawa i udźwiękowienie, telemetria retencji, walidacja Android AAB, rzetelna kalibracja na graczach.

**Uwaga o testach:** do projektu dołączono `tests/test_model.py`, zawierający niezależny model reguł w Pythonie. Testuje 500 losowych przebiegów, kaskady, grawitację, STAR i kompletność tłumaczeń. To NIE oznacza, że Godot został automatycznie uruchomiony w tym środowisku — **przy pierwszym imporcie i F5 trzeba jeszcze sprawdzić działanie samego silnika**. Test logiki modelu: `python tests/test_model.py`. Dodatkowy, bezpośredni test GDScript uruchomisz po instalacji silnika poleceniem `godot --headless --path . --script res://tests/test_rules.gd` (nie uruchomiono go w środowisku tworzenia paczki).

## Gdzie edytować

- `scripts/game.gd` — widok, interakcje, bonusy, życia, ekran końca rundy, nagrody testowe.
- `scripts/rules.gd` — układy, generator, dopasowania, grawitacja, symulacja.
- `localization.json` — wszystkie języki gry.
- `scenes/main.tscn` — główna scena.
- `PODGLAD-UI.png` — **ilustracyjny podgląd stylu**, a nie zrzut uruchomionej gry.
- `docs/REKLAMY.md` — co trzeba zrobić przed publikacją reklam.

## Licencje assetów

Fonty Clear Sans (Copyright © Intel 2013) — Apache 2.0. Teksty licencji w `fonts/`. Pozostałe elementy gry zostały napisane od zera na potrzeby tego projektu.
