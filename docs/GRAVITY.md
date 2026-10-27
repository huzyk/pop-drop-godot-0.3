# POP DROP Gravity — prototyp mechaniki (gałąź `gravity-prototype`)

**To eksperyment z nowymi zasadami, a nie gotowa aktualizacja gry.** Oryginalny POP DROP pozostaje na gałęzi `main`.

## Jak uruchomić — bez nowego ZIP

1. Godot może pozostać otwarty; w razie potrzeby zatrzymaj uruchomioną grę (F8). Przy zmianach skryptów edytor zwykle przeładuje je automatycznie.
2. W **GitHub Desktop** wybierz repozytorium `pop-drop-godot-0.3`.
3. Kliknij **Fetch origin**.
4. Otwórz listę **Current branch**, znajdź **gravity-prototype**, wybierz **Switch branch**. Jeśli najpierw widzisz opcję **New branch**, sprawdź zakładkę z gałęziami zdalnymi, a nie twórz nowej.
5. Jeśli pojawi się **Pull origin**, kliknij.
6. Wróć do **tego samego projektu** w Godot 4.7.2 i wciśnij **F5**. Na tej gałęzi `project.godot` uruchamia `scenes/gravity.tscn`.

Po zakończeniu testów możesz ponownie przełączyć **Current branch → main**, żeby wrócić do poprzedniej gry. Nie twórz nowego projektu, nie importuj ponownie i nie kasuj żadnych plików.

## Zasady do przetestowania

- Plansza 8 × 8; 3 kolory, z góry spada **jeden mały kształt**.
- Generator używa teraz **12 celowo dobranych sylwetek**: 1 pojedyncza kulka, 2 pary, 3 trójki, 6 czwórek (linia, kwadrat, L, T, **S, Z**). Przy luźnej planszy udziały rozmiarów to około **6% / 34% / 31% / 29%** (1/2/3/4 kulki). Czwórki trafiają się dużo częściej, a S i Z są dodatkowo promowane wśród czwórek. Ostatnie 5 sylwetek jest lekko wyciszanych w losowaniu, żeby tace nie wyglądały stale tak samo. Gęsta plansza preferuje mniejsze układy.
- Widać aktualny kształt oraz dwa następne (podgląd).
- **Dotknij kolumny** na planszy, żeby zrzucić kształt; spadnie do swoich kolumn. Następny kształt automatycznie wchodzi do gry — **przycisk „Dalej” został usunięty**.
- **Dwa duże przyciski pod planszą** obracają planszę w lewo albo w prawo. Przesuwanie palcem po planszy nie wywołuje obrotu — plansza służy wyłącznie do zrzucania kulek.
- Obracaj **ile chcesz, przed zrzutem lub po nim**, bez zużywania kształtów. Obroty mogą uruchamiać kaskady; gracz sam wybiera, kiedy znów coś zrzucić.
- Start jest bardziej żywy: **20 kulek**, w tym celowo przygotowana grupa **czterech jednakowych**, którą można rozbudować do pięciu. **Pierwszy kształt** to czerwona i zielona kulka obok siebie — zrzucenie go do lewej skrajnej kolumny domyka 5 czerwonych i **automatycznie uruchamia pierwszy POP za 320 pkt**, bez żadnego obrotu. Kolejne kształty są losowane.
- **POP jest automatyczny po zrzuceniu i po obrocie.** Grupa **co najmniej 5 kulek tego samego koloru połączonych bokami** pęka od razu po ukończeniu ruchu. Kształt grupy jest dowolny (linia, L, zygzak, blok); same połączenia po przekątnej nie wystarczą.
- **3/5 i 4/5 nie wybuchają** — te skupiska można dalej budować. Jeżeli jedna figura połączy dwie mniejsze grupy w jedną grupę 7–10+, wszystkie znikną w jednej większej eksplozji.
- Obrót przemieszcza zawartość planszy o 90°, po czym kulki opadają i gra automatycznie sprawdza POP. Obrót jest **taktyką do łączenia grup i ratowania miejsca**, nie obowiązkowym przyciskiem do odbioru nagrody.
- Grupa 5 daje **320 pkt**, 6 daje **560**, 7 daje **900**, 8 daje **1400**. Większe punktują jeszcze więcej. Każdy poziom kaskady mnoży wypłatę. Dwie oddzielne grupy po pięć liczą się oddzielnie, nie jak dziesiątka.
- Na planszy wyróżniona jest największa rosnąca grupa; obok podglądu kształtów pojawia się **3/5 lub 4/5** i potencjalna nagroda za piątkę. Grupy gotowe 5+ automatycznie pękają, więc nie są magazynowane. Na przyciskach obrotu widać przewidywany wynik każdej rotacji (z uwzględnieniem grawitacji i kaskad).
- Większe figury nie są sklejone po zrzucie: liczy się **ile kulek, w których kolumnach i w jakiej kolejności** spada. Dzięki temu S i Z z identycznymi kolorami mogą dać dwa różne układy na planszy. Pojedynczy kształt ma najwyżej 4 kulki, więc sam na pustej planszy nie wywoła pięciokulkowego POP.
- **Jak przegrać:** górny rząd planszy to czerwona linia zagrożenia. **Dotknięcie jej kulką po zrzucie lub obrocie kosztuje 1 życie**, a plansza otrzymuje częściowy ratunek. Gra ostrzega już przy wysokości 6/8 i pokazuje aktualną wysokość. Wciąż można także stracić życie za całkowity brak możliwego zrzutu mimo obrotów. Po utracie trzeciego życia runda się kończy.
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

Test sprawdza zrzucanie pionowych i poziomych par, legalne ruchy, oba obroty, grawitację, grupy 5+ o różnych kształtach, kasowanie po zrzucie i obrocie oraz 300 symulowanych ruchów.

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
3. Ułóż grupę **3**, potem **4** kulek — nic nie powinno wybuchnąć. Dołóż piątą: wybuch i naliczenie punktów mają nastąpić **automatycznie po opadnięciu**, bez obrotu.
4. Wywołaj kaskadę: obserwuj osobne wybuchy i mnożnik `×2`, `×3`.
5. Podczas animacji szybko naciśnij kolejny obrót: powinien wykonać się automatycznie po zakończeniu aktualnego.

**Status walidacji:** sprawdzono strukturę pliku i zapisy w GitHubie, ale w środowisku implementacji nie było uruchamialnego silnika Godot. Należy uruchomić projekt klawiszem F5 i sprawdzić konsolę oraz płynność na docelowym telefonie.

## Eksperyment: 5 do POP + ryzyko przegranej

- Testowana hipoteza: gracz będzie chętniej układać celowe kombinacje, gdy nagroda zaczyna się od **5** zamiast **3** i uruchamia się **automatycznie po każdym ruchu**.
- Ponieważ próg wzrósł, dopracowano start, aby na planszy od razu było widać grupę 4/5 i brakujące miejsce na piątą kulkę.
- Reguła jest centralnie definiowana przez `POP_THRESHOLD = 5` w `scripts/gravity_rules.gd`. Gra i symulacja obu przycisków obrotu korzystają z tej samej reguły.
- Wdrożono testy reguł pięciu kulek, nieregularnych układów, natychmiastowych POP po zrzucie i obrocie, wypłat, kaskad oraz górnej linii przegranej. **Testy nie zostały jeszcze uruchomione w Godot**.
