---
layout: post
title: LXPanel plus Parcellite jako zamiennik dla zmodowanego fbpanel
author: Robert Paciorek
tags:
- debian
- x11
---

Jest to pewnego rodzaju aktualizacja dla wpisu [Konfiguracja poinstalacyjna Debian Buster](/2020/07/01/buster-post-install.html) w związku z usunięciem fbpanel z Debiana z wydaniem Bookworm.

[**LXPanel**](https://packages.debian.org/stable/lxpanel) jest panelem (paskiem zadań) wspierającym m.in.:

* menu startowe
* przyciski szybkiego uruchamiania
* przełączanie pulpitów pokazujące ich miniatury
* klasyczną listę okien z możliwością wysyłania okna na inny pulpit (możliwe jest także konfigurowanie wersji typu "tylko ikony", "grupowanie okien aplikacji", etc)
* monitoring obciążenia CPU i zajętości RAM
* konfigurowalny zegar

Przykładowy plik konfiguracyjny: [`lxpanel`](/files/linux-configs/lxpanel).

Zaktualizowany został także [`autostart.sh`](/files/linux-configs/openbox-autostart.sh) aby zapewnić uruchamianie obu programów i konfigurację zegara w LXPanel (warszawska strefa czasowa, język angielski, poniedziałek jako pierwszy dzień tygodnia). Do poprawnego działania tej konfiguracji wymagane jest posiadanie locali `en_DK.UTF8`.

Dodatkowo konfiguracja dla Pythona w roli kalkulatora uruchamianego z ikony na panelu: [`lxpanel.calculator.desktop`](/files/linux-configs/lxpanel.calculator.desktop) i [`pyCalc-Autostart.py`](/files/linux-configs/pyCalc-Autostart.py).

[**Parcellite**](https://packages.debian.org/stable/parcellite) jest managerem schowka wspierającym m.in.:

* obsługę schowka Ctrl+C/V oraz zaznaczenia (kółko myszy) jako niezależnych schowków (lub uwspólnionych, w zależności od konfiguracji)
* historię zawartości z wyróżnianiem aktualnej zawartości obu schowków na osobne sposoby
* stałe (przypięte) pozycje historii

Przykładowy plik konfiguracyjny: [`parcelliterc`](/files/linux-configs/parcelliterc)
