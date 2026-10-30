# POP DROP Gravity 0.16 — więcej decyzji, mniej darmowych monet

## Koniec rundy

**Jedyną naturalną przyczyną przegranej pozostaje brak możliwych ruchów**, także po możliwych obrotach. Nie przywracamy linii śmierci ani kar za zapełniony górny rząd. Po przegranej można raz wykupić lub obejrzeć reklamę za ratunek, który otwiera miejsce.

## Presja: fale i nawałnice

Fale zrzucają pojedyncze kulki do różnych dostępnych kolumn. Co **piąta fala** to zapowiadana w dolnym pasku **NAWAŁNICA**: otrzymuje dwie dodatkowe kulki (maksymalnie 8). Jeśli kolumn jest za mało, fala dodaje tylko tyle kulek, ile mieści się na planszy.

| Numer fali | Odstęp | Typowe kulki | Nawałnica |
|---|---:|---:|---:|
| 1–4 | 16 s | 4 | — |
| 5–9 | 14 s | 5 | 7 w fali 5 |
| 10+ | 12 s | 6 | 8 co piątą falę |

**Skały pojawiają się od drugiej fali, po jednej co drugą falę**, bez sztywnego limitu. Są usuwane przez trzy osobne sąsiednie POP-y lub trafienia bombą.

Generator wyraźnie częściej proponuje kształty z trzema i czterema kulkami, zamiast stale ratować gracza pojedynczymi. Zmniejszono jego preferencję do proponowania gotowych kombinacji POP; nadal bierze pod uwagę grywalność i awaryjnie potrafi zaproponować mniejszy kształt.

## Ekonomia gry

- **Wynik i XP nie są limitowane**. Nadal warto robić duże combosy i walczyć o rekord.
- Za POP wypada około **1 moneta na 85 punktów**, minimum 2 i maksimum 24 za pojedyncze rozliczenie POP.
- **Łącznie do 160 monet za POP podczas jednej rundy.** Licznik jest zapisywany i nie resetuje się po ponownym uruchomieniu aplikacji. Jednorazowy komunikat informuje o osiągnięciu limitu.
- Premie za dzienne zadania, serie dni i odznaki są oddzielne od limitu POP. Dalszy rozwój wymaga wielu sesji; jedna długa gra nie powinna automatycznie finansować całego sklepu.
- Istniejące monety, skórki, boostery i XP pozostają bez zmian. Stary portfel v3 przechodzi na v4.

## Testy

```sh
godot --headless --path . --script res://tests/test_gravity_pressure.gd
godot --headless --path . --script res://tests/test_gravity_shop.gd
```

Parametry są punktem wyjścia do testów długości sesji oraz retencji, nie gwarancją optymalnego balansu.
