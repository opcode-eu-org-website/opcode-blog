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

# logujemy do pliku w /tmp
exec >>/tmp/openbox-${USER}${DISPLAY}-autostart.log 2>&1

# jeżeli odpalone nie przy pomocy basha execujemy się na basha
if [ -z "$BASH_VERSION" ]; then
	echo "exec to /bin/bash"
	exec /bin/bash $HOME/.config/openbox/autostart.sh
fi


# wczytanie .bashrc
[ -f ~/.bashrc ] && PS1="" . ~/.bashrc

# wczytanie .Xdefaults
[ -f ~/.Xdefaults ] && xrdb -merge ~/.Xdefaults

# ustawienie źródła wyglądu aplikacji Qt
export QT_QPA_PLATFORMTHEME=qt5ct


# ustawienie mapy klawiatury
setxkbmap -option "kpdl:dot" pl

# włączenie numlock
python3 -c 'from ctypes import *; X11 = cdll.LoadLibrary("libX11.so.6"); X11.XOpenDisplay.restype = c_void_p; display = X11.XOpenDisplay(None); X11.XkbLockModifiers(c_void_p(display), c_uint(0x0100), c_uint(16), c_uint(16)); X11.XCloseDisplay(c_void_p(display))';

# nielimitowany dostep do X serwera z localhosta (dla schroot)
xhost +localhost


# włączenie lokalnej konfiguracji
# w dalszej częsci używane zmienne z tego pliku:
#   WALLPAPER_PATH    - jeżeli niepusta, używa jako ścieżki do pliku z tapetą
#   FBPANEL_PATH      - jeżeli niepusta, używa jako ścieżki fbpanel
#   DONT_RUN_XCOMPMGR - jeżeli ustawiona na true, nie startuje xcompmgr
#   DONT_RUN_DEFAPPS  - jeżeli ustawiona na true, nie startuje aplikacji określonych przez DEFAPPS (domyślnie claws-mail, psi-plus i linphone)
#   DEFAPPS           - umożliwia zmianę listy uruchamianych domyślnie aplikacji (gdy DONT_RUN_DEFAPPS != true)
if [ -f "$HOME/.config/openbox/autostart-local.sh" ]; then
        . "$HOME/.config/openbox/autostart-local.sh"
fi


if which xcompmgr && [ "$DONT_RUN_XCOMPMGR" != "true" ] ; then
	xcompmgr -c &
fi

if [ "$DONT_RUN_DEFAPPS" != "true" ] ; then
	for a in ${DEFAPPS:-claws-mail psi-plus linphone}; do
		$a &
	done
	
	# funkcja wyszukujaca okna o podanych parametrach
	# $1 - regexp dla WM_CLASS, $2 - regexp dla calej linii
	win_find() {
		wmctrl -lxp | awk '$4 ~ "'"$1"'" && $0 ~ "'"$2"'" {print $1}';
	}
	
	# funkcje zamykająca (ukrywająca w tray'u), minimalizująca, maksymalizująca okna
	win_close() {
		[ $1 != "" ] && wmctrl -ic $1
	}
	win_hide() {
		[ $1 != "" ] && wmctrl -b add,hidden -ir $1
	}
	win_maximize() {
		[ $1 != "" ] && wmctrl -b add,maximized_vert,maximized_horz -ir $1
	}
	
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
	( win_close `win_wait 0.2 44 'linphone[.]Linphone' 'Linphone$'`; ) &
	
	# zminimalizuj okno pokoi konferencyjnych i rozmów Psi
	( win_hide `win_wait 0.2 44 'tabs[.]psi'`; ) &
	
	# zmaksymalizuj i ukryj Claws-mail
	( win=`win_wait 0.2 44 'claws-mail.Claws-mail' 'Claws Mail'`; win_maximize $win; win_close $win; ) &
fi

# ustaw tapetę
[ "$WALLPAPER_PATH" != "" ] && feh --bg-fill $WALLPAPER_PATH &

# start panel
LANG=C.UTF8 LC_TIME=en_DK.UTF-8 TZ=Europe/Warsaw lxpanel &

# start clipboard manager
(
	sleep 1.3
	parcellite
) &
(
	sleep 3.0
	if ! ps x | grep parcellite; then
		echo parcellite try again
		sleep 1.7
		parcellite
	fi
) &
