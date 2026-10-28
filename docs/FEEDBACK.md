# POP DROP Gravity 0.6 — audio, dotyk i celebracje

## Oprawa dźwiękowa
- `scripts/gravity_feedback.gd` generuje jednorazowo przy uruchomieniu 8 krótkich, oryginalnych efektów PCM (16-bit, mono, 22050 Hz). Nie pobiera niczego z internetu i nie zawiera muzyki chronionej.
- Zdarzenia: `tap` (interfejs), `drop` (zrzut), `rotate` (obrót), `pop` (kasowanie 5+), `cascade` (kolejne łańcuchy), `mission` (ukończenie misji), `level` (awans), `fail` (utrata życia).
- Pool 5 `AudioStreamPlayer` pozwala na nakładanie się dźwięków, a dla identycznego dźwięku zastosowano limit 65 ms.
- Ustawienie w menu **DATA → DŹWIĘKI / SOUND** jest zachowywane w `user://gravity_feedback_v1.json`. Dźwięki można całkowicie wyłączyć.

## Wibracje
- Delikatne, różne długości impulsu dla zrzutu, obrotu, POP, misji, awansu i straty życia.
- Przełącznik **DATA → WIBRACJE / HAPTICS**, niezależny od audio. Domyślnie włączony, ale gracz może wyłączyć.
- Na Androidzie w eksportowanym projekcie trzeba zaznaczyć **Permissions → VIBRATE**. Inaczej Godot `Input.vibrate_handheld` nie działa.
- Wibracje nie aktywują się w czasie pracy na PC; na urządzeniu system może je ograniczyć.

## Celebracja awansu
- Po wejściu na kolejny poziom: złoty pulsuący panel, duży numer poziomu, rozsypujące się iskry i dodatkowe rozbłyski.
- Efekt nie przerywa gry ani nie blokuje kolejnego ruchu.
- Misja wywołuje krótszy sygnał i toast +XP.

## Weryfikacja
Automatyczny test: 
```sh
godot --headless --path . --script res://tests/test_gravity_feedback.gd
```
Test sprawdza połączenie gry z modułem audio, liczbę klipów, generowane bajty PCM, rozmiary, tryb 16-bit, sterowanie włącz/wyłącz i brak awarii przy nieznanym efekcie. CI w `.github/workflows/godot-tests.yml` wykonuje go wraz z regresją gry.

### Testy ręczne na Androidzie
1. Sprawdź głośność zrzutu, obrotu, POP i kilku kaskad; dźwięki nie powinny się zlewać ani trzeszczeć.
2. Wyłącz dźwięki w DATA, wykonaj ruch, zamknij i otwórz aplikację, sprawdź, czy ustawienie pozostało.
3. Wyłącz wibracje, uruchom kaskadę i nowy poziom, sprawdź brak wibracji.
4. Wykonaj awans, zweryfikuj, że panel pojawia się na 3 sekundy, ale nie blokuje dotyku.
5. Zmierz FPS na telefonach budżetowych (efekty generowane przy starcie; animacje dodatkowe w czasie awansu).

## Pozostały blok
Reklamy AdMob nadal wymagają podpięcia natywnego pluginu Poing, App ID i identyfikatorów jednostek reklamowych oraz testu zgód UMP i eksportu Android. Nie symulujemy działających reklam. Szczegóły: `docs/MOBILE_FOUNDATION.md`.
