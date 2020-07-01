---
layout: post
title: Zaginione ikony w aplikacjach KDE
author: Robert Paciorek
tags:
- debian
- kde
- x11
---

Jeżeli nie używamy żadnego dużego środowiska graficznego, ale zdecydowaliśmy się na korzystanie z jakiś aplikacji KDE (np. kate),
to po ich zainstalowaniu i uruchomieniu możemy często spotkać się z problemem braku jakichkolwiek ikon.
W przypadku wspomnianego edytora `kate` jest to szczególnie uciążliwe w formularzu "wyszukaj i zastąp".

Problem możemy rozwiązać na co najmniej dwa sposoby:

* ustawiając zmienną środowiskową XDG_CURRENT_DESKTOP
* instalując narzędzia konfiguracji wyglądu qt5 i stosowne elementy graficzne oraz ustawiając zmienną QT_QPA_PLATFORMTHEME


## XDG_CURRENT_DESKTOP

`XDG_CURRENT_DESKTOP` jest zmienną środowiskową określającą aktualnie używane środowisko graficzne (desktop environment).
Ustawienie jej na wartość związaną z jakimś popularnym środowiskiem (np. `GNOME`) oszuka aplikacje używające tej zmiennej
i sprawi że będą próbowały działać tak jakby były uruchomione w tym środowisku.

Aplikacje KDE uwzględniają tą zmienną w swoim działaniu, zatem ustawienie jej na `GNOME` spowodują ze będą zachowywać się jakby
działały w tym środowisku, efektem tego będzie chęć stosowania ikon związanych z biblioteką GTK na której oparty jest Gnome.

Jeżeli w Debianie posiadamy zainstalowaną bibliotekę GTK (bez znaczenia czy w wersji 2, 3 czy nawet 4) to posiadamy też
podstaw zestaw ikon (jest zależnością pakietów libgtk2.0-0, libgtk-3-0 i libgtk-4-0), zatem jest bardzo duże prawdopodobieństwo że go mamy.

W efekcie tego:

	export XDG_CURRENT_DESKTOP=GNOME
	kate

spowoduje uruchomienie edytora `kate` z ikonami zainstalowanymi wraz z biblioteką GTK (lub skonfigurowanymi dla niej).

Jako że jest to metoda oparta na oszustwie może ona spowodować dziwne zachowanie się niektórych aplikacji i raczej należy ją odradzać.


## QT_QPA_PLATFORMTHEME

`QT_QPA_PLATFORMTHEME` jest zmienną środowiskową określającą pożądany motyw dla aplikacji opartych na bibliotece Qt.


### gnome

Jeżeli problem braku braku ikon rozwiązywało ustawienie `XDG_CURRENT_DESKTOP=GNOME` to powinno go rozwiązać także ustawienie

	export QT_QPA_PLATFORMTHEME=gnome
	kate

(uwaga na wielkość liter – tym razem gnome jest małymi literami).
To rozwiązanie działa analogicznie jak tamto – opiera się na tym iż najprawdopodobniej mamy zainstalowaną bibliotekę GTK, a wraz z nią potrzebne ikony.
Jednak w odróżnieniu od tamtego:

* oddziałuje tylko na aplikacje Qt
* nie jest oszustwem (określamy że chcemy aby aplikacje wyglądały jak w Gnome, a nie że mamy uruchomione to środowisko),
  przez co nie niesie ze sobą ryzyka dziwnych zachowań


### qt5ct

Zainstalowanie aplikacji qt5ct i ustawienie zmiennej `QT_QPA_PLATFORMTHEME` na `qt5ct` pozwala na konfigurowanie wyglądu aplikacji opartych na Qt przy jej pomocy:

	export QT_QPA_PLATFORMTHEME=qt5ct
	kate

Można także doinstalować zestaw ikon `oxygen-icon-theme`, dzięki czemu po jego wybraniu aplikacje Qt będą wyglądały jak w KDE.


### pakiety qt5-style-plugins i qt5-gtk-platformtheme

Pakiet qt5-style-plugins dostarcza kilka dodatkowych stylów możliwych do wybrania w qt5ct
oraz plugin pozwalający na upodobnienie do wyglądu skonfigurowanego dla aplikacji opartych na bibliotece gtk2 poprzez ustawienie `QT_QPA_PLATFORMTHEME=gtk2`.

Natomiast pakiet qt5-gtk-platformtheme dostarcza plugin pozwalający na upodobnienie do wyglądu aplikacji opartych na bibliotece gtk3 poprzez ustawienie `QT_QPA_PLATFORMTHEME=gtk3`.
