# POP DROP Gravity — aktualna lista zadań po audycie 30.10.2026

## Zrobione w 0.21 beta-prep
- Przeszukiwanie różnych sekwencji darmowych obrotów z deduplikacją stanów; brak fałszywej przegranej przy limicie analizy.
- Test regresyjny sekwencji L-R-L-R oraz pełnego zablokowania kamieniami.
- Darmowe, nieograniczone starty rund w beta (bez odliczania energii).
- Katalog skórek w siatce 2×2, sześć stron zamiast dwunastu.
- Uczciwa nazwa kasowania tylko lokalnych danych analitycznych.
- Wersja projektu `0.21.0-beta-prep`.

## Przed zamkniętą betą
1. Zatwierdzenie UI na pięciu zrzutach z realnego Godota i na telefonach w kilku proporcjach; poprawa spójności ustawień, sklepu, profilu, końca gry.
2. Test fizyki i czasu obliczeń na tańszym Androidzie; szczególnie dłuższy BFS ratunku.
3. Sesje z 10–20 ludźmi, test pierwszego POP-a i zrozumiałości obrotu oraz przegranej.
4. Symulacja rozgrywek: środkowa długość rundy, fale, częstość POP, monety na rundę, wydawanie na skórki.
5. Kompletne tłumaczenia wszystkich widoków (obecnie część sklepu/profilu jest PL/EN).
6. PostHog, prywatność, obsługa przerwanego zapisu i crash reporting.
7. Plugin AdMob/UMP, zgodność ze zgodami, eksport i podpis Android AAB; nie włączać prawdziwych reklam przed testami.
8. Zewnętrzna beta i metryki D1/D7; ograniczenie energii wyłącznie po zweryfikowaniu efektów.

## Definicja beta-ready
Brak utraty postępu, brak fałszywych porażek, zero wyciekających hitboxów, zweryfikowane FPS, jasny onboarding i spełnione warunki prywatności. Zielone CI jest konieczne, lecz niewystarczające.
