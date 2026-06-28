---
layout: post
title: Ikony plików pokazywane na podglądzie w Dolphin
author: Robert Paciorek
tags:
- debian
- dolpin
- kde
---

Pokazywanie ikony wraz z podglądem (znane ze starego KDE) zostało usunięte z KIO w efekcie [https://bugs.kde.org/show_bug.cgi?id=425789](https://bugs.kde.org/show_bug.cgi?id=425789) i nigdy nie zaimplementowane w Dolphin. Aby przywrócić to zachowanie można spróbować kilku podejść.


## własny generator podglądu

### .thumbnailer

Biblioteka KIO obsluguje podglądy definiowane w plikach [`.thumbnailer`](https://gitlab.freedesktop.org/xdg/xdg-specs/-/work_items/201).
Plik taki musi mieć rozszerzenie `.thumbnailer`, być umieszczony w `~/.local/share/thumbnailers/` (lub `/usr/share/thumbnailers`) i być postaci:

```
[Thumbnailer Entry]
Exec=PATH_TO_OWN_TOOL %i %o %s
MimeType=text/x-python3;text/plain;text/x-python;text/x-cmake;text/html;
```

`PATH_TO_OWN_TOOL` zamieniamy na ścieżkę do naszego programu (argumenty które dostaje: `%i` - plik dla którego tworzymy podgląd, `%o` - plik tymczasowy do którego zapisujemy podgląd, `%s` - rozmiar podglądu) oraz dostosowujemy listę typów mime.

Wtyczki rejestrowane są w ustalonej kolejności (pierwsza alfabetycznie wtyczka w `~/.local/share/thumbnailers/` będzie mieć najwyższy priorytet.
Jest to istotne gdyż kolejna wtyczka nie ma możliwości obsługi typów mime już zarejestrowanych przez inną ([porównaj](https://invent.kde.org/frameworks/kio/-/merge_requests/1651/diffs#679b0d63b2445f7cdba799bb066e5ebeb42dadc2_175_191)).

Przed rozpoczęciem ładowania wtyczek `.thumbnailer` ładowane są wszystkie natywne wtyczki kio (`/usr/lib/x86_64-linux-gnu/qt6/plugins/kf6/thumbcreator/`), w związku z czym takie rozszerzenia nie będą nigdy dostępne dla typów obsługiwanych przez natywne wtyczki, `/usr/lib/x86_64-linux-gnu/qt6/plugins/kf6/thumbcreator/`

### wtyczka KIO

Biblioteka KIO pozwala na tworzenie własnych generatorów podglądu w postaci wspomnianych wtyczek w `/usr/lib/x86_64-linux-gnu/qt6/plugins/kf6/thumbcreator/`. Przykładem takiej wtyczki jest [keneric](https://github.com/Hizoka76/keneric_qt6/).

Podejście takie wymagałoby jednak przeniesienia obsługi wszystkich typów na tą wtyczkę oraz własnej implementacji gemnerowania podglądów dla nich.
Rozwiązanie `.thumbnailer` oraz keneric będą wolniejsze (ze względu na wywołania zewnętrznych programów) niż wewnętrzne generowanie podglądu w wtyczkach KIO.

### więcej informacji o podglądach

Informacje o bibliotekach i programach wspierających Dolphina w generowaniu podglądów (oraz sporo informacji o samym Dolphin) można znaleźć na [https://wiki.archlinux.org/title/Dolphin](https://wiki.archlinux.org/title/Dolphin).


## patch dla Dolphin:

Najlepszym podejściem wydaje się podążenie za ideą przedstawioną w problematycznym zgłoszeniu błędu i przeniesienie obsługi nakładania ikony do samego Dolphina. [Oto taki patch](/files/dolphin-icons-on-preview.patch).
