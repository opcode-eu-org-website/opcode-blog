---
layout: post
title: Własny dbus
author: Robert Paciorek
tags:
- debian
- dbus
---

W celu odizolowania środowiska uruchomieniowego gier i aplikacji windowsowych z nimi związanych oraz bałaganu z nim związanego (jak chociażby biblioteki 32 bitowe) korzystam z rozwiązania chroot opartego o przestrzenie nazw opisanego w [bwrap wewnątrz chroot, czyli Steam w chroot](/2025/04/25/bwrap_inside_chroot.html).

Niekiedy jednak przydatna jest możliwość wywołania akcji na głównym systemie z programu działającego w takiem środowisku (np. uruchomienia gry bezpośrednio z Playnite, która ma działać w innym prefizie wine).
Można to uzyskać z wykorzystaniem *D-Bus*, a dokładniej jego portalu *OpenURI* (to pozwala także na bezproblemowe wychodzenie z wine / proton / umu).

W tym celu:

1. wszystkim programom uruchamianym w tym chroot przekazywany jest niestandardowy adres dbus (porównaj `DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$UID/games_chroot_dbus.sock"` w [games_chroot.sh](/files/wine/games_chroot.sh)
2. z wykorzystaniem systemd na poziomie użytkownika uruchamiany są:
	1. dedykowany serwer dbus obsługujący ten adres – [custom-dbus.service](/files/wine/custom-dbus.service) w `~/.config/systemd/user/`
	2. dedykowany portal  – [custom-portal.service](/files/wine/custom-portal.service) w `~/.config/systemd/user/`
3. skrypt [`~/.bin/custom-portal.py`](/files/wine/custom-portal.py) (odpalany przez `custom-portal.service`) zajmujący się obsługą żądań *OpenURI* pochodzących z chroot, także tych pochodzących z wine.

Skrypt `custom-portal.py` podejmuje niestandardowe działania gdy host w otwieranym URL jest `RUN_GAME` (uruchomienie skryptu odpalającego grę) lub `OPEN_DIR` (otwarcie katalogu w dolpin).
Lepszym rozwiązaniem byłoby użycie niestandardowych prefixów protokołów, ale miało to problemy z działaniem w Playnite pod umu).
Pozostałe adresy URL http i https otwierane są z użyciem prywatnego okna Firefoxa.
