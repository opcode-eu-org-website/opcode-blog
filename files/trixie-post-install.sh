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

pkg__01_BASE0__info="essential"
pkg__01_BASE0__list="bash bsdutils coreutils util-linux findutils diffutils grep sed tar gzip
	debianutils dpkg apt hostname login sysvinit-utils perl-base"
# see `aptitude -F '%p' search '~E'` for full list of essential packages

pkg__01_BASE1__info="base"
pkg__01_BASE1__list="aptitude bsdmainutils cron less rsync vim xxd
	procps psmisc lsof htop iotop strace
	schroot busybox file screen tmux sudo bash-completion
	konwert gpg gpgv gpgsm bzip2 xz-utils p7zip-full
	python3 python3-pip whiptail gawk bc man-db manpages
	pass pwgen  console-setup gpm"

pkg__04_NETBASE__info="network"
pkg__04_NETBASE__list="iproute2 nftables iputils-ping isc-dhcp-client
	net-tools iputils-tracepath bind9-dnsutils mtr-tiny
	ethtool vlan bridge-utils iptables arptables ebtables
	netcat-openbsd ncat socat inetutils-telnet
	wget curl httrack ntpdate debootstrap
	openssh-client openssh-server sshfs sshguard"

pkg__05_NETWIFI__info="wireless network"
pkg__05_NETWIFI__list="wireless-tools wpasupplicant hostapd rfkill"

pkg__06_NETDIAG__info="network diagnostic"
pkg__06_NETDIAG__list="inetutils-traceroute traceroute tcptraceroute
	tcpdump nmap wireshark
	sipcalc ipv6calc
	arping arp-scan ndisc6
	vnstat iftop tcpflow ngrep
	dnstop dnstracer dnswalk"
	# old: paris-traceroute netdiag

pkg__11_HWTOOLS__info="hardware diagnostic"
pkg__11_HWTOOLS__list="sysstat lm-sensors
	pciutils usbutils lsscsi dmidecode
	hdparm sdparm smartmontools
	picocom jpnevulator
	ipmitool pcmciautils"
	# old: hddtemp

pkg__14_FSTOOLS__info="mass storage and file systems"
pkg__14_FSTOOLS__list="lvm2 mdadm dmsetup multipath-tools cryptsetup-bin
	parted fdisk gdisk kpartx testdisk
	e2fsprogs xfsprogs btrfs-progs dosfstools
	nfs-kernel-server
	fuse3"

pkg__15_OTHER__info="system boot and kernel"
pkg__15_OTHER__list="linux-image-amd64 grub-pc os-prober amd64-microcode
	firmware-linux firmware-realtek ir-keytable ntfs-3g"

pkg__30_NOACTION__info=""

pkg__31_DESKTOP__info="X11 desktop enviroment"
pkg__31_DESKTOP__list="xorg slim openbox fbpanel wmctrl xdotool
	feh xcompmgr onboard gexec xterm
	xfce4-notifyd"

pkg__32_DESKTOP_MULTIMEDIA__info="X11 desktop enviroment - multimedia & pdf"
pkg__32_DESKTOP_MULTIMEDIA__list="alsa-utils pavucontrol
	vlc mpv celluloid mplayer xpdf
	vlc-plugin-access-extra vlc-plugin-fluidsynth vlc-plugin-svg"
	# old: pavumeter

pkg__32_DESKTOP_KDE__info="X11 desktop enviroment - konqueror, okular, kate"
pkg__32_DESKTOP_KDE__list="konqueror dolphin kio kate okteta okular konsole konsole-kpart ark gwenview kfind
	kde-runtime konq-plugins dolphin-plugins kio-extras kio-gopher sonnet6-plugins
	kdegraphics-thumbnailers kimageformat-plugins ffmpegthumbs unrar unzip okular-extra-backends"
	# old: kdepimlibs-kio-plugins

pkg__32_DESKTOP_NET__info="X11 desktop enviroment - internet"
pkg__32_DESKTOP_NET__list="firefox-esr ca-certificates
	claws-mail claws-mail-feeds-reader claws-mail-address-keeper claws-mail-multi-notifier claws-mail-dillo-viewer
	claws-mail-smime-plugin claws-mail-pgpinline claws-mail-pgpmime claws-mail-attach-remover claws-mail-tnef-parser
	psi-plus psi-plus-plugins linphone"

pkg__34_DESKTOP_MISC__info="X11 desktop enviroment - misc & icons"
pkg__34_DESKTOP_MISC__list="kde-cli-tools xdg-desktop-portal-kde
	qt5ct kde-style-oxygen-qt5 qt6ct kde-style-oxygen-qt6 oxygencursors
	tango-icon-theme gnome-icon-theme gnome-icon-theme-nuovo gnome-icon-theme-gartoon
	gnome-icon-theme-suede gnome-icon-theme-yasis oxygen-icon-theme
	plasma-workspace systemsettings"

pkg__40_NOACTION__info=""

pkg__41_AUDIO__info="Audio-video: audio"
pkg__41_AUDIO__list="audacity kwave  rosegarden
	wavesurfer ardour timidity"
	#old: sweep

pkg__42_VIDEO__info="Audio-video: video"
pkg__42_VIDEO__list="obs-studio  openshot-qt kdenlive
	pitivi  "
	# old: avidemux avidemux-cli cinelerra dvbcut kino

pkg__43_AVUTILS__info="Audio-video: utils & players"
pkg__43_AVUTILS__list="ffmpeg mencoder ogmtools sox mjpegtools
	audacious mplayer subtitleeditor"
	# old: transcode transcode-utils gpac

pkg__44_GRAPHICS1__info="Graphics: 2D - raster"
pkg__44_GRAPHICS1__list="kolourpaint4 gimp krita"
	# old: gimp-gap

pkg__45_GRAPHICS2__info="Graphics: 2D - vector"
pkg__45_GRAPHICS2__list="inkscape dia librecad"

pkg__46_GRAPHICS3__info="Graphics: 3D"
pkg__46_GRAPHICS3__list="blender freecad   leocad ldraw-parts"
	# old: k3d

pkg__47_GRAPHICS4__info="Graphics: utils"
pkg__47_GRAPHICS4__list="graphicsmagick imagemagick netpbm exiv2 librsvg2-bin dvipng pdf2svg"


pkg__51_LATEX__info="Office & DTP: LaTeX"
pkg__51_LATEX__list="texlive-latex-base texlive-luatex texlive-latex-recommended
	texlive-latex-extra texlive-pictures texlive-plain-generic
	texlive-lang-polish texlive-lang-english"
	#texlive-pstricks texlive-science

pkg__52_DTPUTILS__info="Office & DTP: DTP utils"
pkg__52_DTPUTILS__list="scribus fontforge
	ghostscript psutils poppler-utils ps2eps pdftk-java wkhtmltopdf
	texlive-extra-utils texlive-font-utils blahtexml highlight python3-pygments"
	# texlive-extra-utils provide i.a.: a2ping pdfjam pdfbook pdfjoin command
	# texlive-font-utils provide i.a.: epstopdf command

pkg__53_OFFICE__info="Office & DTP: DTP office"
pkg__53_OFFICE__list="libreoffice-writer libreoffice-calc libreoffice-impress
	libreoffice-math libreoffice-dmaths libreoffice-draw
	aspell-en aspell-pl hunspell-en-us hunspell-pl"

pkg__54_FONTS__info="Office & DTP: fonts"
pkg__54_FONTS__list="fonts-dejavu fonts-lmodern fonts-freefont-otf fonts-texgyre  fonts-symbola
	fonts-dseg fonts-glasstty fonts-ocr-a fonts-3270 fonts-okolaks fonts-ocr-b
	ttf-sjfonts fonts-dkg-handwriting fonts-humor-sans fonts-breip fonts-rufscript
	fonts-klaudia-berenika fonts-monoid fonts-levien-typoscript fonts-monofur
	texlive-fonts-recommended"
	# not in stable: fonts-pecita
	# base, geek-look, handwriting, dodatkowe
#	fonts-opensymbol fonts-powerline fonts-noto-color-emoji
#	fonts-hack-otf fonts-inconsolata fonts-junicode fonts-roboto fonts-sil-andika fonts-sil-gentium
#	fonts-konatu fonts-levien-museum fonts-tuffy fonts-vollkorn ttf-bitstream-vera
#	fonts-oflb-asana-math fonts-fanwood fonts-go fonts-goudybookletter fonts-oldstandard fonts-open-sans fonts-opendin
#	fonts-noto fonts-noto-extra fonts-noto-mono fonts-noto-ui-core fonts-noto-ui-extra fonts-noto-unhinted
#	fonts-lyx fonts-elusive-icons"

pkg__60_NOACTION__info=""

pkg__61_ELECTREONICS__info="Engineering: electreonics"
pkg__61_ELECTREONICS__list="geda geda-gschem geda-utils pcb-rnd gerbv kicad
	gnucap gnucap-default-plugins0 gnucap-common ngspice tkgate
	avarice avrdude uisp stm32flash"
	# old: oregano

pkg__62_SOFTDEV__info="Engineering: software"
pkg__62_SOFTDEV__list="gcc g++ clang gdb make cmake pkg-config
	gcc-avr avr-libc gdb-avr
	gcc-arm-none-eabi binutils-arm-none-eabi libnewlib-arm-none-eabi libnewlib-dev
	doxygen graphviz manpages-dev"

pkg__63_DEVUTILS__info="Engineering: utils"
pkg__63_DEVUTILS__list="git subversion mercurial bzr patch
	gnuplot-x11
	xutils-dev devscripts cpio
	xalan xmlstarlet libsaxonb-java"
	# old: pythoncad

pkg__80_SERVER__info="Servers"
pkg__80_SERVER__list="bsd-mailx nullmailer rssh
	nginx php7.3-fpm php7.3
	exim4 spamassassin greylistd dovecot
	prosody asterisk
	squirrelmail nocc jwchat rainloop"

pkg__91_CONSOLE_NET__info="Internet in console"
pkg__91_CONSOLE_NET__list="w3m w3m-img links2 cone finch linphone-nogtk canto rsstail"


show_pkg_selection() {
	pkg_list="pkg__${1}__list"
	pkg_list=${!pkg_list}
	
	pkg_info="pkg__${1}__info"
	pkg_info=${!pkg_info}
	
	default=${2:-OFF}
	
	i=0; unset args
	
	args[$i]="__SELECT__ALL__"; let ++i
	args[$i]="Select all packages in this group"; let ++i
	args[$i]=OFF; let ++i
	
	for pn in $pkg_list; do
		args[$i]=$pn; let ++i
		desc=`apt-cache show $pn | egrep '^Description(-en)?:' | cut -f2- -d' '`
		status=`dpkg-query -f '${db:Status-Want}' -W $pn 2> /dev/null`
		if [ "$status" = "install" ]; then
			args[$i]="(+) $desc"; let ++i
			args[$i]=ON; let ++i
		else
			args[$i]="( ) $desc"; let ++i
			args[$i]=$default; let ++i
		fi
	done
	
	whiptail --title "Packages in group: $pkg_info" --checklist  "Choose packages to install ..." --separate-output 0 0 0 "${args[@]}" 2> $tmpFile
	selection=`cat $tmpFile`
	
	if [ "$selection" = "" ]; then
		return
	elif echo $selection | grep __SELECT__ALL__ >& /dev/null; then
		show_pkg_selection $1 ON
	else
		apt install $selection
		echo "Enter to continue"
		read
	fi
}

showMenu() {
	echo "whiptail --title \"Packages in group $pkg_info\" --menu \"Choose packages set:\" --notags 0 0 0"
	for n in `set | grep '^pkg__.*__info=' | sed -e 's#pkg__\(.*\)__info=.*#\1#'`; do
		pkg_info="pkg__${n}__info"
		echo "$n \"${!pkg_info}\""
	done
	echo "NOACTION \" \""
	echo "END \"(EXIT)\""
}

runMenu() {
	while true; do
		eval `showMenu` 2> $tmpFile
		selection=`cat $tmpFile`
		[ "$selection" = "" ] && break
		[ "${selection/*_/}" = "END" ] && break
		[ "${selection/*_/}" = "NOACTION" ] && continue
		show_pkg_selection $selection
	done
}

ask() {
	a=${ASK_DEFAULT:-?}
	while [ "$a" != "y" -a "$a" != "Y" -a "$a" != "" -a "$a" != "n" ]; do
	echo "${1}? (Y/n)"
		read a
	done
	test "$a" != "n"
	return $?
}

if [ "$1" = "-n" ]; then
	ASK_DEFAULT="n"
elif [ "$1" = "-y" ]; then
	ASK_DEFAULT="y"
else
	ASK_DEFAULT="?"
fi

if ask "enable UTF8 support"; then
	echo 'LANG="C.UTF-8"' > /etc/default/locale;
	echo 'set -a; . /etc/default/locale; set +a' > /etc/profile.d/locale.sh
	echo 'perl -e exit 2>&1 | grep "Setting locale failed" 2>&1 > /dev/null && export LC_ALL=C.UTF-8' >> /etc/profile.d/locale.sh
fi

if ask "disable auto install recommends packages"; then
	echo 'Apt::Install-Recommends "false";' > /etc/apt/apt.conf.d/13norecommends
fi

if ! which whiptail; then
	if ask "Skrypt wymaga do poprawnej pracy pakietu whiptail czy chesz go zainstalowa"; then
		apt install whiptail
	fi
fi

# run packages install menu
tmpFile=`mktemp "/tmp/XXXXXXXX"`
runMenu
/bin/rm $tmpFile
