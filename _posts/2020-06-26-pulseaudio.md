---
layout: post
title: PulseAudio
author: Robert Paciorek
tags:
- debian
- multimedia
---

## Narzedzia

* `pavucontrol` - graficzne narzędzie kontrolujące mikser, pozwala na regulację głośności, wybór urządzeń wejściowych, wyjściowych, itd.
* `pactl` - narzędzie linii poleceń pozwalające na operowanie mikserem oraz uzyskiwanie informacji o stanie PulseAudio, przykłady użycia:
	* `pactl list cards; pactl list sinks`
	* `pactl -- set-sink-volume alsa_output.pci-0000_00_14.2.analog-surround-51 105% 70% 85% 70% 70% 70%`


## Deamon użytkownika czy systemowy

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

Operowanie tymi *hints* jest też teoretycznie możliwe poprzez sysfs np.:

	echo 'jack_detect=false' > /sys/class/sound/card0/hwC0D0/hints
	echo '1' > /sys/class/sound/card0/hwC0D0/reconfig

jednak wymaga wtedy zatrzymywania i ponownego uruchamiania usług związanych z audio i nie zawsze działa prawidłowo.
