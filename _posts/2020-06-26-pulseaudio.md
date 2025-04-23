---
layout: post
title: PulseAudio
author: Robert Paciorek
tags:
- debian
- multimedia
updated: 2025-04-23
---

## Narzedzia

* `pavucontrol` - graficzne narzędzie kontrolujące mikser, pozwala na regulację głośności, wybór urządzeń wejściowych, wyjściowych, itd.
* `pactl` - narzędzie linii poleceń pozwalające na operowanie mikserem oraz uzyskiwanie informacji o stanie PulseAudio, przykłady użycia:
	* `pactl list cards; pactl list sinks`
	* `pactl -- set-sink-volume alsa_output.pci-0000_00_14.2.analog-surround-51 105% 70% 85% 70% 70% 70%`


## Daemon użytkownika czy systemowy

Domyślnie PulseAudio uruchamiany jest w ramach sesji danego użytkownika.
Rozwiązanie takie może być kłopotliwe w sytuacji gdy korzystamy z programów odpalanych na prawach innego użytkownika (np. poprzez sudo).
Możliwe są dwa rozwiązania - skonfigurowanie deamonów tych dodatkowych użytkowników jako klientów naszego i pozwolenie naszemu na przyjmowanie połączeń od nich lub uruchomienie PulseAudio jako usługi ogólnosystemowej (dla wszystkich użytkowników w grupie *pulse-access*).

Aby uruchomić PulseAudio jako usługę ogólnosystemową należy:

1. zablokować mozliwość startu usług użytkowników: `systemctl --global mask pulseaudio.service pulseaudio.socket`
2. utworzyć plik usługi systemowej `/etc/systemd/system/pulseaudio.service` o następujacej treści:
<pre>
[Unit]
Description=PulseAudio system server
[Service]
Type=notify
ExecStart=pulseaudio --disallow-exit --disallow-module-loading --system --realtime --log-target=journal
[Install]
WantedBy=multi-user.target
</pre>
3. włączyć usługę systemową: `systemctl --system enable pulseaudio.service`

Użycie w roli deamona ogólnosystemowego nie jest zalecane przez twórców PulseAudio.
Więcej na ten temat w [dokumentacji PulseAudio](https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/SystemWide/).


## Status „unplugged” podłączonego mikrofonu

Jeżeli `pavucontrol` pokazuje nasz mikrofon jako *unplugged* pomimo że jest on podłączony i po jego wybraniu w mikserze działa prawidłowo to i tak w niektórych aplikacjach (np. chromium) nie będzie on widoczny.
Analogiczny problem może dotyczyć także słuchawek / głośników.
Rozwiązaniem tego problemu (którego przyczyną może być np. źle działająca detekcja włożenia wtyczki do gniazda mikrofonu), w przypadku kart dźwiękowych opartych o moduł *snd-hda-intel* jest zastosowanie odpowiednich *hints* dla tego modułu.
Można to zrobić poprzez:

	echo "options snd-hda-intel patch=hda-jack-detect.fw" > /etc/modprobe.d/hda-jack-detect.conf
	echo '[codec]' > /lib/firmware/hda-jack-detect.fw
	awk -F ': ' '$1=="Vendor Id" {v=$2} $1=="Subsystem Id" {s=$2} $1=="Address" {a=$2} END {print(v,s,a)}' /proc/asound/card0/codec* >> /lib/firmware/hda-jack-detect.fw
	echo '[hints]' >> /lib/firmware/hda-jack-detect.fw
	echo 'jack_detect=no' >> /lib/firmware/hda-jack-detect.fw

Operowanie tymi *hints* jest też możliwe poprzez sysfs np.:

	echo 'jack_detect=false' > /sys/class/sound/card0/hwC0D0/hints
	echo '1' > /sys/class/sound/card0/hwC0D0/reconfig

jednak wymaga wtedy zatrzymywania i ponownego uruchamiania usług związanych z audio i nie zawsze działa prawidłowo.

Można to uzyskać poprzez dodanie odpowiednich poleceń do `/etc/systemd/system/pulseaudio.service`:

	# no plug detection on analog card
	ExecStartPre=/bin/bash -c 'echo jack_detect=no > /sys/class/sound/card2/hwC2D0/hints'
	ExecStartPre=/bin/bash -c 'echo 1 >  /sys/class/sound/card2/hwC2D0/reconfig'


## Wyjścia HDMI/DP jako osobne urządzenia

PulseAudio pozwala na utworzenie z osobnych wyjść HDMI/DP osobnych urządzeń audio co pozwala m.in. na łatwe przełączanie używanego wyjścia. W tym celu należy do konfiguracji pulse audio (np. w `/etc/pulse/system.pa.d/` dla daemona ogólno systemowego lub w `/etc/pulse/default.pa.d/` dla domyślnych ustawień daemona użytkownika) dodać:

	set-card-profile alsa_card.pci-0000_03_00.1 off
	# ^ potrzebne aby dodanie wirtualnych urządzeń (load-module module-alsa-sink) działało
	load-module module-alsa-sink device=hw:0,3 sink_name=radeon-dp-0 sink_properties="device.description='Digital Audio DP-0'" channel_map=left,right
	load-module module-alsa-sink device=hw:0,9 sink_name=radeon-hdmi-0 sink_properties="device.description='Digital Audio HDMI-0'" channel_map=left,right


## Ustawienie domyślnego profilu oraz zmiana nazwy urządzenia

Konfiguracja w `/etc/pulse/system.pa.d/` / `/etc/pulse/default.pa.d/` pozwala także np. na ustawienie domyślnego profilu karty dźwiękowej na 5.1 z wejściem stereo i zmianę nazwy tego urządzenia poprzez:

	set-card-profile alsa_card.pci-0000_73_00.6 output:analog-surround-51+input:analog-stereo
	update-sink-proplist alsa_card.pci-0000_73_00.6 device.description="Analog Audio Surround 5.1"

## Słuchawki i 5.1 w jednym profilu

Możliwe jest pozowlenie na korzystanie z wyjścia słuchawkowego bez potrzeby przełączania się między 5.1 a stereo (ale w takiej konfiguracji na słuchawakach nie będą dostępne wogóle inne kanały niż przednie). W tym celu należy utworzyć nowy profil lub zmodyfikować profil 5.1 w `/usr/share/pulseaudio/alsa-mixer/profile-sets/default.conf`:

	--- /usr/share/pulseaudio/alsa-mixer/profile-sets/default.conf.org	2025-04-19 16:27:23.717456166 +0000
	+++ /usr/share/pulseaudio/alsa-mixer/profile-sets/default.conf.new	2025-04-19 16:09:47.858124577 +0000
	@@ -165,7 +165,7 @@
	[Mapping analog-surround-51]
	device-strings = surround51:%f
	channel-map = front-left,front-right,rear-left,rear-right,front-center,lfe
	-paths-output = analog-output analog-output-lineout analog-output-speaker
	+paths-output = analog-output analog-output-lineout analog-output-speaker analog-output-headphones analog-output-headphones-2
	priority = 13
	direction = output


## Więcej informacji i możliwości:

* bardzo użyteczny wpis na Wiki Arch: https://wiki.archlinux.org/title/PulseAudio/Examples
* opis modułów PulseAudio: https://www.freedesktop.org/wiki/Software/PulseAudio/Documentation/User/Modules/
