# POP DROP Gravity: progress and retention 0.5 alpha

## Działanie

W prawym górnym pasku gry obok **DATA** pojawia się **POZ. 1 · XP**. Dotknięcie otwiera pełnoekranowy profil. Ekran działa zarówno w czasie rozgrywki, jak i na ekranie końca rundy (nie otworzy się w czasie animacji).

### XP i poziomy

- Każde **udane położenie** kształtu: +2 XP. Samo przekładanie podglądów czy nieskuteczny zrzut nie daje punktów.
- Każdy POP: XP za faktyczną liczbę kulek i grup oraz bonus za kaskady.
- XP wymagane do kolejnych poziomów: 120 (poziom 2), 360 (3), 720 (4), 1200 (5), 1800 (6).
- XP jest osobne od punktów w rundzie. **Obroty same w sobie nie przyznają XP**, żeby nie opłacało się bez końca kręcić planszą.
- Postęp jest offline i lokalny, bez logowania, konta czy transferu danych reklamowych.

### Trzy codzienne misje

| Misja | Cel | Nagroda |
| --- | --- | --- |
| Zrzuć kształty | 10 udanych zrzutów | +60 XP |
| Wywołaj POP | 3 grupy znikających kulek | +90 XP |
| Zdobądź punkty | 1800 punktów za POP-y | +120 XP |

Nagroda przyznawana jest **automatycznie tylko raz dziennie** po zakończeniu celu. Stan misji resetuje się lokalną datą kalendarzową. Otwarcie ekranu profilu samo w sobie nie zwiększa serii dni — dopiero realny zrzut.

### Serie dni

Seria wzrasta, jeśli gracz faktycznie położy kształt następnego dnia kalendarzowego. Dzień przerwy resetuje serię do 1. Nie ma powiadomień wywołujących FOMO ani kar w podstawowej rozgrywce za przerwę.

### Odblokowania kosmetyczne

- **Klasyczne** — od początku, znane szklane kulki.
- **Aurora** — poziom 3, delikatna dodatkowa poświata i refleks.
- **Gwiezdne** — poziom 6, złota obwódka i gwiezdny refleks.

Wygląd można przełączać w profilu. Nie wpływa to na balans gry, szanse na POP ani reklamy.

## Architektura

`scripts/gravity_progression.gd` — osobny moduł RefCounted, zapis `user://gravity_profile_v1.json`, walidowane liczniki, atomowy zapis przez tymczasowy plik i przeniesienie. Wywołania z `gravity_game.gd`:
- `record_drop` po sprawdzeniu legalności położenia;
- `record_pop` po faktycznym rozliczeniu kaskady;
- `record_round` w momencie końca rundy;
- `ensure_day` przy otwarciu profilu.

Zdarzenia mają identyfikatory `run_id + action_serial + cascade`, a ostatnie 128 identyfikatorów jest zapisywane z profilem; to zabezpiecza przed powtórzonym eventem/callbackiem. Nadal **nie jest** to bezpieczny serwerowy ranking: użytkownik ma pełną kontrolę nad lokalnym zapisem i datą urządzenia.

Telemetria PostHog (jeśli użytkownik ją włączył): dodatkowe zdarzenia `mission_completed`, `level_reached`, `profile_open`, `skin_selected`, a istniejący `piece_drop` otrzymuje `player_level`.

## Testy

```sh
godot --headless --path . --script res://tests/test_gravity_progression.gd
godot --headless --path . --script res://tests/test_gravity_session.gd
godot --headless --path . --script res://tests/test_gravity_ads.gd
godot --headless --path . --script res://tests/test_gravity_rules.gd
```

Test progresji sprawdza: bonusy naliczane dokładnie raz, progres misji, ponowne zdarzenia, serie kalendarzowe, XP, skórki i import klasy gry. Środowisko autora nie zawierało binarki Godot, więc do czasu uruchomienia tych testów i F5 na telefonie status nadal jest **niezweryfikowaną alfą**.

## Kolejny etap

Dźwięki i haptyka, animacje przejścia poziomu, finalny onboarding, integracja faktycznego SDK AdMob/UMP na Androidzie oraz test realnego odbioru/retencji. Należy również skonfigurować klucz projektu PostHog, jeżeli zapadnie decyzja o monitorowaniu online.
