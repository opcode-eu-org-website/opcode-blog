#!/bin/bash
## 
## Copyright (c) 2015-2020 Robert Ryszard Paciorek <rrp@opcode.eu.org>
## 
## MIT License
## 
## Permission is hereby granted, free of charge, to any person obtaining a copy
## of this software and associated documentation files (the "Software"), to deal
## in the Software without restriction, including without limitation the rights
## to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
## copies of the Software, and to permit persons to whom the Software is
## furnished to do so, subject to the following conditions:
## 
## The above copyright notice and this permission notice shall be included in all
## copies or substantial portions of the Software.
## 
## THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
## IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
## FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
## AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
## LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
## OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
## SOFTWARE.

# wczytanie .bashrc
[ -f ~/.bashrc ] && . ~/.bashrc

# wczytanie .Xdefaults
[ -f ~/.Xdefaults ] && xrdb -merge ~/.Xdefaults

# ustawienie mapy klawiatury
setxkbmap -option "kpdl:dot" pl

# nielimitowany dostep do X serwera z localhosta (dla schroot)
xhost +localhost

# włączenie lokalnej konfiguracji
# w dalszej częsci używane zmienne z tego pliku:
#   WALLPAPER_PATH    - jeżeli niepusta, używa jako ścieżki do pliku z tapetą
#   FBPANEL_PATH      - jeżeli niepusta, używa jako ścieżki fbpanel
#   DONT_RUN_XCOMPMGR - jeżeli ustawiona na true, nie startuje xcompmgr
#   DONT_RUN_DEFAPPS  - jeżeli ustawiona na true, nie startuje claws-mail, psi-plus i linphone
if [ -f "$HOME/.config/openbox/autostart-local.sh" ]; then
        . "$HOME/.config/openbox/autostart-local.sh"
fi

if which xcompmgr && [ "$DONT_RUN_XCOMPMGR" != "true" ] ; then
	xcompmgr -c &
fi

# start fbpanel
(
	err_cnt=0
	while [ $err_cnt -lt 5 ]; do
		${FBPANEL_PATH-fbpanel}
		if [ $? -eq 0 ]; then
			err_cnt=0
		else
			err_cnt=$(( $err_cnt + 1 ))
		fi
		echo "fbpanel restart error count: $err_cnt"
		sleep 1;
	done
) > /tmp/fbpanel-${USERNAME}${DISPLAY}.log 2>&1 &

if [ "$DONT_RUN_DEFAPPS" != "true" ] ; then
	claws-mail &
	psi-plus &
	linphone &

	# funkcja wyszukujaca okna o podanych parametrach
	# $1 - regexp dla WM_CLASS, $2 - regexp dla calej linii
	win_find() {
		wmctrl -lxp | awk '$4 ~ "'"$1"'" && $0 ~ "'"$2"'" {print $1}';
	}

	# funkcje zamykająca (ukrywająca w tray'u) oraz minimalizująca wyszukane okna
	# argumenty jak dla win_find
	win_close() {
		for win in `win_find "$1" "$2"`; do
			 [ "$win" != "" ] && wmctrl -ic $win
		done
	}
	win_hide() {
		for win in `win_find "$1" "$2"`; do
			 [ "$win" != "" ] && wmctrl -b add,hidden -ir $win
		done
	}
	# PRZYKAŁD UŻYCIA (minimalizacja okien programów komunikacyjnych do tray'a):
	# win_close '(claws-mail[.]Claws-mail)|(linphone[.]Linphone)|(main[.]psi)' \
	#           '(- Claws Mail 3[.]8[.]1)|(Linphone)|(Psi[+])$'

	# funkcja czekająca na pojawienie sie okna i zwracająca jego identyfikator
	# $1 - czas kroku [s], $2 - liczba krokow
	# $3 - regexp dla WM_CLASS, $4 - regexp dla calej linii
	win_wait() {
		count=0; win=""
	        while [ "$win" = "" -a $count -lt $2 ]; do
        	        count=$(( $count + 1 ))
                	win=`win_find "$3" "$4"`
	                sleep $1
        	done
		echo $win
	}

	# funkcje czekające na wskazane okno, a następnie
	# zamykające (ukrywająca w tray'u) oraz minimalizujące je
	# argumenty jak dla win_wait
	win_wait_and_close() {
		win=`win_wait $@`
        	if [ "$win" != "" ]; then
			wmctrl -ic $win
	        fi
	}
	win_wait_and_hide() {
		win=`win_wait $@`
        	if [ "$win" != "" ]; then
			wmctrl -b add,hidden -ir $win
	        fi
	}

	# ukryj okno linphone w tray'u na starcie
	# (nie ma on takiej opcji, ale wystarczy wysłać mu close)
	( win_wait_and_close 1 20 'linphone[.]Linphone' 'Linphone$'; ) &

	# zminimalizuj okno pokoi konferencyjnych i rozmów Psi
	( win_wait_and_hide 1 20 'tabs[.]psi'; ) &
fi

# ustaw tapetę
[ "$WALLPAPER_PATH" != "" ] && feh --bg-fill $WALLPAPER_PATH &
