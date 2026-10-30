# POP DROP Gravity — po pełnej przebudowie beta 0.21 (30.10.2026)

## Wdrożone do main
- Ilustrowane, skalowalne panele na każdy ekran: sklep, profil, ustawienia, zakończenie gry; dodatkowo wektorowe przyciski zamykania i nawigacji.
- Nowy ekran zasad dla pierwszego uruchomienia, z osobnym pamiętaniem potwierdzenia, zatrzymaniem zegara fali i siedmioma językami.
- Sklep w galerii 2×2; 23 wpisy, sześć stron. Poprawne ikony i nazwy 12 osiągnięć.
- Prawidłowe rozpoznanie, czy dowolny ciąg darmowych obrotów pozwala uniknąć porażki (z ograniczeniem liczby stanów); test mieszanego obrotu.
- Lepsze zarobki monet za POP i limit 12 kamieni naraz; 12-seedowy test botów.
- Rozgrywka bez kosztu energii w becie. Zapis portfela zgodny z poprzednią wersją.
- Kluczowe ekrany, reklamy i onboarding PL/EN/ES/PT/DE/FR/RU.
- Zgody analityczne, usunięcie lokalnych zdarzeń i ID, anonimowy pomiar pierwszego POP-a i długości rundy wyłącznie po opt-in.
- Godot CI sprawdza import, logikę, osiem proporcji telefonów, bilans, prywatność, wszystkie skórki i wykonuje osiem rzeczywistych renderów ekranów.
- Presety `export_presets.cfg` dla Android debug APK i AAB oraz workflow tworzący APK w GitHub Actions.

## Zależności zewnętrzne i walidacja przed Play
1. Prawdziwa instalacja APK na minimum dwóch urządzeniach Android (słaby/mocny), test dotyku, animacji, FPS, crashy, pamięci i muzyki.
2. Test 10–20 graczy, rzeczywiste D1/D3/D7, średnie monety na rundę, czas do pierwszego POP-a. Boty nie dowodzą dobrego balansu.
3. Docelowy unikalny identyfikator Android package (obecny `com.example.popdropgravity` jest tylko placeholderem).
4. Dla Play: prywatny klucz podpisujący wydanie, Android Build Template/Gradle AAB, finalne informacje sklepu i komplet formularzy.
5. Reklamy dopiero po instalacji zgodnego pluginu, wprowadzeniu identyfikatora AdMob, prawdziwej zgodzie UMP i testach przyznawania nagród. Są wyłączone domyślnie.
6. Zdalny PostHog dopiero po podaniu klucza, wdrożeniu odpowiedniej polityki prywatności i kanału obsługi usunięcia danych z serwera. Obecnie opt-in bez zdalnego klucza jest tylko lokalny.
7. Obejrzenie i zaakceptowanie osiem renderów UI; zielony test automatyczny nie jest zatwierdzeniem jakości graficznej przez człowieka.
8. Wyprodukowanie i przetestowanie finalnego AAB podpisanego dla Play; sam debug APK nie spełnia warunków publikacji.

Status: **beta przygotowana w kodzie**, nie publikacja produkcyjna. Zobacz `docs/ANDROID_RELEASE.md` i `docs/SHOP.md`.
