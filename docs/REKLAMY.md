# Integracja reklam — checklist przed wydaniem

W tym prototypie NIE ma zainstalowanego AdMob ani prawdziwej reklamy.

- Akcja `reward` w `scripts/game.gd` pokazuje **jawny przycisk TEST**. `_grant_test_reward()` jedynie symuluje przyznanie nagrody.
- Przed publikacją zastąp wywołanie przycisku DEMO obsługą certyfikowanego, aktualnego pluginu Android/AdMob dla Godot.
- Realne `grant_reward` musi nadejść tylko z callbacka potwierdzającego uzyskanie nagrody (reward earned). Nie przyznawać przy kliknięciu ani samym rozpoczęciu reklamy.
- Przy błędach, braku reklamy lub jej zamknięciu bez zdobycia nagrody nie przyznawać bonusu.
- Trzeba zapobiec wielokrotnemu wykonaniu callbacka i duplikowaniu nagród dla jednego wyświetlenia.
- Nagroda: po każdej poprawnie zakończonej reklamie +1 życie i odzyskanie przestrzeni; brak limitu reklam na konto/rundę w logice gry (dostępność emisji zależy od AdMob).
- Dodatkowe jednostki reklam za power-upy. Dobrowolne oglądanie, wyraźne rozróżnienie od zakupu.
- Interstitial wyłącznie przy przejściu między rundami i z limitem częstotliwości, nigdy w trakcie ruchu ani w czasie STAR MODE.
- Zaimplementować obsługę zgód użytkownika, prywatności i danych (w tym UMP i wymagania Europejskiego Obszaru Gospodarczego), identyfikator reklamowy jeśli potrzebny, politykę prywatności, wymagania rodzinne jeśli gra będzie kierowana do dzieci.
- Tylko oficjalne testowe identyfikatory reklam podczas debugowania. Testy na realnym urządzeniu i podpisana paczka AAB.
- Nie publikować tego builda jako produkcyjnego z przyciskiem 'TEST: PRZYZNAJ NAGRODĘ', bo pozwoli to obchodzić monetyzację.
