# POP DROP — system wizualny i standard skórek (v1.0)

## Cel
POP DROP ma wyglądać jak dopracowana, pogodna, dotykowa gra casual na telefon, nie jak neonowy panel debugowy. Obowiązuje kierunek **Candy Playground**: jasne niebo w kolorach brzoskwini, lawendy i mięty; kremowe karty; jasnofioletowa plansza; trójwymiarowe, nasycone żelki. Pierwszą skórką jest **Jelly Pals** — miękkie, radosne żelki o dużych czytelnych twarzach. Skórki zmieniają wygląd kulek, a nie reguły gry, hitboksy, tempo czy informacje o dostępnych ruchach.

## Nienegocjowalne zasady
1. **Sylwetka pierwsza.** Kulka musi być rozpoznawalna po zmniejszeniu do 38–50 px oraz na jasnym i ciemnym tle. Zero cienkich ozdobników i gęstych tekstur.
2. **Trzy typy kolorów.** Każda skórka zawiera dokładnie warianty `coral`, `mint`, `blue` w stałym porządku indeksów 0/1/2. Typy odróżnia również detal / wyraz twarzy, nie tylko barwa.
3. **Jedna dominanta.** Wybierz jeden rodzaj materiału (żel, drewno, kosmos, futro). Nie mieszaj szkła, neonów, metalu i pikselozy w jednym obiekcie.
4. **Światło z góry z lewej.** Jeden duży highlight, delikatny cień kontaktowy, subtelny rim. Żadnych podwójnych fluorescencyjnych pierścieni wokół wszystkich kulek.
5. **Prawdziwe assety.** Grafika skórki ma zawierać cały wygląd obiektu (włącznie z twarzą). Nie budować postaci z `draw_circle()` w logice gry.
6. **Gameplay jest nadrzędny.** Pusta plansza ma pozostawać spokojna; efekty uruchamiać wyłącznie po akcji gracza, dopasowaniu, combo i osiągnięciach.
7. **Bez pay-to-win.** Płatne skórki nie dają przewagi, nie zmieniają rozmiaru logicznego kulek, nie zasłaniają pól.
8. **Bezpieczne pola.** Grafika mieści się w kwadracie 256×256, środek (128,128); zasadnicza sylwetka w kołowym obszarze o promieniu maksymalnym 101 px, cień może zejść niżej. Jedna grafika = jedna kulka, przezroczystość poza sylwetką.
9. **Brak zależności od języka.** Nie umieszczać tekstu w teksturach; podpisy renderuje UI.
10. **Wydajność.** Tekstury importowane w Godot, wspólne źródła reużywane, bez ciągłego tworzenia materiałów w pętli `_draw()`.

## Format paczki
`assets/skins/<skin_id>/coral.svg`
`assets/skins/<skin_id>/mint.svg`
`assets/skins/<skin_id>/blue.svg`

Źródło: wektor 256×256 viewBox, bez filtrów SVG i zewnętrznych fontów/linków. Przy produkcji PNG korzystaj z minimum 512×512 px jako renderu high-DPI, z alfą. Każdy kolor i każdy wyraz twarzy należy zatwierdzić osobno. Przy dodawaniu nowej skórki:
1. Utworzyć trzy pliki w `assets/skins/<id>/` według tego formatu.
2. W `scripts/gravity_skin_art.gd` dopisać const z trzema `preload()` w kolejności coral/mint/blue, następnie ID w `sprite_for()` i `is_authored()`. To jedyne miejsce, w którym rejestrujemy **grafikę** nowych skórek.
3. W `scripts/gravity_shop.gd` dopisać ofertę, cenę i ID własności; w `scripts/gravity_game.gd` dopisać ID do `_shop_catalog()` i teksty podglądu.
4. Dodać test importu i wyposażenia do `tests/test_gravity_skin_art.gd`, a następnie sprawdzić Godot CI i urządzenie.
5. Dla nieznanego ID zachować dotychczasowy fallback sklepu / logiki zapisu. Wprowadzanie nowych skórek **nie może** resetować zakupionych skórek ani monet.

## Warstwy grafiki na planszy
1. Tło **jasne, ilustracyjne**, bez rozpraszających elementów w środkowej strefie gry; gradient brzoskwinia → jasny błękit → lawenda. Dodatkowe bąbelki wyłącznie na marginesach.
2. Plansza jako biała tacka z miękkim cieniem. Kratki w spokojnych odcieniach jasnej lawendy, bez czarnych dołków i grubych ramek.
3. Cień kontaktowy *pod* kulką, nie wielokrotny neon.
4. Sprit kulki w całości.
5. Efekt gameplayowy: krótki squish na lądowaniu, bąbelkowe cząstki po POP, subtelny pierścień combo, światło podczas wyboru.
6. UI: wynik, fala, życia oraz sterowanie – priorytety czytelności i kontrastu, a nie ornament.

## Ruch i VFX — wskazówki
- **Spoczynek:** brak ciągłego pulsowania wszystkich kulek. Dopuszczalne bardzo subtelne odbicie światła (maks. kilka %).
- **Upadek:** 120–250 ms sprężynującego lądowania, maksymalnie +12% szerokości i −9% wysokości.
- **Obrót:** existing gravity movement, smugi wyłącznie na ruchomych kulkach; smug nie należy rysować po lądowaniu.
- **POP:** w ciągu 250–500 ms: powiększenie, krótki błysk i 6–12 lekkich cząstek; przy większym combo dołożyć falę.
- **Dostępność:** przy opcji reduced motion wyłączyć shake, ambient shimmer i nadmiar cząstek. Nie kodować informacji wyłącznie barwą.

## Kolory Jelly Pals
- Coral: `#FF687C` — energetyczna, ciepła
- Mint: `#53DCAF` — świeża, spokojna
- Blue: `#6DAFF5` — miękka, chłodna
- Tło Candy Playground: `#FFEDE3` → `#E8F1FD` → `#EBE5FA`.
- Plansza: tacka `#FFFFFF`, pola `#E6E9F6` / `#DDE2F1`.
- Typografia: granat `#27364E`; etykiety `#607A94`, nigdy jasny tekst na białych kartach.
- Sterowanie: lewo `#FF6388`, prawo `#32B8BB`, biały tekst.
- Panele: `#FFFFFF`, subtelny cień `#7193AE` na 10–18% krycia.
- Sklep / profil / ustawienia: należą do tej samej rodziny jasnych paneli, nie wracamy do neonowego trybu.
- Akcenty tylko tam, gdzie stan gry lub decyzja gracza tego potrzebują.


## Reguły interfejsu Candy Playground (od 30.10.2026)
- **Jedno mocne centrum**: plansza, a po niej wybrane kształty i dwa przyciski obrotu.
- **Nawigacja drugorzędna**: ikony na białych kartach, bez ozdobnych ramek.
- **Czytelność w 450×800**: najważniejszy tekst co najmniej 20 jednostek w referencyjnym układzie 720×1280; etykiety 16–19, pojedyncze niekrytyczne szczegóły nie mogą zasłaniać mechaniki.
- **Dotyk**: grafika ma odpowiadać hitboksowi, a większe przyciski otrzymują widoczną dolną krawędź wskazującą fizyczne wciśnięcie.
- **Żadnych czarnych dziur** na pustej planszy, świecących obręczy na każdej kulce, metalicznych ikonek mieszanych z kreskówką ani powielanych ozdobnych linii.
- **VFX mają być zdarzeniowe**: bąbelki i pop-konfetti po udanej akcji, żelkowy squash na lądowaniu, czytelny floater punktów, mocniejsze celebracje wyłącznie przy prawdziwym sukcesie.
- Przed uznaniem zmian za zatwierdzone obowiązkowy **screenshot z uruchomionego Godota** w 450×800 i test na telefonie. Statyczny projekt koncepcyjny nie jest dowodem poprawnego renderowania w silniku.

## QA przed publikacją nowej skórki
- [ ] Czy każdy z trzech wariantów jest czytelny w rozmiarze 32 px?
- [ ] Czy typy są rozpoznawalne bez polegania na kolorze?
- [ ] Czy połączenie pięciu kulek jest wyraźne i nie przykrywa go VFX?
- [ ] Czy ruch/obroty/squish nie wychodzą poza planszę?
- [ ] Czy podgląd w sklepie i render na planszy używają tych samych assetów?
- [ ] Czy wybrana skórka i zakupy przeżywają ponowne uruchomienie?
- [ ] Czy 450×800 i standardowy telefon nie mają uciętych tekstów i przycisków?
- [ ] Czy FPS i czas klatki na starszym Androidzie nie pogorszyły się znacząco?
