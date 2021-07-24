---
layout: post
title: PXE – bootowanie przez sieć
author: Robert Paciorek
tags:
- debian
- storage
---

PXE jest technologią pozwalającą na bootowanie komputera "po sieci", czyli bez fizycznej instalacji systemu operacyjnego na danej maszynie.
Wymaga ona wsparcia na poziomie BIOSu karty sieciowej.

Karta z włączonym wsparciem PXE, wysyła zapytanie do serwara DHCP i w odpowiedzi oprócz swojego adresu IP i tego typu danych otrzymuje także informacje związane z bootowaniem PXE (takie jak nazwa obrazu).
Następnie obraz bootloadera pobierany jest z serwera TFTP i uruchamiany.
Bootloader ten pobiera (typowo także po TFTP) i uruchamia odpowiedni obraz jądra, które rootfs montuje typowo z użyciem NFS.


## Konfiguracja serwera PXE

### DHCP

Serwer powinien mieć zainstalowaną (i uruchomioną) usługę DHCP, która w konfigu oprócz standardowego przyznawania adresów ma włączoną (globalnie lub dla wybranego hosta/hostów) opcję wysyłania nazwy obrazu PXE.

Dla serwera *isc-dhcp-server* jest to:

	filename "pxelinux.0";

Natomiast dla *dnsmasq* (który może pełnić od razu funkcję serwera TFTP) jest to:

	dhcp-boot=pxelinux.0
	enable-tftp
	tftp-root=/var/lib/tftpboot/

### TFTP

Na tym komputerze powinna działać także usługa TFTP (przy *dnsmasq* jest już w zestawie, przy *isc-dhcp-server* należy zainstalować i uruchomić osobny serwer, może być uruchamiany via *xinetd*).

Do głównego katalogu TFTP (np. `/var/lib/tftpboot/`) powinien być wgrany [PXELINUX](https://wiki.syslinux.org/wiki/index.php?title=PXELINUX) (na systemach Debianowych może być zainstalowany z paczki *pxelinux* i odpowiednio podlinkowany).
Jego konfiguracja (w `$ROOT_TFTP/pxelinux.cfg/default`, gdzie `$ROOT_TFTP` jest ścieżką do głównego katalogu TFTP) może wyglądać:

	DEFAULT menu.c32
	PROMPT 0
	
	MENU TITLE PXE Menu
	MENU AUTOBOOT Starting Local System in # second
	
	LABEL bootlocal
	  MENU LABEL Boot From Local Disk
	  MENU DEFAULT
	  LOCALBOOT 0
	TIMEOUT 1200
	
	MENU INCLUDE debian-usb/pxelinux.cfg

Natomiast zainkludowany plik `debian-usb/pxelinux.cfg` może być postaci:

	LABEL debianusb
	MENU LABEL Debian LiveUSB via PXE
	KERNEL debian-usb/vmlinuz
	APPEND initrd=debian-usb/initrd.img console=tty0 console=ttyS0,115200n8 root=/dev/nfs nfsroot=/var/lib/tftpboot/debian-usb ro

### NFS

Bootwanie PXE w wielu wypadkach wymaga także serwera NFS i może on być zainstalowany i uruchomiony na tej samej maszynie co DHCP i TFTP.
W pliku `/etc/exports` powinien być wyeksportowany katalog w którym znajduje się rootfs dla maszyn uruchamianych z PXE np.:

	/var/lib/tftpboot/debian-usb       *(ro,no_root_squash)

### Obraz systemu:

Powyższa konfiguracja zakłada że obraz systemu umieszczony jest w `/var/lib/tftpboot/debian-usb` i funkcję takiego obrazu może pełnić (podmontowany w tej lokalizacji) obraz [bootowalnego USB](http://www.opcode.eu.org/LiveUSB.xhtml).
W tym celu w `/var/lib/tftpboot/debian-usb` montujemy (lub wypakowujey) zawartość partycji rootfs z usb, np. poprzez:

	cd /var/lib/tftpboot/; DEV=`losetup --partscan --find --show debian-usb.img`; mount ${DEV}p3 debian-usb
