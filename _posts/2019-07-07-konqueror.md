---
layout: post
title: Konqueror
author: Robert Paciorek
tags:
- debian
- kde
- x11
---

Konqueror jest przeglądarką WWW i zaawansowanym menagerem plików dostępnym w środowisku KDE. Może być jednak używany także jako samodzielna aplikacja.

Celem uzyskania pełnej funkcjonalności (włączając w to podglądy plików, rozpakowywanie archiwów, ...) należy zainstalować następujące pakiety (Debian Buster):

	konqueror dolphin kio kate okteta okular konsole ark gwenview kfind
	kde-runtime kde-cli-tools konq-plugins dolphin-plugins kio-extras kio-gopher kdepimlibs-kio-plugins
	kdegraphics-thumbnailers kimageformat-plugins ffmpegthumbs unrar unzip okular-extra-backends

Pakiet kde-runtime jest wymagany głównie ze względu na `kuiserver` obsługujący dialogi z postępami kopiowania, przenoszenia plików.
Jeżeli chcemy używać innego emulatora terminala niż `konsole` możemy zrezygnować z instalacji tego pakietu i utworzyć w ścieżce wyszukiwania plik wykonywalny o nazwie `konsole` uruchamiający nasz ulubiony terminal np.:

	echo "exec /usr/bin/xterm" > /usr/local/bin/konsole; chmod +x /usr/local/bin/konsole


## Skrót uruchamiający nowe okno

(aktualizacja 2025-04-23: w wersji 24.12.0 z Trixie nie ma potrzeby stosowania tego rozwiązania - polecenie `konqueror` otwiera nowe okno)

Aby wpis w menu / ikona uruchamiała zawsze kolejne okno konqueror'a należy uruchamiać go z podanym URLem do otwarcia – np. `konqueror about:blank` zamiast po prostu `konqueror`.
Rozwiązuje to też problem z ponownym uruchamianiem konqueror'a gdy wcześniej został zamknięty.
Aby uniknąć otwierania pustego okna przy odtwarzaniu sesji można zastosować prosty skrypt do jego uruchamiania:

	if ps -C konqueror >& /dev/null; then konqueror about:blank; else konqueror; fi


## Pojedyncze czy podwójne kliknięcie

Opcja ta może być zmieniona z użyciem programu `qt5ct`, o którym więcej informacji w [zaginione ikony w aplikacjach KDE](/2019/04/07/zagionione_ikony_w_kate.html).


## Skojarzenia typów plików

Skojarzenia plików możemy edytować w ustawieniach Konquerora. Dialog ten możemy też wywołać zewnętrznie poprzez: `kcmshell5 filetypes`.


### Dodanie nowej aplikacji

Celem dodania nowej aplikacji obsługującej wiele typów plików można (zamiast pracowicie to wyklikiwać) utworzyć plik `.desktop` w `.local/share/applications/`. Przykładowo jeżeli chcemy mieć możliwość otwarcia dokumentu w nowym oknie edytora Kate możemy utworzyć plik `kate-n.desktop` z następująca treścią:

	[Desktop Entry]
	GenericName=Advanced Text Editor (new window)
	Name=Kate (new window)
	Comment=KDE Advanced Text Editor (new window)
	MimeType=text/plain;
	InitialPreference=8
	Exec=kate -n %U
	Icon=kate
	Type=Application

Pełniejszy opis skłądni na stronach [freedesktop.org](https://specifications.freedesktop.org/desktop-entry-spec/latest/).

### Domyślność aplikacji i modyfikacjia ich kolejności

Wpisy aplikacji `.desktop` zawierają pole `InitialPreference` określające domyślny priorytet danej aplikacji.
Określa to ich kolejność na liście aplikacji do otwarcia danego typu plików oraz determinuje, która z aplikacji będzie używana domyślnie.
Można to modyfikować poprzez dialog skojarzenia typów plików. Zmiany te zapisywane są w pliku `~/.config/mimeapps.list`.
Pełniejszy opis składni na stronach [freedesktop.org](https://specifications.freedesktop.org/mime-apps-spec/mime-apps-spec-1.0.html).

### Typy MIME

Typy mime konfigurowane są w `~/.local/share/mime/packages/`. Pełniejszy opis składni na stronach [freedesktop.org](https://www.freedesktop.org/wiki/Specifications/shared-mime-info-spec/)


## Menu kontekstowe

Konqueror pozwala na dodanie dodatkowych akcji dla poszczególnych typów plików (w taki sposób jak działają akcje "Extract" i "Compress") w tym celu należy utworzyć odpowiedni plik `.desktop` w `~/.local/share/kservices5/ServiceMenus/` (aktualizacja 2025-04-23: dla kde6 w `~/.local/share/kio/servicemenus` oraz wymagane ustawienie prawa wykonywalności na pliku `.desktop`).
Przydatną opcją tego typu jest możliwość tekstowej lub hexalnej edycji plików dowolnego typu. Możemy to uzyskać przy pomocy następującego pliku `any_file_edit.desktop`:

	[Desktop Entry]
	Type=Service
	ServiceTypes=KonqPopupMenu/Plugin
	MimeType=all/allfiles
	Actions=kwrite;gvim;_SEPARATOR_;okteta
	X-KDE-Submenu=Text or Binary Edit
	X-KDE-Priority=TopLevel
	
	[Desktop Action kwrite]
	Exec=kate -n %U
	Name=Kate
	Icon=kate
	
	[Desktop Action gvim]
	Exec=xterm -e vim %f
	Name=Vim Text Editor
	Icon=gvim
	
	[Desktop Action okteta]
	Exec=okteta %f
	Name=Okteta HEX Editor
	Icon=text-x-hex

### Menu "create new"

Możliwe jest też dodanie pozycji do menu pozwalającego na tworzenie nowych plików. W tym celu należy w katalogu `.local/share/templates` utworzyć plik `.desktop` opisujący pozycję tego menu – np. `LaTeX.desktop`:

	[Desktop Entry]
	Name=LaTeX File
	Comment=Enter LaTeX filename:
	Type=Link
	URL=LaTeX.tex
	Icon=text-x-tex

Oraz wskazany w nim plik wzorcowy – w powyższym przykładzie `LaTeX.tex` z zawartością która ma być kopiowana do nowo tworzonego pliku, np.:

	\documentclass[a4paper]{article}
	% \usepackage{}
	\begin{document}
	
	\end{document}


## Uwagi końcowe

Celem wprowadzenia niektórych z opisywanych modyfikacji w życie po utworzeniu stosownych konfigów może być potrzeba wywołania `kbuildsycoca5` i/lub restart Konquerora.
