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
- Generator używa teraz **12 celowo dobranych sylwetek**: 1 pojedyncza kulka, 2 pary, 3 trójki, 6 czwórek (linia, kwadrat, L, T, **S, Z**). Przy luźnej planszy udziały rozmiarów to około **6% / 34% / 31% / 29%** (1/2/3/4 kulki). Czwórki trafiają się dużo częściej, a S i Z są dodatkowo promowane wśród czwórek. Ostatnie 5 sylwetek jest lekko wyciszanych w losowaniu, żeby tace nie wyglądały stale tak samo. Gęsta plansza preferuje mniejsze układy.
- Widać aktualny kształt oraz dwa następne (podgląd).
- **Dotknij kolumny** na planszy, żeby zrzucić kształt; spadnie do swoich kolumn. Następny kształt automatycznie wchodzi do gry — **przycisk „Dalej” został usunięty**.
- **Dwa duże przyciski pod planszą** obracają planszę w lewo albo w prawo. Przesuwanie palcem po planszy nie wywołuje obrotu — plansza służy wyłącznie do zrzucania kulek.
- Obracaj **ile chcesz, przed zrzutem lub po nim**, bez zużywania kształtów. Obroty mogą uruchamiać kaskady; gracz sam wybiera, kiedy znów coś zrzucić.
- Start jest bardziej żywy: **20 kulek** w przygotowanym układzie (bez gotowego match-3).
- Obrót obraca zawartość planszy o 90°, a następnie kulki opadają zgodnie z ekranową grawitacją. Kolorowe grupy **3+ sąsiadujących bokami kulek** znikają, a pozostałe spadają.
- Kolejne połączenia uruchamiają kaskady. Gracz powinien zrozumieć, jak obrót może je wywołać.
- Większe figury nie są sklejone po zrzucie: liczy się **ile kulek, w których kolumnach i w jakiej kolejności** spada. Dzięki temu S i Z z identycznymi kolorami mogą dać dwa różne układy na planszy. Generator nie powinien podawać czterech kulek, które same bez pomocy planszy automatycznie eksplodują.
- 3 życia na rundę. Nie tracisz życia, jeśli kształt nie mieści się w danej chwili, **ale obrót mógłby zrobić dla niego miejsce**. Życie tracisz dopiero gdy żadne z przetestowanych położeń po obrocie nie daje możliwości zrzutu.
- Po 3. utraconym życiu pojawia się **TEST: +1 ŻYCIE**. To przycisk demonstracyjny, **nie reklama**. Reklam jeszcze nie zintegrowano.

## Zakres i ograniczenia

- Interfejs, zasady obrotu, grawitacja, dopasowania, kaskady, 7 języków interfejsu, rekord i demonstracyjne życie.
- Obroty są na razie **nielimitowane** (hipoteza do sprawdzenia). Wielokrotne kręcenie może nadmiernie ułatwiać grę — oceniamy to w testach.
- Tempo prototypu: zrzut ~0,19 s, obrót ~0,22 s, opadanie ~0,18 s oraz krótsze pauzy przy POP. Przyciski i zrzut reagują na naciśnięcie, bez potrzeby czekania na puszczenie przycisku/palca.
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

## Efekty wizualne — aktualizacja 27.10.2026

Animacje są częścią gałęzi `gravity-prototype` (nie `main`). Zastosowano **proceduralny system efektów bez tekstur i zewnętrznych assetów**:

- **Obrót:** łuk 90° z wygładzonym ruchem kulek, trzema świetlnymi echami, podświetleniem obręczy i subtelnym ruchem planszy.
- **Zrzut/opad:** przyspieszony optycznie lot ze smugami; po zatrzymaniu wybuchają krótkie iskry i pojawia się fala uderzeniowa.
- **POP:** 0,18–0,21 s napięcia (rozświetlanie i pęcznienie połączonych kulek), eksplozja kolorowych iskier, rozchodzący się pierścień, błysk, drgnięcie planszy i unoszące się punkty; kaskady wzmacniają efekty.
- **Interfejs:** płynne naliczanie wyniku, sprężyste komunikaty i lekkie świetlne drobiny w tle.
- **Responsywność:** w czasie animacji zapamiętywany jest jeden ostatni klik obrotu/zrzutu i wykonywany po zakończeniu sekwencji; gracz nie musi klikać ponownie. Logika punktów, spadania i generatora pozostaje bez zmian.
- **Budżet wydajności:** maksymalnie 220 iskier, 14 fal i 10 wyskakujących punktacji równocześnie.

### Ręczny test po Pull

1. Zrzuć kształt na wysoką kolumnę: obserwuj smugę i iskry przy lądowaniu.
2. Obróć w lewo i prawo: wszystkie kulki powinny wykonać ćwierćokrąg, po czym opaść.
3. Ułóż grupę 3+ identycznych kulek: powinny rozświetlić się *przed* eksplozją, a wynik powinien policzyć się płynnie.
4. Wywołaj kaskadę: obserwuj osobne wybuchy i mnożnik `×2`, `×3`.
5. Podczas animacji szybko naciśnij kolejny obrót: powinien wykonać się automatycznie po zakończeniu aktualnego.

**Status walidacji:** sprawdzono strukturę pliku i zapisy w GitHubie, ale w środowisku implementacji nie było uruchamialnego silnika Godot. Należy uruchomić projekt klawiszem F5 i sprawdzić konsolę oraz płynność na docelowym telefonie.
