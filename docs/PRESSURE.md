# POP DROP Gravity 0.15 — świadoma gra zamiast ukrytych kar

## Koniec rundy

**Jedyną naturalną przyczyną przegranej jest brak możliwych ruchów.** Sprawdzamy wszystkie trzy oferowane kształty i możliwości odzyskania miejsca przez obroty (z grawitacją i POP-ami). Żaden zajęty rząd, także najwyższy, **nie odbiera życia**. Nie ma już trzech serduszek ani osobnych kar za fale.

Przy przegranej pojawia się komunikat **BRAK DOSTĘPNYCH RUCHÓW**. Po zakończeniu można rozpocząć nową rundę albo **jeden raz w rundzie** wykupić / obejrzeć reklamę za ratunek. Ratunek czyści dwie najwyższe zapełnione kulkami linie, a jeśli nie otwiera możliwości ruchu (np. przy całkowicie skalistej górze), odblokowuje górne pola i gwarantuje jedną małą kulkę do położenia.

## Fale kulkami od góry

Stary model napierających wierszy został usunięty. W każdym cyklu nowa fala **zrzuca pojedyncze kulki do różnych wolnych kolumn**. Zajęte kolumny są pomijane, nie wypychają innych kulek i nie powodują osobnej utraty życia. Kiedy na planszy nie ma już żadnego legalnego ruchu nawet po obrocie, uruchamia się zwykły koniec rundy.

| Etap | Numer fali | Odstęp | Kulki na falę |
|---|---|---:|---:|
| Rozgrzewka | 1–4 | 18 s | 3 |
| Środek | 5–9 | 16 s | 4 |
| Zaawansowana gra | 10+ | 14 s | 5 |

Czas nie biegnie podczas animacji lub otwartego menu. Po wznowieniu starego zapisu pozostały czas jest ograniczony do nowych parametrów.

## Skały

Nie ma sztucznego limitu skał. **Co trzecia fala** próbuje dodać **jedną skałę** na wolnym polu środkowo-dolnej części planszy. Jeśli nie znajdzie tam miejsca, fala nie dodaje skały. Skały obracają się wraz z planszą, nie spadają pod wpływem grawitacji. Każda wytrzymuje trzy osobne sąsiadujące POP-y lub trafienia bombą. Ratunek jest szczególnym wyjątkiem: w całkowicie zablokowanej sytuacji może otworzyć także dwa pola zajęte przez skały.

## Interfejs

Zamiast trzech serc i sygnału „linia śmierci” gra pokazuje liczbę wolnych pól. Ekran porażki mówi wprost, dlaczego runda się skończyła.

## Testy

```sh
godot --headless --path . --script res://tests/test_gravity_pressure.gd
godot --headless --path . --script res://tests/test_gravity_rules.gd
godot --headless --path . --script res://tests/test_illustrated_art.gd
```

To balans startowy do testów na telefonie, nie wynik pomiarów retencji.
