---
layout: post
title: Konfiguracja poinstalacyjna Debian Buster
author: Robert Paciorek
tags:
- debian
- shell
- x11
---

## Instalacja dodatkowych pakietów i ustawienia ogólne

Po instalacji systemu prawie zawsze konieczne jest jego dostosowanie poprzez instalację potrzebnego oprogramowania oraz utworzenie lub modyfikację pewnych plików konfiguracyjnych.
Jeżeli często instalujemy system z jakimiś zbiorami oprogramowania to instalację tego oprogramowania można w różny sposób automatyzować – np. własne meta pakiety z zależnościami, skrypty instalacyjne, etc.
Zamieszczam przykład [skryptu służącego do wyboru i instalacji pakietów](/files/buster-post-install.sh) z podzielonymi na kategorie tematyczne listami pakietów wartych w mojej opinii zainstalowania lub przynajmniej przetestowania.

Poniżej zamieszczam informacje związane z konfiguracją wybranych programów. Polecam także inne wpisy związane z konfiguracją systemu:

* [Wsparcie UTF-8 bez instalowania locali](/2019/03/29/utf-8_bez_locales.html)
* [Zaginione ikony w aplikacjach KDE](/2019/04/07/zagionione_ikony_w_kate.html)
* [Konqueror](/2019/07/07/konqueror.html)


## Bash

[Bash](https://packages.debian.org/stable/bash) jest najpopularniejszą powłoką systemową w systemach linuxowych. W zależności od sposobu uruchamiana (powłoka logowania, czy zwykła) bash na starcie uruchamia odpowiednie pliki konfiguracyjne, które są skryptami bashowymi:

* `~/.bash_profile` dla powłoki logowania
* `~/.bashrc` dla zwykłych powłok interaktywnych

Jeżeli chcemy aby na powłokach logowania także wykonywany był `~/.bashrc` należy zainkludować go w pliku `~/.bash_profile` poprzez np.:

	[ -f ~/.bashrc ] && . ~/.bashrc

Zamieszczam przykładowy plik [`~/.bashrc`](/files/linux-configs/bashrc), który m.in.:

* konfiguruje zapisywanie historii bez powtórzeń oraz wykonuje backup pliku historii
* włącza zaawansowane auto-uzupełnianie (w oparciu o pakiet [bash-completion](https://packages.debian.org/stable/bash-completion))
* ustawia zmienne środowiskowe, aliasy i przydatne funkcje (np. uproszczone wywołanie *schroot*, rekurencyjnego wyszukiwania i zastępowania)
* wywołuje menu pytające o uruchomienie lub wybór sesji *tmux* przy starcie powłoki w wybranych terminalach

## Vim

[Vim](https://packages.debian.org/stable/vim) jest zaawansowanym edytorem tekstu działającym w trybie tekstowym.
Zamieszczam przykładowy, dość minimalistyczny plik [`~/.vimrc`](/files/linux-configs/vimrc).

## Tmux

[Tmux](https://packages.debian.org/stable/tmux) jest multiplekserem terminali pozwalającym na uzyskanie wiele okien na jednym terminalu (także przez pionowe i poziome podziały), odłączanie się i podłączanie się do takich sesji, współdzielenie tej samej sesji na wielu oknach terminala, itd.

Zamieszczam przykładowy plik [`~/.tmux.conf`](/files/linux-configs/tmux.conf), który m.in.:

* modyfikuje mapowania klawiszy (szczegóły poniżej)
* konfiguruje pasek statusu
* powoduje odpowiednie ustawianie tytułu okna *xterm*


### klawiszologia

Jeżeli nie zaznaczono inaczej podane komendy należy poprzedzić *tmux prefix key*, czyli <span class="key">Ctrl</span>+<span class="key">b</span> lub <span class="key red">Ctrl</span>+<span class="key red">x</span>,
czyli aby np. wyświetlić informację o mapowaniu klawiszy w tmux (polecenie <span class="key">?</span>) należy wprowadzić: <span class="key">Ctrl</span>+<span class="key">b</span>, <span class="key">?</span>.
Aby przekazać do programu uruchomionego w tmux'ie klawisz wprowadzający *tmux prefix key* należy wprowadzić go dwukrotnie,
czyli <span class="key">Ctrl</span>+<span class="key">b</span>, <span class="key">Ctrl</span>+<span class="key">b</span> przekaże <span class="key">Ctrl</span>+<span class="key">b</span> do programu działającego w tmux'ie
(analogicznie z <span class="key red">Ctrl</span>+<span class="key red">x</span>).

Kolorem <span class="red">czerwonym</span> oznaczono niestandardowe mapowania skonfigurowane w prezentowanym `.tmux.conf`.

* ogólne:
	* przełączenie obsługi myszki w tmux: <span class="key red">m</span>
	* lista mapowań klawiszy: <span class="key">?</span>
* tworzenie, przełączanie i zamykanie okien
	* nowe okno: <span class="key">c</span>
	* następne / poprzednie okno: <span class="key">n</span> / <span class="key">p</span>
	* lista okien: <span class="key">w</span>
	* zamknij (zabij) okno: <span class="key">&</span>
* panele, czyli podzielone okna
	* podziel poziomo:
		* utwórz nowe: <span class="key red">h</span> lub <span class="key">"</span>
		* dołącz istniejące: <span class="key red">H</span>
	* podziel pionowo:
		* utwórz nowe: <span class="key red">v</span> lub <span class="key">%</span>
		* dołącz istniejące: <span class="key red">V</span>
	* pokaż numeracje i przełącz na podany: <span class="key">q</span>
	* zamień miejscami z następnym / poprzednim: <span class="key">}</span> / <span class="key">{</span>
	* przełącz panel: strzałki
	* zmień rozmiar panelu: <span class="key">Ctrl</span>+strzałki
	* zamknij (zabij) panel: <span class="key">x</span> lub <span class="key red">^</span>
* bufory, czyli przeszukiwanie, kopiowanie i przeglądanie zawartości okna
	* wejście w tryb buforu historii: <span class="key red">Esc</span>
	* polecenia w trybie bufora historii (nie wymagają poprzedzania *tmux prefix key*):
		* przewijanie: strzałki lub kółko myszy lub <span class="key">PgUp</span>/<span class="key">PgDown</span>
		* wyszukiwanie: <span class="key">/</span> oraz <span class="key">n</span> lub <span class="key">?</span>
		* początek zaznaczania: <span class="key red">spacja</span> lub <span class="key red">v</span>
		* skopiowanie i wyjście z trybu: <span class="key red">enter</span> lub <span class="key red">y</span>
		* anulowanie zaznaczenia: <span class="key">Esc</span>
	* wklejenie: <span class="key red">P</span>
	* zapis całego bufora panelu do pliku: <span class="key red">Ctrl</span>+<span class="key red">s</span>
	* włączenie logowania panelu do pliku: <span class="key red">Ctrl</span>+<span class="key red">l</span>
	* wyczyszczenie historii: <span class="key red">Ctrl</span>+<span class="key red">q</span>
* sesje
	* lista wyboru sesji: <span class="key">s</span>
	* zmiana nazwy sesji: <span class="key">$</span>
	* odłączenie bieżącego klienta: <span class="key">d</span>
	* odłączenie wskazanego klienta: <span class="key">D</span>
	* blokada bieżącej sesji: <span class="key red">b</span>
* inne
	* zegar w obecnym panelu: <span class="key">t</span>
	* informacja o dacie i czasie: <span class="key red">Ctrl</span>+<span class="key red">t</span>
	* kalenarz trzymiesięczny: <span class="key red">Ctrl</span>+<span class="key red">c</span>

* komendy szybkiego dostępu (nie wymagają poprzedzania *tmux prefix key*):
	* następne / poprzednie okno: <span class="key red">Alt</span>+<span class="key red">PageUp</span> / <span class="key red">Alt</span>+<span class="key red">PageDown</span>
	* przełącz panel: <span class="key red">Alt</span>+<span class="red">strzałki</span>


## Xterm

[Xterm](https://packages.debian.org/stable/xterm) jest emulatorem terminala działającym pod kontrolą X serwera.
Przy odpowiedniej konfiguracji wspiera on UTF-8 i czcionki *TrueType*.
Jego konfiguracja umieszczana jest w ogólnym pliku konfiguracyjnym aplikacji działających w środowisku graficznym – `~/.Xdefaults` i może wyglądać następująco:

	! utf8
	xterm.vt100.utf8: always
	xterm.vt100.utf8Title: true
	xterm.vt100.utf8Fonts: true
	
	! use TrueType font
	xterm.vt100.renderFont: true
	XTerm*faceName: Monospace
	XTerm*faceSize: 12
	
	! visual - cursor, colors, ...
	xterm.vt100.cursorBlink: true
	XTerm*foreground: green
	XTerm*background: black
	
	! set TERM env variable
	! xterm.termName: xterm-256color

Użycie `XTerm*` zamiast `xterm.vt100.` pozwala na nadpisywanie tych ustawień z użyciem opcji linii poleceń, na przykład: `xterm -bg black -fg white -fs 10 /usr/bin/python3`.


## OpenBox

[OpenBox](https://packages.debian.org/stable/openbox) jest wysoce konfigurowalnym, lekkim i niezależnym od żadnego dużego, zintegrowanego środowiska graficznego menedżerem okien dla X serwera.
Jego pliki konfiguracyjne umieszczane są w katalogu ` ~/.config/openbox/` i mogą to być m.in.:

* [`rc.xml`](/files/linux-configs/openbox-rc.xml) – odpowiedzialny m.in. za podstawowe ustawienia zachowania menadżera okien, wygląd dekoracji okien oraz skróty klawiszowe
* [`menu.xml`](/files/linux-configs/openbox-menu.xml) – odpowiedzialny za konfigurację menu, może tam być np. zdefiniowane `root-menu` wyświetlane po kliknięciu prawym przyciskiem myszy w pulpit
* [`autostart.sh`](/files/linux-configs/openbox-autostart.sh) – skrypt wykonywany przy stacie menadżera okien, może określać automatycznie uruchamiane aplikację, konfigurować tapetę pulpitu, itp.

### klawiszologia

Plik `rc.xml` odpowiada m.in. za konfigurację skrótów klawiszowych, w prezentowanym pliku konfiguracyjnym ustawione są następujące skróty:

* okno
	* aktyawacja:
		* <span class="key">Alt</span> + <span class="key" title="lewy przycisk myszy">LPM</span>
		* <span class="key" title="lewy przycisk myszy">LPM</span> na belce tytułowej
	* aktywacja bez przesunięcia na wierzch:
		* <span class="key">Alt</span> + <span class="key" title="prawy przycisk myszy">PPM</span>
	* menu:
		* <span class="key">Alt</span> + <span class="key">Win</span> + <span class="key" title="prawy przycisk myszy">PPM</span>
		* <span class="key">Alt</span> + <span class="key">Space</span>
		* <span class="key" title="prawy przycisk myszy">PPM</span> na belce tytułowej
	* przenoszenie:
		* <span class="key">Alt</span> + <span class="key" title="lewy przycisk myszy">LPM</span>
		* <span class="key" title="lewy przycisk myszy">LPM</span> na belce tytułowej
	* zmiana rozmiaru:
		* <span class="key">Alt</span> + <span class="key" title="prawy przycisk myszy">PPM</span>
		* <span class="key" title="lewy przycisk myszy">LPM</span> na krawędzi
	* zamknięcie:
		* <span class="key">Alt</span>+<span class="key">F4</span>

* pulpity
	* przełączanie na 
		* pulpit x:
			* <span class="key">Ctrl</span> + <span class="key">Fx</span>
		* następny / poprzedni pulpit:
			* <span class="key">Ctrl</span> + <span class="key">Tab</span>
			* <span class="key">Ctrl</span> + <span class="key">Shift</span> + <span class="key">Tab</span>
			* <span class="key">Alt</span> + kółko myszy
	* przeniesienie okna na
		* pulipt x i przełączenie na ten pulpit:
			* <span class="key">Win</span> + <span class="key">Ctrl</span> + <span class="key">Fx</span>
		* pulipt x bez przełączenia na ten pulpit:
			* <span class="key">Win</span> + <span class="key">Ctrl</span> + <span class="key">Shift</span> + <span class="key">Fx</span>
		* następny pulpit i przełączenie na ten pulpit:
			* <span class="key">Alt</span> + <span class="key">Win</span> + kółko myszy
		* następny pulpit bez przełączenia na ten pulpit:
			* <span class="key">Alt</span> + <span class="key">Win</span> + <span class="key">Shift</span> + kółko myszy

* przełączanie okien
	* na bieżącym pulpicie:
		* <span class="key">Alt</span> + <span class="key">Tab</span>
		* <span class="key">Alt</span> + <span class="key">Shift</span> + <span class="key">Tab</span>
	* z wszystkich pulpitów:
		* <span class="key">Alt</span> + <span class="key">Ctrl</span> + <span class="key">Tab</span>
		* <span class="key">Alt</span> + <span class="key">Ctrl</span> + <span class="key">Shift</span> + <span class="key">Tab</span>
	* lista okien na wszystkich pulpitach:
		* <span class="key">Win</span> + <span class="key">d</span>
		* <span class="key">Win</span> + <span class="key">Shift</span>
		* <span class="key">d</span>  lub  <span class="key" title="środkowy przycisk myszy">ŚPM</span> na pulpicie

* inne
	* terminal: <span class="key">Alt</span> + <span class="key">F1</span> / <span class="key">Win</span> + <span class="key">t</span>
	* run command (z użyciem [grun](https://packages.debian.org/stable/grun)): <span class="key">Alt</span> + <span class="key">F2</span> / <span class="key">Win</span> + <span class="key">r</span>
	* menu systemowe: <span class="key" title="prawy przycisk myszy">PPM</span> na pulpicie

### ikony na belce tytułowej

W pliku tym skonfigurowane są także ikony na pasku tytułowym okna w sposób następujący:

* po lewej:
	* wszystkie pulpity
	* zawsze na wieszchu
	* menu (ikona aplikacji)
* po prawej:
	* minimalizacja
	* maksymalizacja (<span class="key" title="lewy przycisk myszy">LPM</span> – pełna, <span class="key" title="środkowy przycisk myszy">ŚPM</span> – w pionie, <span class="key" title="prawy przycisk myszy">PPM</span> – w poziomie)
	* zamknięcie

## Fbpanel

Przydatnym dodatkiem do openboxa może być panel z podglądem i  przełączaniem pulpitów, okien, zegarkiem, itp. Funkcję taką może pełnić np. [fbpanel](https://packages.debian.org/stable/fbpanel).

Zamieszczam przykłądowy plik konfiguracyjny [`~/.config/fbpanel/default`](/files/linux-configs/fbpanel).
Wykorzystuje on moje poprawki do *fbpanel*, których [źródła dostępne są w serwisie github](https://github.com/aanatoly/fbpanel/pulls/rpaciorek).
W serwisie tym dostępny jest też [mój fork fbpanel](https://github.com/rpaciorek/fbpanel/), zawierający te poprawki.
