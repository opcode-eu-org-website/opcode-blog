---
layout: post
title: Użycie klawiatury do symulacji myszy w X11
author: Robert Paciorek
tags:
- debian
- x11
---

X server pozwala na korzystanie z klawiatury w celu poruszania kursorem myszy i emulacji jej przycisków. Realizowane jest to z użyciem klawiatury numerycznej a aktywowane przy pomocy `[Shift]+[NumLock]`. Pełniejszy opis tej funkcjonalności znaleźć można np. na https://en.wikipedia.org/wiki/Mouse_keys

Funkcja wymaga włączenia w ustawieniach X servera lub z użyciem polecenia: `setxkbmap -option "keypad:pointerkeys"` a następnie aktywowania `[Shift]+[NumLock]`. Domyślnie po upływie pewnego czasu bezczynności klawiatury funckcja zostanie zdezaktywowana (i będzie musiała być ponownie aktywowana przy pomocy `[Shift]+[NumLock]`), aby temu zapobiec można wyłączyć obsługę timeoutu dla tej funkcjonalności z użyciem polecenia: `xkbset exp =mousekeys`


## modyfikacja układu klawiszy, itp.

Standardowo *mouse keys* nie pozwalają na emulowanie przewijania z użyciem kółka myszy. Uzyskanie tego wymaga modyfikacji mapy klawiszy używanej przez tą funkcjonalność. Na przykład następujaca modyfikacja pliku `/usr/share/X11/xkb/compat/mousekeys` pozwala na użycie `+` oraz `Enter` jako przewijania kółkiem myszy oraz włącza sygnalizację aktywacji *mouse keys* diodą `Scroll Lock`:

    --- /usr/share/X11/xkb/compat/mousekeys.org	2025-02-18 22:22:16.546186890 +0000
    +++ /usr/share/X11/xkb/compat/mousekeys.new	2025-02-18 22:39:54.392292818 +0000
    @@ -97,7 +97,10 @@
        action = PointerButton(button=default,count=2);
        };
        interpret KP_Add {
    -	action = PointerButton(button=default,count=2);
    +	action = PointerButton(button=4);
    +    };
    +    interpret KP_Enter {
    +	action = PointerButton(button=5);
        };
    
        interpret KP_0 {
    @@ -198,4 +201,9 @@
        indicatorDrivesKeyboard;
        controls= MouseKeys;
        };
    +
    +    // Use Scroll Lock as indicator for MouseKeys
    +    indicator "Scroll Lock" {
    +	controls= MouseKeys;
    +    };
    };

