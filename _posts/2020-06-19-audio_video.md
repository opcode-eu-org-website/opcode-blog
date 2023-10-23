---
layout: post
title: Obróbka Audio-Video
author: Robert Paciorek
tags:
- debian
- multimedia
---

Różnego rodzaju luźne zapiski związane z obróbką audio-video.


## ffmpeg – łączenie i dzielenie plików

Taka sama (lub bardzo podobna) składnia jak w *ffmpeg* działa także w *avconv*.

### wycinanie fragmentu pliku video

	ffmpeg -ss '1:13' -t 22 -i INPUT.mp4 -codec copy OUT.mp4

lub

	ffmpeg -ss '1:13' -to '1:35' -i INPUT.mp4 -codec copy OUT.mp4


`-ss` określa początek wycinanego fragmentu (w tym przykładzie 1 minuta i 13 sekund),
`-t` określa długość wycinanego fragmentu (w tym przykładzie 22 sekundy),
`-to` określa koniec wycinanego fragmentu (w tym przykładzie 2 minuta i 35 sekund)


### łączenie plików video

	ffmpeg -i 'concat:PART1.mp4|PART2.mp4|PART3.mp4' -c copy OUT.mp4

lub w oparciu o listę plików do połączenia w postaci pliku:

	echo "file PART1.mp4" > aa.txt
	echo "file PART2.mp4" >> aa.txt
	echo "file PART3.mp4" >> aa.txt
	ffmpeg -f concat -i aa.txt -c copy  OUT.mp4

(uwaga: wersja z wykazem plików do połączenia w pliku, radzi sobie z większą ilością przypadków, m.in. z sytuacjami gdy na skutek pierwszego wariantu plik wynikowy zawiera dane tylko z pierwszego z plików)


## ffmpeg – ścieżka audio

### wyciągnięcie ścieżki audio
	ffmpeg -i video.mp4 -vn -acodec copy audio.aac

### zastąpienie audio audio
	ffmpeg -i video_with_OLD_audio.mp4 -i NEW_audio.aac -c copy -map 0:v -map 1:a video_with_NEW_audio.mp4

### dodanie dodatkowej ścieżki audio
	ffmpeg -i video_with_OLD_audio.mp4 -i NEW_audio.aac -c copy -map 0:v -map 1:a -map 0:a video_with_NEW_audio.mp4


## ffmpeg – napisy

### dodanie napisów do kontenera mkv

	ffmpeg -i INPUT.mp4 -i INPUT.vtt -c copy OUTPUT.mkv

można także użyć innego formatu napisów (np. `srt` zamiast `vtt`),
jeżeli dodajemy kilka ścieżek napisów należy skorzystać z opcji `-map` (analogicznie jak przy kilku ścieżkach audio), np:

	ffmpeg -i INPUT.mp4 -i INPUT.en.vtt -i INPUT.pl.vtt -map 0 -map 1:0 -map 2:0 -c copy OUTPUT.mkv

można też określić metadane ścieżki (np. język):

	ffmpeg -i INPUT.mp4 -i INPUT.en.vtt -i INPUT.pl.vtt -map 0 -map 1 "-metadata:s:s:0" "language=en" -map 2 "-metadata:s:s:1" "language=pl" -c copy OUTPUT.mkv

### eksport napisów z kontenera mkv

	ffmpeg -i INPUT.mkv -map 0:s:0 OUTPUT.vtt

`0:s:0` określa ścieżkę napisów, jeżeli jest kilka (np. różne języki) można wybrać inną niż zerowa wg. schematu `ID_PLIKU:s:ID_ŚCIEŻKI` (czyli np. `0:s:1`),
można także użyć innego formatu napisów (np. `srt` zamiast `vtt`)


## v4l2loopback – nadawanie do /dev/video0

Po zainstalowaniu i zbudowaniu modułu [v4l2loopback](https://packages.debian.org/stable/v4l2loopback) możliwe jest nadawanie strumienia video tak aby był on dostępny poprzez urządzenia `/dev/video*`.
Pozwala to na transmisję dowolnego wideo do aplikacji obsługujących np. jedynie wejście z kamerek USB.

	sudo modprobe v4l2loopback devices=1 video_nr=3 card_label="Fake Cam"
	ffmpeg -re -i "plik.mp4" -f v4l2 /dev/video3


Możliwe jest także wysyłanie obrazu przez `/dev/video*` przy pomocy tego modułu z OBS.
Najprostszym rozwiązaniem jest wysyłanie obrazu z OBS na tcp i odbieranie go poprzez `ffmpeg -re -i tcp://127.0.0.1:5000?listen -f v4l2 /dev/video3`, jednak wiąże się to z znacznymi opóźnieniami.
Lepszym rozwiązaniem jest użycie pluginu do OBS [obs-v4l2sink](https://github.com/CatxFish/obs-v4l2sink.git).
Działa on poprawnie z OBS 22.0.3 z Debian Buster, niestety jego kompilacja na tej wersji jest dość uciążliwa ze względu na słaby *cmake* w tym projekcie:

* należy zadbać o wskazanie poprawnej ścieżki do plików nagłówkowych `obs-module.h`, `util/config-file.h` i `obs-frontend-api.h`
  (dwa pierwsze znajdują się w `/usr/include/obs` po zainstalowaniu pakietu [libobs-dev](https://packages.debian.org/buster/libobs-dev), trzeci należy pobrać z [repo obs](https://raw.githubusercontent.com/obsproject/obs-studio/master/UI/obs-frontend-api/obs-frontend-api.h) ze względu na [bug](https://github.com/obsproject/obs-studio/issues/2625))
* należy zadbać o wskazanie poprawnej ścieżki do `libobs.so` – w Debian Buster znajduje się on w pakiecie [libobs-dev](https://packages.debian.org/buster/libobs-dev), ale jest instalowany w `/usr/lib/x86_64-linux-gnu/`
* należy umieścić zbudowany plugin w odpowiednim katalogu – `/usr/lib/x86_64-linux-gnu/obs-plugins/` a nie `/usr/lib/obs-plugins/` używanym przez `make install`


## VLC

VLC jest nie tylko uniwersalnym, obsługującym wiele formatów i źródeł odtwarzaczem multimediów,
lecz także bardzo użytecznym narzędziem do wszelkiego rodzaju operacji związanych z sieciowym przesyłaniem strumieni audio-wideo (odbierania, tworzenia, czy też przetwarzania takich stremów),
a także różnego rodzaju lokalnego manipulowania audio i wideo.

### streaming obrazu z kamerki USB po sieci

	vlc 'v4l2:///dev/video0' :input-slave='alsa://hw:2,0' :sout='#transcode{vcodec=mp2v,vb=2000,acodec=mpga,ab=128,channels=2,samplerate=44100,scodec=none}:duplicate{dst=http{mux=ts,dst=:8080/cam1},dst=display}' :live-caching=50 :no-sout-all :sout-keep

odbiór tego strumienia sieciowego możliwy jest także z użyciem VLC:

	vlc http://localhost:8080/cam1 :network-caching=100

### wejście dźwięku z serwera pulseaudio

	vlc pulse://

Konkretne źródło wybierane jest w mikserze *pulseaudio*. Przy odpowiedniej konfiguracji miksera *pulseaudio* pozwala to na przekopiowanie wejścia mikrofonu na głośniki.
Wejścia z *pulseaudio* możemy też użyć w powyższym przykładzie dając `input-slave='pulse://'` zamiast `input-slave='alsa://hw:2,0'`

### konfiguracja zaawansowana – VLM

Bardziej zaawansowana konfiguracja streamingu z użyciem VLC możliwa jest poprzez pliki vlm.
Poniżej znajduje się przykład skryptu generującego taki plik celem utworzenia mozaiki z kilku strumieni wideo.
Obraz taki może być wyświetlony bezpośrednio przez tą instancję VLC lub transkodowany i przesłany przez sieć.

	#!/bin/bash
	
	addRtspHTTPSource() {
		x=$2
		y=$3
		host=$4
		port=$5
		echo new     src$1 broadcast enabled
		echo setup   src$1 input  "rtsp://$host:$port/rtsp_tunnel?&inst=1&rec=0&enableaudio=1&audio_mode=0&rnd=100"
		echo setup   src$1 option rtsp-tcp
		echo setup   src$1 option rtsp-http
		echo setup   src$1 option rtsp-http-port=$port
		echo setup   src$1 output "#duplicate{dst=mosaic-bridge{id=$1,height=360,width=640,x=$x,y=$y},select=video,dst=bridge-out{id=$1},select=audio}"
		echo control src$1 play
	}
	
	addMosaic() {
		echo new     mosaic broadcast enabled
		echo setup   mosaic input TSbg-1280x720.png
		echo control mosaic play
	}
	
	tmpfile=`mktemp`
	addRtspHTTPSource 1 0   0   localhost 8001 >  $tmpfile
	addRtspHTTPSource 2 0   360 localhost 8002 >> $tmpfile
	addMosaic >> $tmpfile
	
	/usr/bin/vlc --sub-filter=mosaic --mosaic-keep-picture --image-duration=-1 --mosaic-width=1280 --mosaic-height=720 --fullscreen --vlm-conf $tmpfile
	
	/bin/rm $tmpfile

### napisy pod filmem

	vlc  --video-filter='croppadd{paddbottom=120}' --sub-margin=-10  $PLIK_VIDEO


## Polecane programy z repozytorium Debiana

Na koniec krótka lista programów związanych z obróbką audio-wideo z repozytorium Debiana, które warto wypróbować a przynajmniej być świadomym ich istnienia 😉.

### obróbka nieliniowa audio

* [audacity](https://packages.debian.org/stable/audacity)
* [kwave](https://packages.debian.org/stable/kwave)
* [rosegarden](https://packages.debian.org/stable/rosegarden) – wielościeżkowy edytor, sekwencer MIDI
* alternatywne propozycje: wavesurfer, ardour, sweep

### obróbka nieliniowa video

* [kdenlive](https://packages.debian.org/stable/kdenlive)
* [openshot-qt](https://packages.debian.org/stable/openshot-qt)
* alternatywne propozycje: pitivi, lives, dvbcut, kino

### obróbka liniowa video (transmisje na żywo)

* [obs-studio](https://packages.debian.org/stable/obs-studio)

### animacja

* [blender](https://packages.debian.org/stable/blender) – animacja i modelowanie 3D
* gimp + [gimp-gap](https://packages.debian.org/stable/gimp-gap) – animacja 2D

### odtwarzacze multimedialne

* [vlc](https://packages.debian.org/stable/vlc) – nie tylko odtwarzacz, ale także narzędzie do streamowania i konwersji
* [mpv](https://packages.debian.org/stable/mpv)
* [audacious](https://packages.debian.org/stable/audacious) – odtwarzacz audio potrafiący odtwarzać ścieżkę audio z plików wideo
* alternatywne propozycje: mplayer

### narzędzia

* [ffmpeg](https://packages.debian.org/stable/ffmpeg)
* [mencoder](https://packages.debian.org/stable/mencoder)
* [sox](https://packages.debian.org/stable/sox)
* [ogmtools](https://packages.debian.org/stable/ogmtools)
* [mjpegtools](https://packages.debian.org/stable/mjpegtools)
* [timidity](https://packages.debian.org/stable/timidity) – konwerter i odtwarzacz MIDI
* [subtitleeditor](https://packages.debian.org/stable/subtitleeditor) – edytor napisów
* alternatywne propozycje: avconv (fork ffmpeg używany w niektórych, starszych wersjach Debiana)
