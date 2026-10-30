# POP DROP Gravity — Studio v4 / Midnight Jelly art direction

## Fundament (od 30 października 2026)
Studio jest **jedynym rendererem produkcyjnym**. Gameplay i input należą do `gravity_game.gd`, 
warstwa obrazu do `gravity_studio.gd`, a grafiki skórek do `gravity_skin_art.gd`.
Nie dokładamy kolejnych dekoracyjnych `draw_circle` do skryptu mechaniki gry.
Cała plansza, efekty, menu, sklep i profil muszą pochodzić z tej samej rodziny wizualnej.

## Kierunek — Jewel Playground
- Miękki, nasycony świat 2.5D: granat i indygo jako rama sceny, turkus i koral jako energia, złoto jako nagroda.
- Jasny, wystający z tła rant planszy; 64 zagłębione, delikatnie zaokrąglone pola.
- Kulki to pełne, bogato wykończone **postacie SVG 512×512** z oświetleniem od lewego górnego rogu, światłem odbitym, refleksami i cieniem.
- Zero pikselowych krawędzi, ostrych, komputerowych przycisków, przypadkowych tekstur lub wielokrotnych obwódek neonowych na każdym elemencie.
- Gracz zawsze rozpoznaje: planszę, kształty do wyboru, obrót i specjalne moce. Jednoznaczne obszary dotyku.
- Wrażenie głębi tworzą materiały, światło, różnica jasności, cienie kontaktowe i kontrolowany ruch. Nie mnożymy przypadkowych świetlnych efektów.

## Układ i bezpieczeństwo
Referencja: **720×1280 jednostek logicznych**, ze skalowaniem do telefonów 450×800 i innych.
Hitboxy i plan obrazu dzielą **te same współrzędne**. Zmiana układu wymaga równoczesnej aktualizacji gry, renderera i testów.
Pole gry `Rect2(56,247,608,608)`, kratka 76×76; bez ucinania sprite'ów i bez przypadkowego nakładania przycisków.
Nie zmieniamy zasad, wygranych, zapisu progresji, ekonomii ani poziomu trudności wyłącznie przez skórkę.

## Jedno źródło grafik
`scripts/gravity_skin_art.gd` zawiera pełen katalog. Wszystkie aktualne skórki mają **trzy różne, autorskie pliki** dla coral/mint/blue.
Obecny katalog: default, neon, gold, donut, capybara, crystal, cosmos, star_capybara.
Aktywny sklep i podgląd używają `SkinArt.sprite_for(skin_id,color_index)`, nie alternatywnych rysunków zbudowanych w kodzie.

Przy projektowaniu nowej skórki:
1. Utwórz trzy pełne postacie `assets/skins/<id>/coral.svg`, `mint.svg`, `blue.svg`.
2. Każda ma format **512×512** z alfa poza sylwetką. Środek kompozycji: (256,256).
3. Każda ma własną sylwetkę i duże rozpoznawalne różnice kolorów/materiału, nawet na planszy przy 47 px fizycznego rozmiaru.
4. Zadbaj o cieniowanie, kontakt ze światłem, kompozycję, identyfikowalność przy rozmiarze 32 px i zgodność z ruchem/squish.
5. Zarejestruj ją w `SkinArt.PACKS` i w `Shop`, nie twórz ukrytej zamiany na bazową grafikę.
6. Dodaj asercje do `test_gravity_skin_art.gd`: trzech pełnych tekstur 512 px, odrębne ścieżki, wyposażenie, podgląd.
7. Zweryfikuj ekran sklepu, planszę, animację, zestaw 3 kształtów, telefon i czytelność kolorów; sprawdź także obraz po skali do 450×800.

## Materiały i efekty
- Nie używamy pixel-art, nearest-neighbor ani generowania niskiej rozdzielczości i rozciągania go na ekran.
- SVG jest rasteryzowane przez importer Godota; używamy 512 px i filtrowania liniowego, a zaokrąglone panele mają anti-aliasing `StyleBoxFlat`.
- Ogólny ruch pozostaje krótki: 100–250 ms w momencie rotacji/kolizji, delikatny squash, ślady i falka wyłącznie w chwili POP.
- Brak ambientowego shake'u i ciągłego migotania wszystkich obiektów. Czytelność najważniejsza.
- Każdy nowy wzór musi wyglądać dobrze na planszy nawet przy wyłączonych efektach.

## Weryfikacja przed kolejnym wdrożeniem
- Godot 4.7.2 importuje zasoby bez błędów `SCRIPT ERROR` — workflow traktuje takie komunikaty jako **FAIL**, nawet gdy sam proces zwróci status 0.
- Wszystkie grywalne testy, sklep, profil, checkpoint i hitboxy zwracają jawny tekst `PASS`.
- Obowiązkowy screenshot **realnej klatki Godota** przy 450×800 (GitHub Actions artifact `pop-drop-actual-godot-preview`).
- Ogląd rzeczywistej klatki i test na urządzeniu są warunkiem zatwierdzenia art direction; projekt SVG lub mockup nie zastępuje działającej gry.
- Zakupy, zapis monet i wybrane skórki muszą działać po aktualizacji, bez resetowania zapisanych danych.

## Studio v3 — zakaz prostokątnych atrap (30.10.2026)
W grze nie wolno udawać zaawansowanego wyglądu przez samo ustawianie `border_radius` na stercie prostokątów.
Małe przyciski, HUD, etykiety i akcje mają sylwetkę kapsuły lub pęcherzyka. Koniec z wielkim białym prostokątnym dockiem pod wyborem kształtów.
Plansza musi zachować kwadratową siatkę 8×8 **wyłącznie z powodów mechaniki**; tło jest miękką silikonową tacką, a gniazda to autorskie tekstury 256 px.
Każdy wybierany klocek jest na odrębnej, organicznej wysepce z promieniami światła i cieniem kontaktowym.
Przyciski obrotu są rzeźbionymi, asymetrycznie miękkimi bryłami gradientowymi, a moce osobnymi żelkowymi kapsułami.

Jedynymi grafikami pod UI v3 są źródła z `assets/visual_v3/`, preładowane przez `scripts/gravity_studio.gd`.
Wszelkie nowe ekrany utrzymują regułę: **pełna forma > granica prostokąta, materiał > płaski kolor, oddech > zagęszczenie, czytelność > ozdobnik**.

CI wykonuje zrzuty **pięciu rzeczywistych ekranów**: gameplay, sklep, profil, ustawienia, koniec rundy. Sprawdzamy je wizualnie przed zatwierdzeniem pracy, oprócz testów mechaniki i importu grafik.

## Studio v4 — Midnight Jelly (poprzedni standard)

**Zasada nadrzędna:** ekran musi wyglądać jak jedna dopracowana gra, a nie kolekcja widżetów. Nie dodajemy kolejnych gradientów i ramek, jeżeli da się poprawić sylwetkę, hierarchię lub rozkład przestrzeni.

- **Tło:** ciemny, matowy fiolet (`assets/visual_v4/world.svg`), miękkie rozproszone światło tylko na obrzeżach ekranu; brak dekoracyjnego szumu pod planszą.
- **Plansza:** `assets/visual_v4/board.svg`, cienka fioletowa rama; 8×8 dyskretnych miejsc na kulki o kontraście nieodciągającym uwagi. **Zakaz powrotu do 64 głębokich, tłoczonych otworów**, osobnych „metalowych” kafli albo siatki z ostrymi liniami.
- **Kulki:** główny nośnik nasyconych kolorów i ekspresji. Wszystkie przyszłe skórki: trzy pełne, czytelne stany kolorystyczne, źródło min. 512×512, twarz/sylwetka widoczna w docelowym rozmiarze ~45px, bez cienkich pikselowych krawędzi. Siatka nie może być bardziej kontrastowa niż kulki.
- **Elementy interfejsu:** jeden materiał dla małych ciemnych kontenerów. Wybrane kształty oznaczamy dyskretnym różowym obrysem, a nie kolejnym białym panelem. Brak wielkiego tła panelu wyboru.
- **Akcje główne:** tylko dwa duże akcenty nawigujące (koralowy i miętowy), identyczne promienie i optyczna hierarchia. Magia/bomba/przetasowanie są wtórne.
- **Typografia:** tylko trzy stopnie — wyraźne liczby i nazwy przycisków, czytelne etykiety, marginalne mikrodetale. Nie mieszamy kilku stylów liter, zbędnego tekstu, przycisków zawierających trzy konkurujące etykiety.
- **Ekrany modalne:** mleczna lawenda na ciemnym przygaszonym tle, te same odstępy i odcienie akcentów. Hitboxy wejścia pozostają takie same jak w `gravity_game.gd`.
- **Test jakości:** generujemy z prawdziwego Godota pięć screenshotów (gra, sklep, profil, ustawienia, koniec gry). Patrzymy na render 450×800, nie tylko na SVG otwarty w przeglądarce. Nie publikujemy zmian interfejsu bez przejścia kontroli kompilacji, mechaniki i tych zrzutów.

### Kontrola przed dodaniem następnej skórki

Pytania kontrolne: czy wzór jest rozpoznawalny przy 42–46 px? Czy zachowuje sylwetkę i wyraz przy ruchu i obrocie? Czy każdy z trzech kolorów nadal różni się wyraźnie? Czy motyw jest obecny w kulce, nie wymusza przemalowania mechaniki? Czy teksturę eksportujemy bez białej obwódki na przezroczystym tle?


## Atelier v5 — asset-first UI (30.10.2026)

**Aktualny standard:** główne elementy ekranu są pełnymi grafikami, a nie kompozycją proceduralnych okręgów, prostokątów i cieni.
Katalog `assets/atelier_v5/` zawiera niezależnie przygotowane SVG dla: świata, ramy planszy, gniazd, HUD, statusu, monet, przycisków narzędziowych, wskaźników energii, wyboru kształtów, obrotu, trzech dopalaczy, CTA i skał. Modalne panele mają materiał `panel.svg` rozciągany dziewięciopolowo (9-slice), aby zachować rzeźbione narożniki niezależnie od rozmiaru.

- Mechanika nadal jest w `gravity_game.gd`; `gravity_studio.gd` renderuje tekstury. Nie zmieniamy punktów dotyku, wymiarów planszy ani modelu zapisu.
- Proceduralne `draw_*` jest dozwolone dla danych dynamicznych (przebieg timera, grupy, trajektorie, iskry, podświetlenie celowania), a nie dla pełnych przycisków/paneli.
- Każdy nowy element wizualny projektujemy w źródłowym pliku osobno, z alfa i z wewnętrznym cieniowaniem; nie robimy „nowego designu” wyłącznie za pomocą zmiany kolorów kształtów w kodzie.
- SVG mają zdefiniowane rozdzielczości: world 720×1280, board 720×720, socket 256×256, elementy UI według dedykowanych wymiarów. Wszystkie testowane w `test_gravity_skin_art.gd`.
- `SkinArt.PACKS` pozostaje jedynym katalogiem kupowanych skórek. Przyszłe skórki nie powinny kopiować wyglądu przycisków za pomocą przypadkowych zmian kolorów.
- Ocena artystyczna wymaga klatek z działającego Godota na 450×800; same SVG i zielony pipeline nie potwierdzają, że kompozycja wizualna została zaakceptowana.
