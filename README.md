# POP DROP Gravity 0.9 — polished arcade interface

**UI redesign:** premium HUD at the top, 8×8 game board (576×576), separate enlarged three-card shape selector, spacious rotation controls, and dedicated power-up dock. Touch regions and graphics use the same geometry. Full details: [docs/ARCADE_UI.md](docs/ARCADE_UI.md).

---

# POP DROP Gravity 0.8 — sklep za monety

**Nowość:** monety za POP-y, sklep z bombami 3×3, dodatkowymi 10 sekundami i trwałymi wyglądami kulek. Wynik i XP są odrębne od waluty. W grze kliknij **SKLEP** u góry; na dole są dwa przyciski pomocy. Więcej: [docs/SHOP.md](docs/SHOP.md).

---

# POP DROP Gravity 0.7 — progressive waves and three-hit rocks

**Nowe:** fala napierająca od dołu po **15 sekundach**, potem po 19 / 23 / 27 / 31 / 35 / 39 s (maks. 39 s); 6 kulek w pierwszych falach, później 7 i 8. Co druga fala może dodać twardą skałę (maks. 3 na planszy), która pęka dopiero po **trzech odrębnych POP-ach przylegających bokiem**. Czas stoi podczas animacji i w menu. Zobacz [docs/PRESSURE.md](docs/PRESSURE.md).

---

# POP DROP Gravity — efekty i wibracje (0.6 alpha)

**Nowości:** osiem oryginalnych efektów dźwiękowych (synteza PCM, bez plików i zewnętrznych licencji), haptyka z krótkimi impulsami oraz dodatkowa celebracja zdobycia poziomu. Ustawienia dźwięku i wibracji są dostępne w menu **DATA**, zachowują się po restarcie. Na Androidzie wibracje wymagają pozwolenia `VIBRATE` w ustawieniach eksportu. Więcej: [docs/FEEDBACK.md](docs/FEEDBACK.md).

Pozostałe funkcje: [docs/RETENTION.md](docs/RETENTION.md) i [docs/MOBILE_FOUNDATION.md](docs/MOBILE_FOUNDATION.md).

---

# POP DROP Gravity — retencja i progresja (0.5 alpha)

**Nowość:** misje dzienne, XP, poziomy gracza, seria aktywnych dni i kosmetyczne warianty kulek. Otwórz **POZ. / LVL** w prawym górnym pasku gry. Aktualne zasady i testy: [docs/RETENTION.md](docs/RETENTION.md).

**Uwaga:** produkcyjne AdMob/UMP oraz serwerowy projekt analityczny nadal wymagają konfiguracji, a bezpośrednie testy na telefonie pozostają do wykonania. W GitHub Actions dodano testy Godot 4.7.2. Starsze sekcje README opisują historyczny prototyp.

---

# POP DROP Gravity — mobile foundation (0.4 alpha)

**Aktualny `main` uruchamia scenę Gravity**, a nie starą grę 0.3. Na gałęzi `feature/mobile-foundation` przygotowano zapis rundy, analitykę za zgodą oraz opcjonalne połączenie AdMob/UMP. Szczegóły wdrożenia, wymagane konfiguracje i testy: [docs/MOBILE_FOUNDATION.md](docs/MOBILE_FOUNDATION.md).

**Uwaga:** nie skonfigurowano produkcyjnych jednostek AdMob ani projektu PostHog. Nie jest to build gotowy do publicznego wydania. Fragmenty starszej dokumentacji niżej dotyczą historycznego prototypu 0.3.

---

# POP DROP Gravity — osobny prototyp

**Jesteś na gałęzi `gravity-prototype`.** W Godot klawisz **F5** uruchamia nową scenę z kulkami zrzucanymi od góry, jednym opcjonalnym obrotem w prawo lub lewo i grawitacją. Stara mechanika opisana poniżej jest zachowana na gałęzi `main`, ale **nie jest** uruchamiana w tej gałęzi.

**Instrukcja i nowe reguły:** [docs/GRAVITY.md](docs/GRAVITY.md).

---

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
- Generator buduje **3 kształty** i analizuje **18 kandydatów na każdy slot**; od wersji 0.3.1 planuje legalną sekwencję trzech kolejnych ruchów, a nie każdy element osobno.
- Wybiera z kilku dobrych kandydatów, więc zestawy nie są zawsze identyczne. W zwykłych sytuacjach każdy z trzech kształtów pasuje też do **obecnej** planszy. Przy wyjątkowo pełnej planszy możliwa jest porażka i ratunek.
- Na początku są 3 kolory, po 36 położonych kształtach dochodzi czwarty.
- Prostsze kształty częściej pojawiają się przy zagęszczonej planszy.
- **Nie ma narzuconego czasu zgonu ani ukrytego pogarszania układów po reklamacie lub reklamie**. Czas rund i częstotliwość komunikatów wymagają dostrojenia na realnych testerach.

## Co jest, a czego jeszcze nie ma

**Zrobione:** grywalna logika, stylizowany interfejs, mysz i dotyk, 7 języków, 7 wspomagaczy, 3 życia, wielokrotne testowe ratunki, osobne zapisy rekordów bez / z ratunkami, efekty cząsteczkowe, symulacyjny generator.

**Jeszcze nie:** rzeczywisty AdMob, ekran zarządzania zgodami (UMP), finalna oprawa i udźwiękowienie, telemetria retencji, walidacja Android AAB, rzetelna kalibracja na graczach.

**Uwaga o testach:** do projektu dołączono `tests/test_model.py`, zawierający niezależny model reguł w Pythonie. Testuje 500 losowych przebiegów, kaskady, grawitację, STAR i kompletność tłumaczeń. To NIE oznacza, że Godot został automatycznie uruchomiony w tym środowisku — **przy pierwszym imporcie i F5 trzeba jeszcze sprawdzić działanie samego silnika**. Test logiki modelu: `python tests/test_model.py`. Dodatkowy, bezpośredni test GDScript (w tym sprawdzanie trzyruchowych planów na planszach pustej, startowej i gęstej) uruchomisz po instalacji silnika poleceniem `godot --headless --path . --script res://tests/test_rules.gd`. Ten test wymaga uruchomienia Godot na Twoim komputerze — nie został jeszcze zweryfikowany w samym silniku. Zmianę 0.3.1 zapisano bezpośrednio w GitHubie.

## Gdzie edytować

- `scripts/game.gd` — widok, interakcje, bonusy, życia, ekran końca rundy, nagrody testowe.
- `scripts/rules.gd` — układy, generator, dopasowania, grawitacja, symulacja.
- `localization.json` — wszystkie języki gry.
- `scenes/main.tscn` — główna scena.
- `PODGLAD-UI.png` — **ilustracyjny podgląd stylu**, a nie zrzut uruchomionej gry.
- `docs/REKLAMY.md` — co trzeba zrobić przed publikacją reklam.

## Licencje assetów

Fonty Clear Sans (Copyright © Intel 2013) — Apache 2.0. Teksty licencji w `fonts/`. Pozostałe elementy gry zostały napisane od zera na potrzeby tego projektu.


## Aktualizacja 0.3.1 — generator

- Generator testuje hipotetyczne położenie pierwszego i drugiego kształtu, zanim dobierze następny. Dzięki temu nie rozdaje trzech elementów ocenianych na niezmienionej planszy.
- `generate_tray_plan` zwraca także pozycje do testowania kolejnych ruchów. Nie są widoczne dla gracza; to narzędzie walidacji generatora.
- Testy GDScript obejmują 90 losowanych zestawów na trzech rodzajach plansz.
- Mechanika nadal wymaga testów odczuć i kalibracji czasu rund. Projekt nie zawiera prawdziwych reklam i nie powinien być jeszcze publikowany.


## Poprawka reguł (27.10.2026)

Wcześniej trzy jednakowe kulki wygenerowane **w jednym kształcie** mogły od razu zniknąć po dowolnym umieszczeniu, nawet na pustej planszy. To sprawiało, że wybór miejsca nie miał znaczenia. Generator `make_candidate` w `scripts/rules.gd` teraz wykrywa i usuwa takie samodzielnie punktujące układy (zachowując pary kolorów). Test GDScript sprawdza kandydatów i tace, aby problem nie powracał. Próg 3 stykających się kulek nadal obowiązuje po ułożeniu na planszy.

Ważne: zmiana została zapisana w GitHubie, ale testów GDScript nie uruchomiono jeszcze w rzeczywistym silniku Godot. Na komputerze pobierz aktualizację przez Fetch/Pull i uruchom F5.
