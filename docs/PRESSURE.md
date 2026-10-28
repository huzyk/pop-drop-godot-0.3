# POP DROP Gravity 0.7 alpha — system presji

## Tempo: częściej na starcie, więcej czasu później

Gracz ma **15 sekund** do pierwszej fali. Po każdej kolejnej fali odstęp rośnie o 4 sekundy, maksymalnie do 39 sekund:

| Fala | Sekundy od poprzedniej | Liczba kulek |
|---:|---:|---:|
| 1 | 15 | 6 |
| 2 | 19 | 6 |
| 3 | 23 | 6 |
| 4 | 27 | 7 |
| 5 | 31 | 7 |
| 6 | 35 | 7 |
| 7 | 39 | 7 |
| 8+ | 39 | 8 |

Mimo dłuższych przerw gra z czasem jest trudniejsza: kolejne rzędy gromadzą się na 8×8, a skały ograniczają możliwości budowania kombinacji.

Zegar działa wyłącznie w fazie wyboru/zrzutu; nie odlicza podczas animacji, POP-ów i przeglądania menu. W trakcie ostatnich 5 sekund pasek odliczania zmienia kolor na alarmowy. Pozostały czas i numer fali zapisują się wraz z rundą. Stare zapisy z 0.6 wczytują się z falą początkową.

## Fala

- Nowy rząd dodawany jest **od dołu**, a wszystkie istniejące elementy (w tym skały) przesuwają się o jeden rząd w górę.
- W początkowych falach dwie pozycje w nowym rzędzie są puste. Dalej zostaje jedna, a od ósmej fali wiersz jest pełny.
- Każda fala może sama doprowadzić do POP i kaskad.
- Jeśli w chwili wypchnięcia coś zajmuje górny rząd, jest to normalna utrata życia: plansza zostaje ratunkowo częściowo oczyszczona. Nie usuwamy niewidocznie elementów z góry.

## Skały

- **Co druga fala** próbuje zespawnować skałę na wolnym polu w środkowo-dolnej części planszy.
- Maksymalnie **3 skały** jednocześnie. Nie dochodzi do generowania na już zajętym polu.
- Kamień obraca się **wraz z planszą**, ale nie podlega grawitacji; po obrocie jest zakotwiczony w nowym polu i kulki mogą się na nim zatrzymać.
- O zwykłe kamienie nie można wykonać POP. Graficznie odróżnione od kulek: kanciasta obudowa z trzema świetlnymi pipsami.
- **Trzy odrębne POP-y obok skały**, przez wspólną krawędź, niszczą ją. Pop w wielu sąsiednich komórkach jednocześnie liczy się tylko jako **jedno uderzenie**. Zwykły POP w innym miejscu nie niszczy skały.
- Gdy skała pęknie, znika, a kulki mogą opaść w powstałą przestrzeń.
- Skróty i symulacje podpowiedzi rozumieją blokady: kule nie teleportują się pod kamieniem.

## Testy

```sh
godot --headless --path . --script res://tests/test_gravity_pressure.gd
```

Sprawdzenie pod CI obejmuje: progresywny zegar, rosnącą gęstość fal, nadpisywanie wierszy, przekroczenie góry, obrót skał, zakotwiczenie, blokowanie zrzutu, trzy POP-y do zniszczenia, limit skał oraz zgodność zapisów.

Wymagany jest również manualny test na telefonie, przede wszystkim ocena czy 15/19/23 s daje satysfakcję i czy kaskady przy falach są dostatecznie czytelne. To ustawienia alfa do balansowania, a nie zweryfikowana retencja.
