---
layout: post
title: Systemd, journalctl i dostrajanie startu systemu
author: Robert Paciorek
tags:
- debian
---

Systemd jest obecnie chyba najpopularniejszym programem typu init w świecie linuxowym. Oprócz samym zarządzaniem startem systemu (uruchamianiem usług) zajmuje się także uruchamianiem usług na poziomie sesji użytkownika (jest w tym celu wywoływany przez pam). Ponaddto może on pełnić także funkcję daemona odpowiedzialnego za uruchamianie zadań w określonym czasie (mogącym zastępować cron / anacron) oraz daemona odpowiedzialnego za zbieranie logów (mogącym zastapić syslog).

[Więcej informacji o samym systemd w rorli init.](https://www.opcode.eu.org/SystemBoot.xhtml#systemd)


## Logi w systemd

Zamiast trzymania logów w podzielonych tematycznie i rotowanych co pewien czas plikach tekstowych systemd trzyma je w pliku. Z tego powodu do ich przeglądania należy korzystać z dedykowanego programu, którym jest *journalctl*.

Nie występuje tu klasyczne rotowanie logów realizowane przez zewnętrzny program. A wielkość trzymanej historii logów (oraz inne ustawienia) określa się w pliku `/etc/systemd/journald.conf`. Wpis `SystemMaxUse=200M` w sekcji `[Journal]` spowoduje że ilość miejsca na dysku zajmowanego przez logi journalctl (`/var/log/journal`) nie przekroczy 200MB.

* Opcje `-u` i `-t` w `journalctl` pozwalają na filtrowanie logów według usługi (odpowiednio wg unit który ją uruchamia bądź identyfikatora syslog).
* Opcje `-S` i `-U` pozwalają na filtrowanie wg czasu. Można także korzystać z wartości względnych - np. `journalctl -S -1h` wyświetli logi z ostatniej godziny.
* `export SYSTEMD_LESS=FRXM` spowoduje włączenie zawijania linii, dzięki czemu nie będzie trzeba przewijać w poziomie.

### kierowanie logów z aplikacji do journalctl

*journalctl* słucha na `/dev/log` zatem możemy kierować do niego także logi z (niektórych) aplikacji standardowo zapisujących je do własnych plików logów.
Na przykład ustawienie w `/etc/nginx/nginx.conf` w zakresie globalnym `error_log syslog:server=unix:/dev/log;` oraz `access_log syslog:server=unix:/dev/log;` w zakresie `http` spowoduje przekierowanie logów nginx do *journalctl*
(o ile ustawienia konkretnego hosta nie nadpiszą tych ustawień).

### dmesg

`dmesg` jest narzędziem (nie powiązanym z systemd ani z journalctl) pozwalającym na wyświetlanie logów jądra. Od jakiegoś czasu jego używanie zaczeło wymagać uprawnień root'a. Aby powrócić do poprzedniego zachowania i pozwolić każdemu na oglądanie logów jądra należy ustawić zero w `/proc/sys/kernel/dmesg_restrict` (można dodać `echo 0 > /proc/sys/kernel/dmesg_restrict` do `/etc/rc.local` jeżeli jest obsługiwany).

### last

Poprawne działanie `last` wymaga obecnie (Debian Trixie) zainstalowania pakietu `wtmpdb`.

## Optymalizacja startu

* Polecenia `systemctl list-units --type=service,timer,socket  --all` pozwala na wylistowanie wszystkich załadowanych bądź nie odnalezionych usług, timerów i gniazd (obsługiwanych przez systemd).
* Polecenie `systemctl list-unit-files --type=service,timer,socket --state=disabled,masked` pozwala na wylistowanie wszystkich wyłączonych i zamaskowanych unitów usług, timerów i gniazd (obsługiwanych przez systemd).
* Polecenie `systemd-analyze blame` pozwala na sprawdzenie co było ładowane przy starcie i ile czasu to zajmowało (uwaga: czasy nie sumują się do czasu startu systemu - usługi mogą być uruchamiane równolegle, czasy obejmują także wczytywanie z dysku, więc pierwsza usługa wczytująca jakąś bibliotekę będzie miała większy czas niż kolejne jej używające).

Wszystkie te polecenia po dodaniu opcji `--user` będą pokazywać odpowiednie wyniki na poziomie sesji użytkownika (a nie systemu).

### Wyłączenie wybranych usług

Poniżej lista poleceń wyłączająca pewne usługi. Jest ona zasadna w specyficznym przypadku danego systemu i nie jest uniwersalna (np. na systemach używających ex4 nie należy wyłączać e2scrub_reap).

	disable() { systemctl stop $1; systemctl disable $1; systemctl mask $1; }
	
	# to jest zainstalowane dla wywołań manualnych a nie pracy jako daemon
	disable lm-sensors
	disable smartmontools
	
	# dyski montuję manualnie ... udisks2 jest zainstalowany tylko jako zależność plasma-workspace
	# ale dolphin potrzebuje udisks2 do działania osobnych koszy dla punktów montowania (`.Trash-$UID`)
	# więc niestety udisks2 musi pozostać włączony
	# disable udisks2
	
	# nie mam potrzeby żeby to się robiło przy starcie ... to jest wykonywane po instalacji
	disable man-db
	disable man-db.timer
	disable dkms
	disable schroot
	
	# nie checę automatycznego update list pakietów
	disable apt-daily
	disable apt-daily.timer
	disable apt-daily-upgrade.timer
	
	# nie używam ext
	disable e2scrub_reap
	disable e2scrub_reap.timer
	
	# nie używam obrazów wirtualizacyjncyh na poziomie systemowym
	disable systemd-importd.socket
	disable systemd-sysext.socket
	
	# grub zawsze pokazuje menu, więc w razie nieudanego boota sam podejmę stosowne działania
	disable grub-common

Oraz analogiczna lista dla poziomu użuytkownika:

	disableu() { systemctl --user stop $1; systemctl --user mask $1; }
	disableu xdg-desktop-portal.service
	disableu xdg-document-portal.service
	disableu xdg-permission-store.service
	disableu mpris-proxy.service
