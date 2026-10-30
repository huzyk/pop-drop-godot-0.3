# POP DROP — system wizualny i standard skórek (v1.0)

## Cel
POP DROP ma wyglądać jak dopracowana gra casual na telefon, nie jak neonowy panel debugowy. Pierwszą skórką jest **Jelly Pals** — miękkie, radosne żelki o dużych czytelnych twarzach. Skórki zmieniają wygląd kulek, a nie reguły gry, hitboksy, tempo czy informacje o dostępnych ruchach.

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

Źródło: wektor 256×256 viewBox, bez filtrów SVG i zewnętrznych fontów/linków. Przy produkcji PNG korzystaj z minimum 512×512 px jako renderu high-DPI, z alfą. Każdy kolor i każdy wyraz twarzy należy zatwierdzić osobno. Przy dodawaniu skórki: skonfigurować trzy importowane tekstury w kodzie, ID w katalogu sklepu, podgląd, test zapisu/wyboru i fallback na Jelly Pals.

## Warstwy grafiki na planszy
1. Spokojne tło z jedną dominantą i ograniczonym kontrastem.
2. Płyta planszy i subtelna siatka. Unikać czarnych dołków pod każdą kulką.
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
- Tło: granat i atrament, bez zlewania z sylwetkami.
- UI: ciemne jednolite panele, biały tekst, akcent tylko dla aktualnej akcji.

## QA przed publikacją nowej skórki
- [ ] Czy każdy z trzech wariantów jest czytelny w rozmiarze 32 px?
- [ ] Czy typy są rozpoznawalne bez polegania na kolorze?
- [ ] Czy połączenie pięciu kulek jest wyraźne i nie przykrywa go VFX?
- [ ] Czy ruch/obroty/squish nie wychodzą poza planszę?
- [ ] Czy podgląd w sklepie i render na planszy używają tych samych assetów?
- [ ] Czy wybrana skórka i zakupy przeżywają ponowne uruchomienie?
- [ ] Czy 450×800 i standardowy telefon nie mają uciętych tekstów i przycisków?
- [ ] Czy FPS i czas klatki na starszym Androidzie nie pogorszyły się znacząco?
