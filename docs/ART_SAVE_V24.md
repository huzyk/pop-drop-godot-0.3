# 0.24 — interfejs, skórki i wspólny zapis

## Wygląd

Przebudowany ekran gry i pięć okien: sklep, profil, ustawienia, koniec rundy
oraz samouczek. Jasne kremowe powierzchnie, turkusowa oprawa, zaokrąglone
przyciski i oddzielone pola sterowania. Wszystkie etykiety aktywnego ekranu
są rysowane przez Godota; nie ma tekstu wbudowanego w bazową ilustrację.

23 skórki katalogowe mają nowe grafiki, każda w trzech kolorach: 69 sprite'ów
256×256. Zwierzęta mają różne sylwetki, uszy, dzioby, rogi i wzory. Zmienione
są też plansze i obrzeża sześciu światów. Istniejące identyfikatory zakupów
pozostają bez zmian. Aurora i Gwiezdne nadal są dekoracjami bazowej skórki.

Źródła SVG powstają deterministycznie przez `python tools/build_art_v24.py`.
Katalog i nowa kopia UI mają tłumaczenia PL/EN/ES/PT/DE/FR/RU. Nazwa POP DROP
pozostaje wspólnym znakiem gry. Pliki starszych ilustracji pozostawiono dla
historii projektu; aktywny renderer korzysta z `assets/ui/v24/game_shell.svg`.

## Zapis

Aktywna gra zapisuje planszę, kształty, wynik, monety, ekwipunek, zakupione
skórki, XP, misje, odznaki i metadane w jednym `gravity_state_v2.json`.

1. Kompletna migawka jest walidowana i zapisywana do pliku tymczasowego.
2. Poprzednia poprawna wersja jest zachowywana jako `.bak`.
3. Dopiero gotowy plik zastępuje główny zapis przez rename.

W trakcie animacji stan nie jest zatwierdzany. Przerwanie procesu przywraca
cały poprzedni ukończony ruch, łącznie z portfelem i progresją. Operacje
sklepowe poza animacją zapisują się po zakończeniu callbacku wejścia.
Nie są już niezależnie nadpisywane stare pliki sklepu i profilu.

Pierwszy start migruje stare dane automatycznie. Nie usuwa starych plików.
Gdy główny zapis jest uszkodzony, gra odczytuje poprzednią kompletną kopię.
Plik tymczasowy po przerwanym zapisie jest ignorowany. Jeśli obie kopie są
uszkodzone, nie są łączone z nieaktualnymi saldami z plików sprzed migracji.

To ochrona przed przerwaniem aplikacji i uszkodzeniem pojedynczego pliku,
nie synchronizacja w chmurze. Odinstalowanie aplikacji nadal usuwa dane.

## Testy

`test_unified_save.gd`: migracja realnych plików, przerwany ruch,
zatwierdzenie wszystkich modeli, kopia awaryjna, niekompletny pakiet,
brak zapisu do dawnych plików. `test_live_copy.gd`: kompletność nowej kopii
we wszystkich siedmiu językach. Pozostałe testy nadal kontrolują reguły,
układ, skórki, audio i pamięć cache. Workflow generuje rzeczywiste ekrany
Godota do wizualnej oceny oraz buduje APK.
