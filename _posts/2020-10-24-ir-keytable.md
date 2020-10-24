---
layout: post
title: Odbiornik podczerwieni, udev i subsystem lirc vc rc
author: Robert Paciorek
tags:
- debian
- udev
---

Po ostatniej aktualizacji jądra w Debian Buster (dokładniej 4.19+105+deb10u3 -> 4.19+105+deb10u7) przestał funkcjonować poprawnie odbiornik podczerwieni na USB konfigurowany z użyciem `ir-keytable` i `/etc/rc_maps.cfg`.
Przyczyną problemów okazało się nie uruchamianie się akcji udev (/lib/udev/rules.d/60-ir-keytable.rules) związanej z dodaniem urządzenia po jego podłączeniu i odpowiedzialnej za konfigurację tabeli klawiszy.

Co ciekawe akcja wykonuje się poprawnie po ręcznym wyzwoleniu akcji dla podsystemu *rc* poprzez `udevadm trigger --action=add --verbose --subsystem-match=rc`,
a logi udev w trybie debug (`udev_log="debug"` w `/etc/udev/udev.conf`) pokazują że po podłaczeniu urządzenia wyzwalane są m.in. akcje dla subsystemu lirc, ale nie dla systemu rc.

Może niezbyt eleganckim, ale działającym rozwiązaniem problemu jest odpalenie konfiguracji key-mapy w ramach akcji podsystemu lirc. W tym celu można utworzyć plik `/etc/udev/rules.d/60-ir-keytablei-lirc.rules` z zawartością:

	ACTION=="add", SUBSYSTEM=="lirc", RUN+="/etc/rc_maps.sh $name"

oraz plik `/etc/rc_maps.sh` z prawem wykonywalności i zawartością:

	#!/bin/sh
	/usr/bin/ir-keytable -a /etc/rc_maps.cfg -s $(basename $(realpath /sys/class/lirc/$1/device))

Po utworzeniu tych plików, nadaniu prawa wykonywalności dla `/etc/rc_maps.sh` i przeładowaniu reguł udev poprzez `udevadm control --reload-rules` po ponownym podłączeniu odbiornik podczerwieni powinien działać poprawnie (jak wcześniej) i przesyłać klawisze do aplikacji.
