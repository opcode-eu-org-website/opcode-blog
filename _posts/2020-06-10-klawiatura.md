---
layout: post
title: Konfiguracja układu klawiatury
author: Robert Paciorek
tags:
- debian
- x11
---

## Trochę teorii ...

Obsługa klawiatur w systemach linux odbywa się kilkupoziomowo.

### scancode → keycode

W pierwszej kolejności jądro otrzymuje od urządzenia numer naciśniętego klawisza w postaci *scancode*.
*Scancode* danego klawisza można poznać przy pomocy `showkey -s` (aby mieć pewność że jest to prawdziwa, surowa wartość jądro powinno być uruchomione z opcją `atkbd.softraw=0`).
*Scancode*:

* może być jedno lub wielo bajtowy (np. główny "Enter" ma `0x1c` a jego odpowiednik z klawiatury numerycznej ma `0xe0 0x1c`)
* inna jego wartość związana jest z wciśnięciem przycisku a inna z jego puszczeniem (np. dla głównego "Enter" będzie to odpowiednio `0x1c` i `0x9c`)
* z wieloma klawiszami związane jest automatyczne generowanie powtórzeń kodu wciśnięcia, jednak nie musi do dotyczyć wszystkich klawiszy (np. multimdialnych),
  jego częstotliwość może być zmieniona przy pomocy polecenia `kbdrate` (jest to ustawienie związane z samym urządzeniem, realizowane przez odpowiednie `ioctl`).

Następnie *scancode* jest mapowany przez jądro na *keycode*.
Używane do tego są tablice mapowań które mogą być odczytywane i zmieniane poleceniami `getkeycodes`, `setkeycodes`.
*Keycode* danego klawisza można poznać przy pomocy `showkey -k`.

Z wartościami *Keycode* skojarzone są ich nazwy postaci `KEY_XXXX` – pełne mapowanie pomiędzy wartościami numerycznymi a tymi nazwami znaleźć można w pliku `/usr/include/linux/input-event-codes.h`.
Warto zauważyć że nazwy typu `KEY_Y` są prawdziwe dla układu klawiatury QWERTY (*keycode* 21 zawsze ma nazwę KEY_Y, ale na układach QWERZ wprowadza litę z).

### keycode → znak

Kolejnym etapem jest mapowanie *keycode* (wraz z obecnymi przy nim modyfikatorami) na znak (lub ciąg znaków, bądź modyfikator), który ma być wprowadzany przy jego pomocy.
To na tym etapie ustalane jest że np. `keycode == 2` będzie normalnie wprowadzał znak `1`, a z modyfikatorem *shift* będzie wprowadzał znak `!`.
To również na tym etapie ustalane jest że np. `keycode == 42` będzie oznaczał modyfikator *shift*.

Warto wspomnieć, iż klawiszom nie mapowanym na znak drukowany lub sterujący ASCII (np. strzałki, F1, F12) przypisywany jest ciąg znaków rozpoczynający się od bajtu 0x1B (escape, zapisywany wizualnie niekiedy jako `^[`). Na przykład strzałka w górę zostanie zamieniona na sekwencję 3 bajtów: 0x1B 0x5B 0x41, czyli `^[[A`. Niektóre z programów nie rozumieją sekwencji związanych z niektórymi klawiszami (np. strzałkami) i wypisują je na ekran w postaci np. `^[[A`. Sekwencję taka można także wprowadzić naciskając jako <span class="key">Ctrl</span>+<span class="key">[</span>, <span class="key">[</span>, <span class="key">A</span> i zostanie ona zrozumiana przez wiele programów jako strzałka w górę (wyjątkiem mogą być programy obsługujące terminal w bardziej zaawansowany sposób np. poprzez *ncurses*).

Na tym etapie rozchodzi się także konfiguracja klawiatury na potrzeby konsoli tekstowej i X serwera.
Warto tu zauważyć, że X serwer operuje na wartościach *keycode* zwiększonych o 8, a konsola tekstowa bezpośrednio na wartościach *keycode*.
Wartość *keycode* X serwera związaną z danym klawiszem (oraz informacje o jego dalszym mapowaniu) można odczytać przy użyciu polecenia `xev`.

<p style="text-align: center;"><img style="width:95%;" alt="" src="/files/keyboard.svg" /></p>

## Konfiguracja

W większości przypadków nie jest potrzebna jakakolwiek ręczna konfiguracja klawiatury na poziomie mapowania *scancode* na *keycode* (czy też wcześniejszym samego generowania *scancode* przez urządzenie).
Wyjątkiem mogą być nietypowe klawiatury (np. niektóre klawiatury multimedialne, czy też przyciski specjalne w laptopach).

Natomiast potrzeba konfiguracji mapowań *keycode* na konkretne znaki jest częsta – konieczna (w takiej czy innej formie) zawsze gdy chcemy używać z innego układu klawiatury niż `us`.

### konsola tekstowa

Mapy klawiatur dla konsoli tekstowej operują na wartościach *keycode* i konfigurowane / odczytywane są przy pomocy poleceń `loadkeys` / `dumpkeys`.

Źródłem danych dla `loadkeys` moga być mapy z pakietu `console-data` lub przetwarzane przy pomocy `ckbcomp` mapy z pakietu `xkb-data`.
Bezpośrednie ładowanie przez `loadkeys` map z pakietu `console-data` ma problem z kodowaniem – mapa jest ładowana w kodowaniu latin1 pomimo że powinna być w kodowaniu latin2.
Pakiet `console-setup` domyślnie używa map konwertowanych z xkb, co rozwiązuje ten problem i pozwala łatwiej uzyskać spójną (taką samą) konfigurację klawiatury w konsoli tekstowej jak i w X serwerze.

Konfiguracja klawiatury używana przez pakiet `console-setup` znajduje się w pliku `/etc/default/keyboard`, który może mieć postać np.:

	XKBLAYOUT="pl"
	XKBOPTIONS="kpdl:dot"

Powoduje to ustawienie układu "polski programisty" z kropką na klawiaturze numerycznej.
Więcej zmiennych które można ustawić w tym pliku oraz informacji na jego tema można znaleźć w `man 5 keyboard`.

Zmiany w `/etc/default/keyboard` będą widoczne na konsolach tekstowych po wykonaniu polecenia: `systemctl restart keyboard-setup`.

Włączenie trybu NumLock w konsoli tekstowej możliwe jest przy pomocy polecenia: `setleds -D +num`.
Dodanie go do skryptów startowych powoduje automatyczne włączanie NumLock'a po uruchomieniu systemu lub zalogowaniu.

### X serwer

Ustawienia w `/etc/default/keyboard` po reboocie lub wykonaniu polecenia `udevadm trigger --subsystem-match=input --action=change` powinny ustawić także odpowiedni układ klawiatury w środowisku graficznym.

Układ ten może być zmieniony także przy pomocy polecenia `setxkbmap`. Podanej powyżej konfiguracji odpowiada wywołanie:

	setxkbmap -option "kpdl:dot" pl

Możliwe jest też modyfikowanie ustawień dla konkretnych *keycode* (a także np. przycisków przypisanych do modyfikatorów) przy pomocy `xmodmap`.
Na przykład poniższe polecenia dadzą efekt taki jak opcja `kpdl:dot` (czyli kropkę na klawiaturze numerycznej):

	setxkbmap -option "" pl
	xmodmap -e "keycode 91 = KP_Delete KP_Decimal KP_Delete KP_Decimal"

Listę wszystkich dostępnych wartości dla opcji `-model`, `-layout`, `-variant` i `-option` polecenia `setxkbmap` można znaleźć w plikach `/usr/share/X11/xkb/rules/*.lst`.
Aktualne ustawienia mapowania klawiatury w X serwerze można sprawdzić w wyniku polecenia `setxkbmap -print -v 10`, warto zwrócić uwagę na dwie wartości:

* `xkb_keycodes` odpowiada za mapowanie numerów *keycode* na nazwy używane w plikach opisujących układy klawiatur, pliki tych mapowań można znaleźć w `/usr/share/X11/xkb/keycodes`
* `xkb_symbols` odpowiada za wybór mapowania nazw związanych z *keycode* na *keysym*, pliki tych mapowań można znaleźć w `/usr/share/X11/xkb/symbols`

Na ustawienie `xkb_keycodes` może mieć znaczący wpływ opcja `-model`, jednak jako że X serwer działający na platformie Linux korzysta z eventów systemowych używających standardowych wartości *keycode*,
to w współczesnych systemach Linux'owych opcję tą można praktycznie zaniedbać (dla niemal wszystkich modeli klawiatur `xkb_keycodes` jest ustawiane na standardowe `evdev`).


#### automatyczne włączenie NumLock

Włączenie trybu NumLock w X serwerze nie jest możliwe z użyciem `setleds`. Można zamiast tego skorzystać np. z polecenia `numlockx` (z pakietu o tej samej nazwie) lub następującego skryptu Python'a (operującego na wywołaniach libX11):

	python -c 'from ctypes import *; X11 = cdll.LoadLibrary("libX11.so.6"); X11.XOpenDisplay.restype = c_void_p; display = X11.XOpenDisplay(None); X11.XkbLockModifiers(c_void_p(display), c_uint(0x0100), c_uint(16), c_uint(16)); X11.XCloseDisplay(c_void_p(display))';

#### prędkość powtarzania

X serwer samodzielnie generuje sygnały związane z powtórzeniami przycisków w oparciu o *keycode* związany ze zdarzeniem *press* i *release*
(nie korzysta w tym celu z powtarzania konfigurowanego poprzez `kbdrate`).
W celu zmiany opóżnienia lub częstotliwości powtarzania można skorzystać z polecenia `xset r rate` np. `xset r rate 200 10` ustawi opóźnienie pierwszego powtórzenia na 200ms i częstotliwość powtórzeń na 10Hz.
`xset` pozwala także na włączenie / wyłączenie powtórzeń dla konkretnych klawiszy.

#### klawisz komponujący

Oprócz typowego wprowadzania znaków niedostępnych bezpośrednio (metoda ta nie ogranicza się tylko do polskich ogonków) z użyciem modyfikatora Alt-Gr (prawy Alt) możliwe jest także wprowadzania niedostępnych znaków przy pomocy uzyskiwanego przez niektóre z kombinacji Alt-Gr [martwego klawisza](http://pl.wikipedia.org/wiki/Martwy klawisz) oraz [klawisza komponującego](http://pl.wikipedia.org/wiki/Klawisz komponujący).

Aby skorzystać z klawisza komponującego konieczne jest przypisanie go do któregoś z modyfikatorów na klawiaturze np. do prawego WinKey - można to zrobić np. poprzez `setxkbmap -option compose:rwin`.
Klawisz komponujący potrafi używać indywidualnej mapy dla użytkownika umieszczonej w pliku `~/.XCompose` (za wzorzec mogą posłużyć mapy systemowe z `/usr/share/X11/locale/*/Compose`).

#### mapowanie odwrotne

Biblioteka Xów dostarcza też możliwość odwrotnego mapowania *keysym* → *keycode* przy użyciu funkcji `XKeysymToKeycode`.
Należy pamiętać że mapowanie w tą stronę może nie być jednoznaczne (kilka różnych wartości *keycode* może wskazywać na ten sam *keysym*).
W takim przypadku funkcja ta może zwrócić inną wartość *keycode* niż powiększona o 8 wartość otrzymana z jądra – widać to np. w wyniku polecenia `xev` przy klawiaturze mającej skonfigurowaną kropkę na klawiaturze numerycznej:

	state 0x10, keycode 91 (keysym 0xffae, KP_Decimal), same_screen YES,
	XKeysymToKeycode returns keycode: 129
	XLookupString gives 1 bytes: (2e) "."

#### graficzna prezentacja układu klawiatury

Komenda `setxkbmap` obsługuje argument `-geometry` wskazujący na plik z geometrią klawiatury który ma zostać użyty.
Pliki geometrii znajdują się w `/usr/share/X11/xkb/geometry/` i zgodnie z <span title="Geometry files aren't used by xkb itself but they may be used by some external programs to depict a keyboard image. (https://www.x.org/releases/X11R7.5/doc/input/XKB-Enhancing.html)">dokumentacją xkb</span> pliki geometrii nie są używane do dokonywania ustawień, ale mogą służyć właśnie generacji takich obrazków przy pomocy np.:

	setxkbmap pl -geometry 'pc(pc105)' -print | xkbcomp - - | xkbprint - - | ps2pdf - > pc105.pdf

#### zobacz także

* [X keyboard extension @ ArchWiki](https://wiki.archlinux.org/index.php/X_keyboard_extension)
* [Xorg Keyboard configuration @ ArchWiki](https://wiki.archlinux.org/index.php/Xorg/Keyboard_configuration)
* [Klawisze z *keycode* &gt; 0xf7 - evtest, udev](https://morfikov.github.io/post/klawiatura-multimedialna-i-niedzialajace-klawisze/)
* [Wprowadzanie znaków niedostępnych na klawiaturze](http://dug.net.pl/tekst/151/)

## Odbiornik IR i sterowanie pilotem
Możliwe jest także korzystanie z pilotów podczerwieni do sterowania komputerem z linuxem, przy pomocy odpowiedniego odbiornika.
Wbudowany odbiornik podczerwieni posiada wiele z tunerów telewizyjnych DVB.
Jeżeli jest on obsługiwany przez nasze jądo mapowania jego przycisków na sygnały klawiatury możemy dokonać z wykorzystaniem `ir-keytable`.

Polecenie `ir-keytable` wylistuje dostępne odbiorniki podczerwieni wraz z informacjami na ich temat. 

Polecenie `ir-keytable -s rc0 -t -v` pozwala na wyświetlanie dla wskazanego odbiornika (w tym przykładzie `rc0`) surowych numerów przycisków zczytanych z pilota – *scancode* oraz przypisanych do nich *keycode*.
Wartości *keycode* wypisywane są w postaci `KEY_XXXX(0xNNNN)`, gdzie `0xNNNN` to szesnastkowo zapisany numer *keycode* a `KEY_XXXX` to związana z nim nazwa.

Polecenie `ir-keytable -s rc0 -w /etc/rc_keymaps/rtl_simple` pozwala załadować tablice mapowań *scancode* → *keycode* (w tym przykładzie `/etc/rc_keymaps/rtl_simple`) dla wskazanego odbiornika podczerwieni (w tym przykładzie `rc0`).
Tablica taka ma postać pliku tekstowego, rozpoczynającego się komentarzem sterującym określającym nazwę tej tablicy oraz używany protokół komunikacji z pilotem - np. `# table rtl_simple, type: NEC`.
W kolejnych liniach podawane są mapowania – w pierwszej kolumnie podawana jest numeryczna wartość *scancode*, a w drugiej numeryczna wartość lub nazwa *keycode* na który ma być on mapowany.
Przykładowy plik może wyglądać następująco:

	# table rtl_simple, type: NEC
	
	# duzy pilot - srodkowe "kolko" (L, R, ENTER, UP, DOWN)
	0xe5004c KEY_PREVIOUSSONG
	0xe50040 KEY_NEXTSONG
	0xe50006 KEY_PLAYPAUSE
	0xe50044 KEY_VOLUMEUP
	0xe50048 KEY_VOLUMEDOWN
	
	# duzy pilot - numeryczne (1, 3, 4, 6, 7, 9) jako jump
	0xe50009 KEY_BACK
	0xe50001 KEY_FORWARD
	0xe5004b KEY_PAGEUP
	0xe50043 KEY_PAGEDOWN
	0xe5004a KEY_HOME
	0xe50042 KEY_END
	
	# inne
	0xe50057 KEY_PLAYPAUSE
	0xe5005e KEY_PLAYPAUSE
	0xe5005a KEY_STOPCD

Aby ustawienia były wczytywane automatycznie po starcie systemu / podłączeniu urządzenia należy w pliku `/etc/rc_maps.cfg` dodać wpis wiąrzący moduł obsługujący odbiornik IR z mapą klawiszy - np: `dvb_usb_rtl28xxu  *   rtl_simple`, gdzie mapa zapisana w pliku `/etc/rc_keymaps/rtl_simple`.

Należy mieć na uwadze, że po dodaniu nowych (nie występujących wcześniej w konfiguracji tego urządzenia) wartości *keycode* aby były zauważone w X serwerze (np. w `xev`) należy zrestartować odbiornik podczerwieni lub X serwer.
Restart odbiornika `rc0` można także zasymulować poleceniem `udevadm trigger --action=change /sys/class/rc/rc0`.
Wynika to z tego ze X serwer ogranicza się do obsługi eventów odczytanych na starcie z /dev/input/event* jako obsługiwane przez dane urządzenie. Zobacz wynik polecenia `evtest` na urządzeniu `/dev/input/event` związanym z danym odbiornikiem podczerwieni.

W przypadku chęci korzystania z odbiornika w aplikacjach opartych na X serwerze należy także unikać *keycode* o wartościach większych niż 0xf7 (patrz limity określone w `/usr/share/X11/xkb/keycodes/evdev`).
