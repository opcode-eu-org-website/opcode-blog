---
layout: post
title: Zasoby dyskowe
author: Robert Paciorek
tags:
- debian
- storage
---

## Tablica partycji GPT

[GUID Partition Table](http://pl.wikipedia.org/wiki/GUID Partition Table) (niekiedy określany także jako tablica partycji EFI) jest jednym z kilku stosowanych typów tablic partycji.
W porównaniu do konkurentów (takich jak:
	PC/DOS/[MBR](http://pl.wikipedia.org/wiki/Master Boot Record),
	[BSD disklabel](http://en.wikipedia.org/wiki/BSD disklabel),
	[APM](http://en.wikipedia.org/wiki/Apple Partition Map), ...
) jest rozwiązaniem dość nowym i posiadającym zalety wobec nich – obsługa dużych partycji, bezpośrednia (bez zagnieżdżania disklabel) obsługa systemów BSD, obsługa do 128 partycji, itd.

Do tworzenia tego typu partycji pod linuxem możemy posłużyć się GNU parted:

	# tworzymy tablicę partycji typu gpt
	parted $DEV "mklabel gpt"

	# tworzy partycję która posłuży do wgrania gruba
	# należy zaznaczyć iż nie jest to partycja /boot
	# jest to surowe (bez filesystemu) miejsce na dysku gdzie
	# zostanie wgrany fragment gruba normalnie wgrywany zaraz za MBR
	parted $DEV "mkpart grub 0 2MB";

	# ustawiamy dla tej partycji flagę "GRUB BIOS partition"
	parted $DEV "set 1 bios_grub on"

	# resztę dysku możemy podzielić wg uznania
	# w tym przykładzie robimy jedną dużą partycję o nazwie raid
	parted $DEV "mkpart raid 2MB 100%";

GRUB2 instalowany w takim układzie (gdzie dostaje własną partycję na wgranie swoich binariów) radzi sobie bez problemu z partycjami GPT, macierzami mdadm, wolumenami LVM itd.


## RAID i LVM - bezpieczniejsze, większe i bardziej elastyczne partycje dyskowe

Linux oferuje dwie przydatne technologie dotyczące zarządzania pamięciami masowymi - jest to programowy [RAID](http://pl.wikipedia.org/wiki/RAID) oraz woluminy logiczne [LVM](http://pl.wikipedia.org/wiki/LVM).
RAID umożliwia realizację różnych form mirroringu mających na celu zabezpieczenie przed utratą danych, a także uzyskiwanie większych przestrzeni złożonych z kilku dysków.
LVM służy umożliwieniu bardziej elastycznego podziału dysku oraz uzyskania logicznych partycji złożonych z wielu różnych fragmentów dysków fizycznych.

	# tworzymy RAID1 dla partycji /
	mdadm -C -v /dev/md0 --level=1 -n 2 /dev/sda1 /dev/sdb1
	# tworzymy zdegradowany RAID1 dla dwóch partycji na których będzie /home
	mdadm -C -v /dev/md1 --level=1 -n 2 /dev/sda3 missing
	mdadm -C -v /dev/md2 --level=1 -n 2 /dev/sdb3 missing
	
	# tworzymy volumeny fizyczne na urządzeniach RAID dla potrzeb LVM
	pvcreate /dev/md1
	pvcreate /dev/md2
	# tworzymy grupę voluminów dla LVM
	vgcreate lvm0 /dev/md1
	# dodajemy volumen fizyczny do grupy
	vgextend lvm0 /dev/md2
	# można też usunąć przy pomocy:
	# vgreduce lvm0 /dev/md2
	# tworzenie volumenu logicznego o zadanej wielkości i nazwie w ramch podanej grupy
	# będzie z nim związane urządzenie /dev/lvm0/home
	lvcreate -L 25G -n home lvm0
	# ogladamy to co żesmy stworzyli
	pvdisplay
	vgdisplay
	lvdisplay
	# powiększamy volumen logiczny
	lvextend  -L +1GB  /dev/sys/homes
	# powiększamy system plików, np.
	#  xfs_growfs /home
	#  resize2fs /dev/lvm0/home
	#  btrfs filesystem resize max /home
	#  # więcej poleceń btrfs-owych: https://btrfs.wiki.kernel.org/index.php/Btrfs%28command%29
	
	# uzupełniamy nasz zdegradowany raid
	/sbin/mdadm -a /dev/md1 /dev/sdc1
	/sbin/mdadm -a /dev/md2 /dev/sdc2

Do kasowania macierzy możemy posłużyć się komendą: `mdadm -S --zero-superblock /dev/md14; mdadm -S /dev/md11`

Warto zachęcać MD do używania identyfikatorów dysków w tym celu: w `/etc/mdadm/mdadm.conf` umieszczamy wpis `DEVICE /dev/disk/by-id/*`, macierz budujemy (w tym przykładzie raid 6 na 8 dyskach) np.:

	mdadm -C -v --auto=mdp --level=raid6 --raid-devices=8 /dev/disk/by-id/scsi-*part2

i w oparciu o wynik `mdadm --detail --scan` edytujemy `/etc/mdadm/mdadm.conf`

### rozwiązywanie problemów

W zasadzie LVM sam się konfiguruje przy uruchamianiu jądra, ale niekiedy może zajść potrzeba ręcznego uruchamiania LVM w trakcie startu systemu. Procedura takiej operacji wygląda następująco:

1. załadowanie modułów od devicemaper `dm-mod` i od lvm `lvm*` (jeżeli jest jako moduły)
2. jeżeli udev nie potworzył urządzeń to tworzymy ręcznie:
<pre>
	mknod --mode=600 /dev/lvm c 109 0
	mknod --mode=600 /dev/mapper/control c 10 62
	# numery możemy odczytać z /proc/device:
	#  major = misc
	#  minor = device-mapper
</pre>
3. wykonanie `/sbin/vgscan`, ewentualnie z opcjami `--ignorelockingfailure` i/lub `--mknodes`
4. wykonanie `/sbin/vgchange -a y`, ewentualnie z opcją `--ignorelockingfailure`
5. ustawienie odpowiednich uprawnień do urządzeń

W przypadku ręcznej konfiguracji LVM na wczesnych etapach działania systemu może pojawić się problem z tworzeniem pliku blokady - "LVM - Locking type 1 initialisation failed",
spowodowane to może być tym iż partycja zawierająca `/var/lock` jest w trybie tylko do odczytu, rozwiązaniem jest np. `mount -t tmpfs tmpfs /var/lock`

Niekiedy (np. niezgodne UUIDy dysków/partycji wchodzących w skład RAIDa) może zajść potrzeba ręcznego wystartowania RAIDa wg podanego trybu i na podanych urządzeniach.
W tym celu należy (po zatrzymaniu raida który wystartował z błędem poprzez `mdadm -S /dev/mdX`) skorzystać z opcji `--create --assume-clean` do polecenia `mdadm` wraz z określeniem jaki typ raida, z ilu dysków i wylistowaniem tych dysków, np.:

	mdadm --create --assume-clean --level=1 --raid-devices=2 /dev/md1 /dev/sda1 /dev/sdb1

Odczyt UUIDów oraz innych informacji odnośnie RAIDa zapisanych na składowym dysku możliwy jest za pomocą: `mdadm --examine /dev/sda1`.
W przypadku kłopotów z mdadm'em przydatne mogą być także opcje `--scan`, `--detail`, `--verbose`.

### więcej informacji

* [RAID programowy @ Arch Wiki](https://wiki.archlinux.org/title/RAID)
* [LVM @ Arch Wiki](https://wiki.archlinux.org/index.php/LVM).
* [RAID programowy @ PLD](http://pl.docs.pld-linux.org/soft_raid.html)
* [LVM @ PLD](http://pl.docs.pld-linux.org/lvm2.html)


## Network File System

[NFS](http://pl.wikipedia.org/wiki/Network file system) jest opartym o protokół IP protokołem do udostępniania systemów plików poprzez sieć.
Udostępnianie zasobów dyskowych po nfs wymaga zainstalowanego serwera NFS (dla linuxów występuje on w dwóch wersjach - działającej w przestrzeni jądra oraz działającej jako normalny daemon).
Konfiguracja udostępnianych zasobów ustawiana jest w `/etc/exports` (dla linuxa) i zatwierdzana (przeładowywana) przy pomocy komendy `exportfs`
	(opcja -r dla ponownego eksportu - przeładowania configu, -v dla pokazania co jest obecnie wyeksportowane).
Plik ten składa się z dwóch kolumn – w pierwszej podawana jest ścieżka do udostępnianego systemu plików, w drugiej podawane są adresy uprawnionych hostów i opcje exportu dla każdego z hostów.
Konfiguracja montowania odbywa się standardowo w `/etc/fstab` i wymaga podania jako typu systemu plików `nfs`.

Możliwe jest także eksportowanie drzewa katalogów po nfs-ie bez umieszczania wpisów w plikach konfiguracyjnych:

	exportfs -o rw host-klienta:/eksportowana/sciezka

oraz montowanie bez wpisów w `/etc/fstab`:

	mount -t nfs serwer:/eksportowana/sciezka /punkt/montowania


## Multipath i SAN

Multipath może być użyty do konfiguracji ścieżek dostępu do dysków/macierzy dyskowych [SAN](http://pl.wikipedia.org/wiki/Storage Area Network) podłączanych na przykład poprzez [Fibre Channel](http://pl.wikipedia.org/wiki/Fibre Channel).
Na ogół jest narzędziem na tyle sprytnym iż radzi sobie z autodetekcją poprawnej ścieżki itd, oczywiście istnieje także możliwość manualnej konfiguracji ścieżek.

Multipath pokazuje identyfikatory [Fibre Channel](http://pl.wikipedia.org/wiki/Fibre Channel) LUN - konkretnie "tgt_node_name" (np. 0x500a09808657d365) oraz "h:b:t:l" (np. 0:0:2:5), gdzie "h:b:t" to `target_id`.
Inne informacje (np. "tgt_port_name", "port_id") można zobaczyć w `/sys/class/fc_transport/target${target_id}/port_name` i jemu podobnych.

Z kolei identyfikator WWN karty (interfejsu) FC (potrzebny do wystawienia zasobów z macierzy) możemy odczytać przez: `cat /sys/class/fc_host/host0/port_name`.

Uwaga: włączenie multipath może spowodować jego zadziałanie na dysku lokalnym co objawi się np. komunikatem o zajętości urządzenia przy próbie tworzenia systemu plików na nim
	(mkfs mówi "is apparently in use by the system; will not make a filesystem here") - należy wtedy (jeżeli nie jest nam potrzebne) wyłączyć działanie multipath na takim urządzeniu lub operować na urządzeniu multipathowym.

Aby zabronić odpalania się multipath na konkretnym urządzeniu należy w pliku `/etc/multipath.conf` umieścić wpis postaci:

	blacklist {
		wwid NASZ_WWID
	}

gdzie `NASZ_WWID` można uzyskać z wyniku komendy `multipath -ll` jest to to identyfikator bez spacji pokazywany w pierwszej linii opisującej dany zastaw ścieżek.
Należy tutaj odrzucić ostatnie znaki tożsame z oznaczeniem urządzenia device mappera w /dev (np. dm-0).
Opcjonalnie zamiast wpisu `wwid NASZ_WWID` można podać wpis typu `devnode /dev/sda*`, ale może to rodzić problemy gdy oznaczenia dysków z jakiś powodów się pozmieniają.


## Odświeżanie listy urządzeń SCSI

W przypadku korzystania z urządzeń SCSI hot-plug (np. dysków hot-swap) zachodzi niekiedy potrzeba odświeżenia wykazu urządzeń w systemie, możemy to wykonać w następujący sposób:

	# odświeżenie listy urządzeń (utworzenie plików w /dev, ...)
	echo - - - > /sys/class/scsi_host/HOST/scan
	# HOST określa który kontroler poddawany jest ponownemu skanowaniu


Często bywa tez potrzebne odświeżenie informacji o wielkości istniejącego urządzenia (np. zmiana rozmiaru LUNa na macierzy). Uzyskać to możemy przy pomocy komend:

	# reskan urządzenia (niekiedy wymagane dla ścieżek multipath-owych)
	echo 1 > /sys/block/DYSK/device/rescan
	
	# odświeżenie informacji o wielkości urządzenia
	blockdev --rereadpt /dev/DYSK
	# wielkość możemy sprawdzić komendą (uwaga wynik w blokach 0.5kB):
	blockdev --getsz /dev/DYSK
	
	# zmiana rozmiaru urządzenia multipath-owego
	multipathd -k"resize map ID_MAPY"

Dla sieciowej odmiany SCSI ([iSCSI](http://pl.wikipedia.org/wiki/ISCSI)) odświeżenie rozmiaru zasobu wykonujemy poleceniem `iscsiadm -m node -R`

Dodatkowo przydatne mogą być polecenia postaci:
	lsscsi
	echo 'scsi-add-single-device    HOST CHAN DEV LUN' > /proc/scsi/scsi
	echo 'scsi-remove-single-device HOST CHAN DEV LUN' > /proc/scsi/scsi


## Montowanie SFTP jako systemu plików

Możliwe jest montowanie zdalnych zasobów SFTP jako lokalnego systemu plików.
Wymaga to zainstalowania pakietu z sshfs oraz załadowania modułu FUSE.
Montowanie wykonujemy przy pomocy polecenia:
	sshfs -o workaround=rename serwer:katalog punkt_montowania

Oczywiście użytkownik wykonujący to polecenie musi mieć prawa do `/dev/fuse` (należeć do grupy fuse).
