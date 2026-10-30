# POP DROP Gravity 0.19 — lokalizacja, efekty POP i dźwięki

## Efekty audiowizualne i lokalizacja (v0.19)

- Reakcje POP/GREAT/AMAZING, zachęty, nawałnica oraz serie korzystają z tabeli tekstów dla **PL, EN, ES, PT, DE, FR i RU**. Wersja polska wyświetla **POP! / ŚWIETNIE! / NIESAMOWITE! / SERIA**.
- W lewym górnym obszarze statystyk interfejsu ilustracyjnego jest widoczny, dotykowy przycisk **JĘZYK: PL**. Przełącznik języka jest też w ustawieniach z nazwą języka w jego własnym zapisie. Preferencja nadal zapisuje się lokalnie.
- Wyróżniające się kombinacje mają krótki, jasny rozbłysk z promieniami i iskrami w miejscu POP-a, podczas gdy zwykły POP nie blokuje ekranu dużą kartą.
- **Każda skała pokazuje wyraźny licznik 3/2/1** na kontrastowej tarczy; po pierwszym trafieniu pojawiają się pęknięcia, po drugim kolejne. Przy trzecim skała rozpada się na trójkątne odłamki i pył, z osobnym dudniącym trzaskiem. Bomba również niszczy skały z odpowiednim efektem.
- Nowe wielowarstwowe, autorskie dźwięki są wytwarzane na starcie z PCM: osobne miękkie lądowanie, obrót, mały i wielki POP, kaskada, uszkodzenie i rozpad skały, bomba oraz nawałnica. Wzrost wysokości tonu przy serii FLOW i odrębne wibracje dla mocniejszych akcji. Dźwięk i wibracje można niezależnie wyłączyć w ustawieniach.
- Zasady porażki, tempo fal, ekonomia i brak limitu zarabianych monet pozostają bez zmian.

## Dynamika — FLOW

Po POP-ie wykonanym przez gracza rozpoczyna się **8 sekund czasu decyzyjnego** na następny POP. Timer nie biegnie podczas animacji, otwartych menu ani przy przerwanej rozgrywce. Każda kolejna akcja z POP-em podtrzymuje serię, a bonus do **punktów wyniku** rośnie:

| Kolejna akcja z POP-em | Premia do wyniku |
|---|---:|
| 1 | ×1,00 |
| 2 | ×1,25 |
| 3 | ×1,50 |
| 4 i kolejne | ×2,00 |

Dwa POP-y w jednej kaskadzie nadal liczą się jako **jedna akcja FLOW**, aby nie nabijać premii przypadkowo. POP uzyskany po obrocie planszy również liczy się jako świadoma akcja. Automatyczna fala i bomba mogą czyścić planszę, ale nie nabijają FLOW. Seria wygasa po ośmiu sekundach aktywnego czasu gracza bez nowego POP-a.

Interfejs pokazuje **FLOW xN** i pasek czasu bez zasłaniania planszy. Zwykłe POP-y używają krótszego, subtelnego komunikatu; pełniejsze efekty graficzne zostają dla prawdziwych kombinacji. Audio przyspieszono, a wysokość dźwięku kolejnych POP-ów w FLOW rośnie. Obrót skrócono z około 0,97 s do około 0,59 s, upadek kształtu z 0,23 s do 0,16 s. Następne etapy kaskady animują się szybciej. Nie przyspieszono fal i nie zwiększono liczby skał.

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

- **Monety, wynik i XP nie mają limitu na rozgrywkę**. Każdy kolejny POP nagradza gracza, także po bardzo długiej serii.
- Nagroda monetowa za POP rośnie łagodnie z punktami: około **0,3 × pierwiastek z punktów** (minimum 2). Przykładowo 900 pkt = 9 monet, 9000 pkt = 28 monet. Duży combo nadal opłaca się bardziej, ale monety nie rosną liniowo z wynikiem.
- **Skórki są celami na dłużej**: Neon 900, Donut 1900, Gold 2600, Kapibara 3300, Crystal 3900, Cosmos 5200. Bomba (160) i Nowy Zestaw (140) pozostają przystępne podczas rozgrywki.
- Premie za dzienne zadania, serie dni i odznaki naliczają się niezależnie i normalnie.
- Dotychczasowe monety, skórki, boostery i XP pozostają bez zmian. Format portfela v4 pozostaje kompatybilny; dawne pola limitu są ignorowane przy odczycie.

## Testy

```sh
godot --headless --path . --script res://tests/test_gravity_pressure.gd
godot --headless --path . --script res://tests/test_gravity_shop.gd
```

Parametry są punktem wyjścia do testów długości sesji oraz retencji, nie gwarancją optymalnego balansu.
