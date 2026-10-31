# POP DROP Gravity — wydanie Android / stan 30.10.2026

## 1. Co można już zbudować

- `Android Debug Beta`: instalowalny APK dla ARM64 na testery; w GitHub Actions: workflow **Build Android beta APK**, artefakt `pop-drop-android-arm64-beta-debug`. Klucz debug generuje się w CI i nie jest przechowywany w repo.
- `Android Play AAB`: wstępny preset Gradle/Android App Bundle dla Play; **to nie jest jeszcze podpisana kompilacja produkcyjna**. Trzeba zainstalować szablon Android Build Template w Godot, skonfigurować podpisywanie wydania i dodać natywny plugin reklam (jeśli reklamy mają działać).
- Nazwa pakietu `com.example.popdropgravity` jest **tymczasowa**. Należy ustalić docelowy unikalny package ID przed publikacją. Zmiana po premierze uniemożliwia aktualizację istniejącej instalacji.
- **Android Play AAB (Gradle)**: docelowy SDK = **36** (Android 16), wymagany dla nowych aplikacji Google Play od 31.08.2026; min SDK 24, architektura arm64-v8a. **Android Debug Beta bez Gradle** korzysta z domyślnych poziomów SDK wyznaczanych przez silnik Godot, bo tej opcji nie wolno ręcznie nadpisywać. Przed publikacją potwierdzić finalny target w wyeksportowanym AAB.
- API klucze, hasła keystore i plik podpisujący nie trafiają do repo. `.gitignore` blokuje APK/AAB/keystore.

## 2. Monetizacja i prywatność

- Tryb `FREE_PLAY_BETA` umożliwia nieograniczone rundy, bez pobierania energii. Nie należy go wyłączać bez analizy D1/D7, długości rund i retencji.
- Domyślnie `pop_drop/ads/enable_admob=false`. Włączenie bez autentycznego pluginu Poing AdMob nie tworzy atrap reklam. Nagroda tylko po prawdziwym callbacku z SDK; zgody UMP wymagane.
- `pop_drop/analytics/posthog_key=""`; telemetria zdalna nie działa do wpisania klucza. Zgoda analityczna jest dobrowolna i domyślnie wyłączona. Tylko po zgodzie wysyłane są anonimowe zdarzenia.
- Ustawienie **USUŃ DANE ANALITYKI** usuwa zdarzenia lokalne i identyfikator z urządzenia. Nie oznacza automatycznego usunięcia zapisów na serwerach PostHog, jeżeli wcześniej wysłano dane. Przed publikacją potrzebna jest procedura zgłoszeń usunięcia danych u operatora analityki.
- Dla sklepu Play przygotować prawdziwą politykę prywatności, formularz Data safety, klasyfikację reklam, zgodę dla EOG i komunikację o opcjonalnych reklamach.

## 3. Testy jakości — obowiązkowe na urządzeniu

1. Minimum: tani Android 10/11 3–4 GB RAM oraz aktualny Android 15/16 z ekranem 20:9; odświeżanie 60/120 Hz.
2. Widoki: tutorial, plansza, galeria skórek na pierwszej i ostatniej stronie, profil/misje/odznaki, ustawienia i koniec gry. Sprawdzić na ekranach 320×568, 360×800, 393×873, 412×915, 540×1200.
3. Wszystkie gesty: przeciągnięcie kształtu, podgląd przed upuszczeniem, obrót lewo/prawo, naciskanie podczas animacji, anulowanie poza planszą, bomba i losowanie.
4. Testy niezawodności: tło/foreground, zamknięcie procesu w trakcie animacji, brak Internetu, powrót po dniu, zapis/odczyt zakupów, 7. dzień logowania, pełne kamienie, długa seria obrotów.
5. Dla każdej skórki: trzy czytelne warianty koloru na planszy, zgodne tło, prawidłowa muzyka i kontrola praw do assetów. Sprawdzić osoby z zaburzonym rozróżnianiem kolorów.
6. Metryki techniczne: stabilne 60 FPS na mocnym telefonie i cel ≥45 FPS na słabym, ładowanie bez zauważalnej pauzy przy pierwszej zmianie muzyki, brak crashy/ANR, rozmiar APK/AAB.
7. Co najmniej 10–20 prawdziwych testerów: zrozumienie zasad, czas pierwszego POP-a, typowy czas rundy, średnie monety/rundę, D1/D3/D7. Symulacja botem w `tests/test_gravity_balance.gd` nie zastępuje danych graczy.

## 4. Zanim uruchomimy reklamy produkcyjne

- Wybrać nazwę pakietu w Google Play; założyć konto deweloperskie i test wewnętrzny.
- Dodać **oficjalnie kompatybilny** plugin Poing AdMob/UMP do `addons/admob`; skontrolować zgodność z Godot 4.7 i build Gradle. **Ważne dla edytora Android:** adapter integracyjny jest obecnie w `docs/integrations/poing_admob_provider.gd.txt` (tekstowy szablon). Po instalacji natywnego SDK skopiować go do `scripts/poing_admob_provider.gd`, zweryfikować nazwy klas z konkretną wersją SDK, a dopiero potem włączyć `pop_drop/ads/enable_admob=true`. Bez pluginu plik `.gd` musi pozostać nieobecny, bo mobilny edytor Godota analizuje wszystkie skrypty i zgłasza błędy niezadeklarowanych klas nawet wtedy, gdy reklamy są wyłączone.
- Ustawić prawdziwy identyfikator aplikacji AdMob w manifeście/pluginie oraz jednostki rewarded/interstitial wyłącznie z konta dewelopera.
- Potwierdzić UMP consent (w tym możliwość zmiany zgody), reward callback, brak nagród za przerwaną reklamę; testować IDs Google tylko w debug.
- Po użytecznym teście A/B rozważyć interstitial, nie podczas pierwszej rundy i nie bezpośrednio po porażce bez świadomej kontroli retencji.
- Podpisać AAB kluczem prywatnym poza repo; użyć Play App Signing.

## 5. Dokumentacja zewnętrzna

- Godot 4.7: https://docs.godotengine.org/en/4.7/tutorials/export/exporting_for_android.html
- Google Play SDK 36: https://support.google.com/googleplay/android-developer/answer/11926878
- Android Gradle: https://docs.godotengine.org/en/4.7/tutorials/export/android_gradle_build.html

Stan: techniczny **beta candidate** po zielonym CI; bez wyników realnego Androida i testów użytkowników nie jest to jeszcze release-ready.
