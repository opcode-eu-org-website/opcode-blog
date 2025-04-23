---
layout: post
title: HDMI pin 18, czyli udajemy że monitora nie ma, a potem że jest
author: Robert Paciorek
tags:
- debian
- multimedia
- elektronika
---

Detekcja (hotplug) HDMi nie uwzględnia faktu czy podłączony monitor jest zasilany czy nie. W efekcie czego nawet fizycznie wyłączony monitor może stać się domyślnym jeżeli jest podpięty do wyjścia z odpowiednio wysokim priorytetem. Nie jest to problemem na poziomie systemu operacyjnego gdzie możemy dość swobodnie konfigurować jaki obraz ma być na którym wyjściu i które ma być uważane za główne przez środowisko graficzne (np. z użyciem `xrandr`). Problem pojawia się na etapie UEFI gdy BIOS nie pozwala na wybór domyślnego wyjścia a z jakiś względów nie możemy podpiąć podstawowego monitora do priorytetowego wyjścia (np. problem na styku przejściówka DP→HDMI i switch HDMI gdy podstawowym wyjściem jest DP).

Detekcja odłączonego od zasilania monitora jest możliwa dzięki podawaniu do niego zasilania 5V poprzez pin 18 złącza HDMI z karty graficznej (źródła sygnału), które jest wykorzystywane w detekcji hotplug (HPD) i do odczytu EDID poprzez DDC. Jeżeli monitor który ma być dodatkowym podaje zasilanie na pin 18 HDMI (wg ChatGPT jest to niezgodne ze specyfikacją i nie powinno się polegać na takim zasilaniu) to można spróbować fizycznie rozłączyć pin 18 aby uniknąć detekcji dopóki nie zostanie załączone zasilanie monitora.

Podejście takie upośledza funkcjonowanie HDP i wymaga programowego wymuszenia detekcji monitora. Może to być zrealizowane poprzez `echo on > /sys/class/drm/card0-DP-1/status` (gdzie `card0-DP-1` określa kartę graficzną i wyjście do której podłaczony jest monitor). Polecenie to powinno być wykonane tuż przed lub po włączeniu monitora, gdyż w przeciwnym razie taki dostępny monitor bez danych EDID będzie problematyczny np. w `xrandr`. Następnie należy włączyć monitor w X11 z użyciem `xrandr`. Całość może być realizowana skryptem:


	echo on > /sys/class/drm/card0-DP-1/status
	
	# FIZYCZNE WŁĄCZENIE ZASILANIA DLA MONITORA
	
	sudo /bin/systemctl restart pulseaudio.service
	xrandr --output DisplayPort-0 --auto; xrandr --output DisplayPort-0 --same-as HDMI-A-0


Konieczność restartu PulseAudio wynika z potrzeby wymuszenia odświeżenia stanu podłączenia kabli do wyjść DP. Realizowane to jest przez `echo 1 >  /sys/class/sound/card0/hwC0D0/reconfig` (gdzie `card0/hwC0D0` związne jest z kartą obsługującą to wyjście). Wykonanie tej komendy wymaga wyłączenia PulseAudio, w związku z tym najwygodniej jest ją umieścić w `/etc/systemd/system/pulseaudio.service`:

	# refresh digital (HDMI/DP) before (re)start
	ExecStartPre=/bin/bash -c 'echo 1 >  /sys/class/sound/card0/hwC0D0/reconfig'

Taka konfiguracja z jakiś powodów prowadzi do wyłączenia nieaktywnego kanału audio (najprawdopodobniej po stronie monitora) i niemożliwości jego ponownego włączenia bez nowego handshake HDMI (wywołanego np. wymuszeniem przełączenia monitora na inne wejście / wyszukania tam, nawet nieistniejącego, sygnału). Można to uzyskać poleceniem `xset dpms force off; sleep 5; xset dpms force on` (`xrandr --output DisplayPort-0 --off; sleep 5;  xrandr --output DisplayPort-0 --auto` powinno zadziałać podobnie.). Ważny jest sleep w tych poleceniach (czas potrzeby żeby monitor zaczął szukać innego sygnału) oraz fakt odtwarzania audio na tym wyjściu w trakcie ich wykonywania lub zaraz po.

Aby wyeliminować ten problem zaniku audio można dodać ciągłe generowanie sygnału na tym wyjściu np. dodając w konfiguracji PulseAudio (`/etc/pulse/system.pa.d/` / `/etc/pulse/default.pa.d/`):

	load-module module-sine sink=radeon-dp-0
	# ^ potrzebne do utrzymania w działaniu audio na połączeniu HDMI bez pinu 18tego (5V Power)
	# [powinno być ustawione bardzo cicho (1%) w mikserze

(gdzie `radeon-dp-0` jest wyjściem pulse audio związanym z tym wyjściem DP do którego podłaczony jest dodatkowy monitor z użyciem konwertera DP→HDMI).
