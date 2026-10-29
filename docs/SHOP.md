# POP DROP Gravity 0.8 — Sklep i monety (soft currency)

## Waluta: osobno od rekordu

- POP wypłaca dokładnie 1 **monetę** za każde pełne 10 punktów naliczonych z faktycznego POP (np. 320 pkt → 32 monety; 900 pkt → 90 monet). Punkty wyniku i XP nie są pomniejszane przez zakupy.
- Monety przechodzą między rundami i nie resetują się po przegranej. Zapis: `user://gravity_shop_v1.json`.
- Dotychczasowe historyczne wyniki nie są automatycznie zamieniane na monety, żeby nie naliczyć dwukrotnie punktów; portfel rozpoczyna się od 0 i nalicza się od przyszłych POP-ów.
- Każdy POP ma identyfikator `run_id:action_serial:cascade`. Ostatnie 256 jest zapamiętanych w portfelu, więc ponowny callback/ponowne rozwiązanie klatki nie nagradza dwa razy.
- To waluta **lokalna i bezpłatna**, bez logowania ani prawdziwych transakcji. Nie stosujemy cen w PLN i nie podłączamy IAP.
- Lokalny zapis nie jest źródłem zaufania dla rankingu sieciowego i może być zmieniony przez właściciela urządzenia.

## Katalog sklepu

| Pozycja | Monety | Typ | Działanie |
|---|---:|---|---|
| **Bomba** | 160 | Jednorazowa | Celowany wybuch **3×3**: usuwa kulki i zabiera **jeden punkt wytrzymałości** każdej trafionej skale |
| **+10 sekund** | 110 | Jednorazowa | Wydłuża aktualny licznik do następnej fali o 10 s (limit 45 s) |
| **Neon** | 500 | Na zawsze | Dodatkowe świecące kontury kulek |
| **Złoto** | 1200 | Na zawsze | Złoty pierścień i refleksy każdej kulki |

Dodatkowe skórki Aurora/Gwiezdne nadal odblokowują się przez poziomy doświadczenia — nie zmieniamy ich dostępności.

### Bomba

W dolnym pasku: **BOMBA ×N**. Jeśli N=0, dotknięcie otwiera sklep. Jeśli N>0, przechodzi do trybu celowania. Dotknięcie dowolnego pola detonuje 3×3 w granicach planszy. Powtórne dotknięcie przycisku bomby lub innego obszaru poza planszą anuluje celowanie bez utraty przedmiotu.

Bomba **nie przyznaje punktów/XP/monet za kulki usunięte bezpośrednio**. Po wybuchu zachodzi normalna grawitacja. Jeśli ułożą się prawdziwe POP-y, działają zwykłe kaskady i ich standardowa punktacja. Pusta detonacja nie zużywa przedmiotu. Wybuch osłabia skałę tylko o 1 — nie omija reguły 3 trafień.

### Dodatkowy czas

W dolnym pasku: **CZAS +10s ×N**. Przedmiot jest używany natychmiast; działa tylko podczas aktywnego ruchu. Zmiana od razu zapisuje stan rundy. Czas w sklepie i menu jest wstrzymany.

### Widok sklepu

Przycisk **SKLEP** pod logo w górnym pasku (również na ekranie końca rundy). Duży panel z liczbą monet, zakładką **POMOCE**, zakładką **WYGLĄDY**, dwoma kartami ofert i przyciskami kup/wybierz. Po kupieniu wyglądu zostaje on automatycznie założony i na stałe wpisany do listy posiadanych. W wyglądach ponowne dotknięcie pozwala go aktywować. Zapas każdego boosta: maksymalnie 20.

## Integralność stanu

Zakupy, portfel i użycia boostów są zapisywane natychmiast w osobnym pliku metodą temp + rename. Trwająca runda zapisuje swoją planszę i licznik w `gravity_round_v1.json`; brak destrukcyjnej migracji poprzednich save'ów. Nie ma transakcji atomowej między dwoma oddzielnymi plikami w razie wymuszonego zamknięcia dokładnie w trakcie użycia pomocy — w wersji produkcyjnej należy przygotować wspólny transakcyjny save.

Nie przyznajemy monet za reklamy, zakupy pieniężne, kliknięcia i obracanie planszy. Analityka sklepu działa wyłącznie po wcześniej wyrażonej zgodzie.

## Testy

```sh
godot --headless --path . --script res://tests/test_gravity_shop.gd
```

Test sprawdza: wymianę POP→monety, odporność na duplikaty, zakupy, odmowę przy braku waluty, trwałe skórki, jednokrotne zużywanie boostów, granice eksplozji, 3×3, osłabianie skał i brak mutacji planszy wejściowej. Workflow GitHub Actions uruchamia również wcześniejsze testy fizyki, zapisów i zwykłej rozgrywki.

## Do przetestowania na telefonie

Po uruchomieniu: zbierz monety POP-em, zakup bombę, sprawdź celowanie dotykowe i ostrzeżenia, zakup +10s, zamknij aplikację i sprawdź zachowanie portfela. Szczególnie ocenić responsywność przycisków na telefonie 720×1280 oraz czy przerwa na sklep nie pozwala łatwo obejść presję. Ceny są eksperymentalne; przed premierą warto zmierzyć medianę monety/minutę, zużycie boostów i odsetek graczy wykonujących pierwszy zakup.
