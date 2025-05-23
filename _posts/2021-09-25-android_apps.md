---
layout: post
title: Zapiski o konfiguracji Androida
author: Robert Paciorek
tags:
- android
updated: 2025-01-24
---

## Subiektywny wybór aplikacji

### podstawy

* Aparat fotograficzny – zdjęcia i video
	* [Open Camera](https://sourceforge.net/projects/opencamera/)
		* [backup konfiguracji](/files/android/BACKUP_OC_20210923_140519.xml)
* Zarządzanie plikami
	* [Ghost Commander](https://sourceforge.net/projects/ghostcommander/)
	* [Ghost Commander - SFTP plugin](https://sourceforge.net/projects/gc-sftp/)
		* klucze ssh dodaje się w opcjach wtyczki (po dłuższym przytrzymaniu na "Serwer SFTP" wyświetli się menu z pozycją "Opcje")
		* klucze dodawane są dla hosta (dodając klucz określamy dla jakiego hosta ma być użyty)
		* klucze muszą być w formacie RSA a nie OpenSSH (wygenerowane `ssh-keygen -t rsa -m pem -f plik_klucza`)
	* [Primitive FTPd](https://github.com/wolpi/prim-ftpd/)
* Mapy i nawigacja
	* [GPSTest](https://github.com/barbeau/gpstest) by barbeauDev
		* w opcjach można włączyć podtrzymywanie działania GNSS (pozycja wyświetlana jako powiadomienie)
	* All-In-One Offline Maps ([non-free](https://play.google.com/store/apps/details?id=net.psyberia.offlinemaps))
	* Coordinate Converter Plus ([non-free](https://play.google.com/store/apps/details?id=com.tennyson.degrees2utm))
* Przeglądarka WWW
	* [Firefox](https://www.mozilla.org/en-US/firefox/mobile/) + [FoxProxy](https://github.com/foxyproxy/firefox-extension)
* Edytor tekstu
	* [Acode](https://github.com/deadlyjack/Acode)
* Nagrywanie dźwięku
	* [AudioRecorder](https://github.com/Dimowner/AudioRecorder)

##### linia poleceń, i przydatne narzędzia 

* Emulator terminala wraz z narzędziami cmd-line
	* [TermOne Plus](https://gitlab.com/termapps/termoneplus) + [SecureBox-ssh,sftp,scp and etc](https://gitlab.com/termapps/securebox)
	* [Termux](https://github.com/termux/termux-app)
		* warto doinstalować kilka przydatnych narzędzi poprzez: `pkg install python openssh tracepath git vim gnupg pass pass-otp` wywołane w Termux'ie
* SSH
	* [ConnectBot](https://connectbot.org/)
* Kalkulator
	* [Calculator ++](https://github.com/serso/android-calculatorpp)
* Media Player
	* [VLC](http://www.videolan.org/)
* Przeglądarka dokumentów PDF
	* [Pdf Viewer Plus](https://github.com/JavaCafe01/PdfViewer)
* Przeglądarka dokumentów ODF
	* [OpenDocument Reader](https://github.com/TomTasche/OpenDocument.droid)
* Manager haseł
	* [Password Store](https://github.com/android-password-store/Android-Password-Store) + [OpenKeychain: Easy PGP](https://github.com/open-keychain/open-keychain)

### launcher, widgety, itp.

* Launcher
	* Nova Launcher ([non-free](https://play.google.com/store/apps/details?id=com.teslacoilsw.launcher))
		* [backup konfiguracji 2021](/files/android/2021-09-26_01-59.novabackup)
		* [backup konfiguracji 2024](/files/android/2024-12-01_11-21.novabackup)
* Klawiatura
	* [Hacker's Keyboard](https://code.google.com/p/hackerskeyboard/)
* Manager Schowka
	* [XClipper](https://gitlab.com/KaustubhPatange/xclipper-fdroid)
		* niestety na Android 10 tego typu programy działają dość słabo ze względu na zablokowaną funkcjonalność monitorowania schowka przez aplikacje w tle
* Widget zegara z sekundnikiem
	* Widget Clock DIGI ([non-free](https://play.google.com/store/apps/details?id=sk.michalec.SimpleDigiClockWidget))
		* [backup konfiguracji](/files/android/DIGI_Clock_Widget.json)
* Wywołanie menu wyłączenia telefonu
	* Shutdown (no Root) ([non-free](https://play.google.com/store/apps/details?id=com.samiadom.Shutdown))
* Blokada odbierania połączeń (na nieodblokowanym telefonie)
	* Incoming Call Lock ([non-free](https://play.google.com/store/apps/details?id=com.approids.calllock))
* Ustawienia i dostosowywanie:
	* [SystemUI Tuner](https://github.com/zacharee/Tweaker/)
	* [NFC Quick Settings](https://github.com/pcolby/nfc-quick-settings)
	* [Sound Quick Settings](https://github.com/SimonMarquis/Android-SoundQuickSettings)
	* Quick Settings ([non-free](https://play.google.com/store/apps/details?id=it.simonesestito.ntiles))
	* BootControl ([non-free](https://play.google.com/store/apps/details?id=com.microntek.bootcontrol))
* Widget battery
	* Battery Widget ([non-free](https://play.google.com/store/apps/details?id=com.droidparadise.batterywidget))
* Backup
	* Kopia zapasowa - Backup ([non-free](https://play.google.com/store/apps/details?id=com.backupyourmobile))

### inne

* Narzędzia dodatkowe:
	* NFC Tools ([non-free](https://play.google.com/store/apps/details?id=com.wakdev.wdnfc))
	* [Sensors Sandbox](https://github.com/mustafa01ali/SensorsSandbox)
	* Skaner kodów kreskowych 1D i 2D: [BinaryEye](https://github.com/markusfisch/BinaryEye)
	* Terminal szeregowy via USB - [UsbTerminal](https://github.com/liorhass/UsbTerminal)
* Informacje turystyczno-plażowe:
	* wschody - zachody – LunaSolCal Mobile ([non-free](https://play.google.com/store/apps/details?id=com.vvse.lunasolcal))
	* pływy morskie – Tide Charts ([non-free](https://play.google.com/store/apps/details?id=com.SeventhGear.tides))

### aplikacje systemowe

Wiele jest słabych, ale część "daje radę", a dla części ciężko znaleźć lepszą alternatywę:

* Górny panel szybkich ustawień
	* można go spersonalizować, a ciężko o dobrą apkę która robiłaby to lepiej
* Zegar
	* ustawienia alarmów, timer, stoper, ...
	* może być uruchamiany kliknięciem na widget zegara z sekundnikiem
* Telefon, Wiadomości i Kontakty
* Aparat
	* zewnętrze programy aparatu nie zawsze mają dostęp do pełnej rozdzielczości, wszystkich aparatów, itd. więc wbudowana aplikacja się przydaje
* Chrome
* Ustawienia i Sklep Play


## Wymiana plików z komputerem poprzez USB

Aktualne wersje Androida nie pozwalają na przedstawienie się urządzenia jako pamięci masowej USB. Konieczne jest stosowanie trybu MTP lub PTP.

Obsługę tych protokołów pod Linuxem zapewniają pakiety takie jak:

* `mtp-tools` (MTP)
* `jmtpfs` (MTP jako fuse)
* `gphotofs` (zarówno MTP jak i PTP jako fuse)

Więcej informacji:

* [https://morfikov.github.io/post/smartfon-android-linux-mtp-ptp/](Smartfon z Androidem pod linux'em (MTP/PTP))
* [Media Transfer Protocol @ ArchWiki](https://wiki.archlinux.org/title/Media_Transfer_Protocol)

Warto mieć na uwadze że w spolszczonym Androidzie 10 MTP opisywane jest jako "Transfer plików", natomiast "USB sterowane przez":

* "To urządzenie" oznacza że hostem USB jest podłączone urządzenie (komputer).
* "Podłączone urządzenie" oznacza że hostem USB jest Android (telefon), czyli tryb OTG.
