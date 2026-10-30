# POP DROP Gravity 0.13 — sklep, odznaki, energia i codzienne nagrody

## Zasady ekonomii

Monety są osobne od wyniku i XP. Każdy prawdziwy POP daje jedną monetę za każde pełne 10 zdobytych punktów. W sklepie nie sprzedajemy punktów ani XP; obracanie, bomba i nieudany ruch nie generują monet. Monety zapisują się lokalnie.

### Moce (jednorazowe)

| Moc | Cena | Efekt |
|---|---:|---|
| Bomba | 160 | Usuwa kulki w obszarze 3×3, osłabia trafione skały o jeden poziom |
| Magiczny Kolor | 220 | Zmienia kolor wybranej kulki na najbardziej obiecujący do POP-a; potem zwykłe kaskady |
| Nowy Zestaw | 140 | Losuje trzy nowe kształty bez wydłużania czasu fali |

**Usunięto premię +10 sekund.** Zakupione wcześniej +10s po wczytaniu starego zapisu stają się Nowym Zestawem. Moce można gromadzić do 20 sztuk każdego rodzaju. Bomba nie nagradza za bezpośrednio usunięte kulki; punktują wyłącznie dalsze naturalne POP-y.

### Skórki (na stałe)

| Wygląd | Cena |
|---|---:|
| Neon | 500 |
| Złoto | 1200 |
| Donuty | 900 |
| Kapibary | 1500 |
| Kryształy | 1800 |
| Kosmos | 2200 |

Skórki nie zmieniają trudności, fizyki, punktacji ani monet. Kupiony wygląd pozostaje dostępny. **Gwiezdna Kapibara** jest darmową specjalną skórką za siódmy kolejny dzień aktywnej gry; nie można kupić jej za monety. Dodatkowe skórki Aurora i Gwiezdne za XP nadal działają.

### Ratunek i energia

Po utracie trzech serc w rundzie można **jeden raz na rundę** kontynuować za **220 monet** lub po faktycznie zakończonej reklamie nagradzanej. Ratunek przywraca jedno serce i zwalnia miejsce na planszy. Nie resetuje punktacji.

Osobna energia ogranicza starty nowych rund: maksymalnie **5 energii**, koszt nowej rundy **1**, odnowienie **1 co 20 minut** liczone od pierwszego zużycia, także po zamknięciu gry. Reklama nagradzana może od razu dodać jedną energię (nie ponad limit). Serca podczas rozgrywki (3) to osobny licznik i nie odnawiają się podczas samej rundy.

Przycisk reklamowy wymaga podłączonego, gotowego SDK AdMob i jego potwierdzenia nagrody. Bez SDK uczciwie pojawia się komunikat o niedostępnej reklamie — **nie ma fikcyjnych nagród**. Nie ma ograniczenia liczby obejrzanych reklam na energię, poza gotowością i ograniczeniami dostawcy reklam.

### Codzienne granie i odznaki

Pierwszy **udany zrzut** danego dnia automatycznie odbiera 7-dniową nagrodę: **20 / 30 / 50 / 70 / 90 / 120 / 150 monet**. Dzień 7 po raz pierwszy odblokowuje Gwiezdną Kapibarę. Kolejne dni rozpoczynają ponownie cykl 7 dni; przerwa resetuje cykl do dnia 1.

Codzienne misje nadal dają XP, ale również monety: **25 / 35 / 50** za misje zrzutów, POP-ów i punktów. Nagroda jest jednorazowa na misję i dzień. Profil ma **12 trwałych odznak**: pierwszy zrzut, 25 i 100 zrzutów; pierwszy, 50 i 200 POP-ów; kaskady ×2 i ×4; 10 000 punktów POP łącznie; 10 rund; serie 3 i 7 dni. Odznaki płacą jednorazową premię monetową (20–300 zależnie od celu).

### Trwałość, testy i ograniczenia

Nowe dane wykorzystują wersjonowany zapis `gravity_shop_v1.json` (wersja formatu 2), migrujący bez kasowania portfela i starych skórek. Liczniki i nagrody mają lokalne identyfikatory zdarzeń, zapisywanie temp+rename i deduplikację; podczas wczytywania profil odtwarza należne premie za odznaki i dzienne misje w razie przerwanego zapisu między modułami.

Profil i sklep są lokalne i możliwe do edytowania przez użytkownika urządzenia. Nie mogą być podstawą bezpiecznego rankingu online bez backendu. Reklamy AdMob/UMP wymagają konfiguracji SDK i zgód w środowisku produkcyjnym.

Testy Godot: `tests/test_gravity_shop.gd`, `tests/test_gravity_progression.gd`, `tests/test_gravity_icons.gd`, `tests/test_gravity_layout.gd`, `tests/test_gravity_ui_layout.gd`. Uruchamia je GitHub Actions przy każdej aktualizacji `main`.
