---
layout: post
title: Konfiguracja poinstalacyjna Debian Bullseye
author: Robert Paciorek
tags:
- debian
- kde
---

Aktualizacja dla wpisu [Konfiguracja poinstalacyjna Debian Buster](/2020/07/01/buster-post-install.html) w związku z nową wersją stable.

### Aktualizacje

* nowa wersja [skryptu służącego do wyboru i instalacji pakietów](/files/bullseye-post-install.sh)
	* gEDA wyleciało ze stable, pora na migrację do *lepton-eda*
	* trochę innych zmian związanych z końcem życia niektórych projektów, usunięciem pakietów ze stable

### Obejścia błędów

* F4 w *konqueror* nie otwiera terminala w bieżącym katalogu (tylko w domowym)
	<!--* [rozwiązanie problemu na forum KDE](https://forum.kde.org/viewtopic.php?f=18&t=170599#p449680)-->
	* utworzyć plik *.desktop* typu `Application` (np. `~/.local/share/applications/xterm-dir.desktop`) uruchamiający wybrany emulator terminala i skojarzony z typem `inode/directory`:
	<pre>
[Desktop Entry]
Name=xterm
GenericName=Open in xterm
Comment=Open directory in xterm
Icon=utilities-terminal
InitialPreference=8
MimeType=inode/directory;
Exec=cd %f; xterm
Type=Application
	</pre>
	* po restarcie konquerora w menu open dla katalogów powinna być opcja *Open in xterm*
	* można do niej przypisać skrót klawiaturowy (np. F4) poprzez *Settings* → *Configure Keyboard Shortcuts* i odnajdując ciąg podany w atrybucie `Name=` pliku *.desktop* (w przykładzie `xterm`)
* brakujące ikony w kolourpaint
	* ma to miejsce jeżeli używamy zestawu ikon Oxygen a nie Breeze
	* rozwiązaniem jest przekopiowanie brakujących ikon z `/usr/share/kolourpaint/icons/hicolor/22x22/actions/` do `/usr/share/icons/oxygen/base/22x22/actions/` i wywołanie polecenia `update-icon-caches /usr/share/icons/oxygen` (w razie potrzeby można zapewne użyć także ikon o innych rozmiarach niż 22x22 podane w przykładzie)
* ginący kursor w Kate
	* może zdarzać się że po użyciu opcji znajdź lub zastąp w edytorze Kate kursor przestaje być widoczny nad paskiem przewijania i tytułami kart, obejściem jest otwarcie okienka wyszukiwania z paska narzędzi lub menu (a nie skrótu klawiaturowego), następnie można już normalnie używać skrótów
