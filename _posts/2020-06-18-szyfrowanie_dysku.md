---
layout: post
title: Szyfrowanie dysków w Linuxie
author: Robert Paciorek
tags:
- debian
- storage
- kryptografia
---

Szyfrowanie jest kolejną warstwą znajdującą się gdzieś pomiędzy abstrakcyjnym obiektem jakim jest plik wraz z zawartymi w nim danymi a dane fizycznie umieszczone gdzieś na dysku twardym lub innym nośniku.
Innymi takimi warstwami mogą być tablica partycji, RAID sprzętowy lub programowy, LVM, system plików.
W zależności od zastosowanego rozwiązania szyfrowanie może być na różnych poziomach (możemy np. zaszyfrować dysk lub partycję na której mamy LVM – co zaowocuje zaszyfrowaniem wszystkich woluminów lub możemy zaszyfrować tylko jeden wolumin LVM).
Istnieje też kilka rozwiązań szyfrowania, zarówno na poziomie urządzeń blokowych (zaszyfrowane będą wszystkie dane składające się na system plików) jak i już samych systemów plików (zaszyfrowana będzie treść plików).
Więcej informacji można znaleźć w: [data-at-rest encryption @ ArchWiki](https://wiki.archlinux.org/index.php/Data-at-rest_encryption).

Jednym z popularniejszych i bardziej wygodnych rozwiązań jest *dm-crypt* wraz z *LUKS*.
Dzięki wsparciu dla tego rozwiązania w bootloaderze *GRUB* możliwe jest utworzenie w pełni zaszyfrowanego *rootfs*, zawierającego także `/boot`.

### Zaszyfrowane urządzenie blokowe

Zaszyfrowane urządzenie blokowe możemy utworzyć poleceniem:

	cryptsetup luksFormat --type luks1 -c aes-xts-plain64 -s 512 $DEV

gdzie `$DEV` oznacza urządzenie blokowe na którym będziemy tworzyć szyfrowany *rootfs*.
Warto zauważyć także że tworzony jest *LUKS* w wersji 1 gdyż tylko taka obecnie jest wspierana przez *GRUB*.

Po utworzeniu szyfrowanego urządzenia blokowego można:

* wyświetlić informacje na jego temat poleceniem `cryptsetup luksDump $DEV`, polecenie to pokazuje w szczególności użyte/wolne sloty na klucze deszyfrujące
* dodać / usunąć / zmienić klucz deszyfrujący (np. hasło) przy pomocy poleceń: `cryptsetup luksAddKey $DEV` / `cryptsetup luksRemoveKey $DEV` / `cryptsetup luksChangeKey $DEV`.

Celem wykonania kolejnych oparacji (np. utworzenia systemu plików lub wolumenów LVM) na zaszyfrowanym urządzeniu blokowym należy je „otworzyć” (czyli podać właściwy klucz deszyfrujący i utworzyć urządzenie dające dostęp do niezaszyfrowanych danych) przy pomocy polecenia:

	cryptsetup open $DEV $NAME

gdzie `$NAME` określa nazwę pliku urządzenia który będzie utworzony w `/dev/mapper`.
Wskazanie urządzeń które powinny być automatycznie otwierane przy starcie systemu możliwe jest w pliku `/etc/crypttab`, który składa się z 4 kolumn:

* nazwa tworzonego urządzenia w`/dev/mapper` (`$NAME`)
* nazwa zaszyfrowanego urządzenia blokowego (`$DEV`)
* plik klucza do deszyfracji lub `none`
* opcje (np. `luks` lub `luks,noauto`)

Na potrzeby kolejnych kroków odczytujemy UUID zaszyfrowanego urządzenia blokowego:

	CRYPT_UUID=$(blkid -o value -s UUID $DEV)
	# taki sam wynik można uzyskać dzieki:
	# cryptsetup luksDump $DEV | awk '$1=="UUID:" {print $2}'

Więcej informacji: [dm-crypt – szyfrowanie całego systemu @ ArchWiki](https://wiki.archlinux.org/index.php/Dm-crypt_(Polski)/Encrypting_an_entire_system_(Polski))


### Instalacja systemu na zaszyfrowanym urządzeniu

Instalacja systemu przebiega standardowo i wykorzystywane do niej jest urządzenie blokowe `/dev/mapper/$NAME`, np.:

	MOUNT=/mnt
	
	mkfs.xfs /dev/mapper/$NAME
	mount /dev/mapper/$NAME $MOUNT
	
	debootstrap stable $MOUNT http://ftp.icm.edu.pl/pub/Linux/debian/
	chroot $MOUNT apt install grub2 linux-image-amd64

Na potrzeby kolejnych kroków odczytujemy UUID (odszyfrowanego) systemu plików:

	ROOTFS_UUID=$(blkid -o value -s UUID /dev/mapper/$NAME)


### Konfiguracja systemu uruchamianego z zaszyfrowanego urządzenia

Po zainstalowaniu systemu konieczne jest odpowiednie skonfigurowanie bootloadera, montowania rootfs, itd.
Warto jednocześnie umożliwić montowanie *rootfs* przez jądro bez konieczności ponownego podawania hasła (hasło musi być podane na etapie bootloadera aby miał on dostęp do zawartości katalogu `/boot`).
Zrealizować to można poprzez użycie drugiego klucza deszyfrującego, który będzie zapisany wewnątrz *initrd.img*.

Utworzenie pliku klucza i dodanie go do szyfrowanego urządzenia blokowego:

	mkdir -p $MOUNT/etc/keys && chmod 700 $MOUNT/etc/keys
	( umask 0077 && dd if=/dev/urandom bs=1 count=64 of=$MOUNT/etc/keys/rootfs.key conv=excl,fsync )
	cryptsetup luksAddKey --key-slot=7 $DEV $MOUNT/etc/keys/root.key

Wpis w `/etc/crypttab` umożliwiający deszyfrację *rootfs* przy pomocy tego klucza (wskazujemy też slot z którym został powiązany ten klucz, w tym przypadku numer 7) oraz wpis w `/etc/fstab`:

	echo "$NAME  UUID=$CRYPT_UUID  /etc/keys/root.key  luks,key-slot=7" >> $MOUNT/etc/crypttab
	echo "/dev/mapper/$NAME  /  xfs  defaults  0  1" >> $MOUNT/etc/fstab

Konfiguracja *initramfs-tools* w celu umieszczania w obrazie rozruchowym odpowiednich kluczy (i zabezpieczenia przed ich wykradzeniem):

	echo 'KEYFILE_PATTERN="/etc/keys/*.key"' >> $MOUNT/etc/cryptsetup-initramfs/conf-hook
	echo 'UMASK=0077' >> $MOUNT/etc/initramfs-tools/initramfs.conf

Wygenerowanie nowego *initrd.img* i sprawdzenie jego poprawności:

	chroot $MOUNT  update-initramfs -u
	lsinitramfs $MOUNT/initrd.img | grep "^cryptroot/keyfiles/" && echo OK


Skonfigurowanie grub'a:

	echo 'GRUB_ENABLE_CRYPTODISK=y' >> $MOUNT/etc/default/grub
	chroot $MOUNT  update-grub

Więcej informacji: [full disk encryption, including /boot](https://cryptsetup-team.pages.debian.net/cryptsetup/encrypted-boot.html)


### Wpis w obcym grub.cfg

Możliwe jest bootowanie systemu z zaszyfrowanego urządzenia także gdy grub pochodzi z innego systemu.
Automatyczne wykrywanie takiego systemu w ramach `update-grub` najprawdopodobniej jednak nie zadziała poprawnie.
Można to rozwiązać dodając np. plik `/etc/grub.d/13_linux_secure` który utworzy w `grub.cfg` wpisy pozwalające na bootowanie systemu z zaszyfrowanego urządzenia.
Plik ten powinien mieć prawo wykonywalności i być np. postaci:

	#! /bin/bash
	set -e
	
	. /etc/grub.d/13_linux_secure.conf
	
	CRYPT_UUID=${CRYPT_UUID//-/}
	
	cat << EOF
	menuentry 'Debian GNU/Linux SECURE' --class debian --class gnu-linux --class gnu --class os \$menuentry_id_option 'gnulinux-simple-$ROOTFS_UUID' {
		insmod cryptodisk
		insmod luks
		insmod gcry_rijndael
		insmod gcry_sha256
		insmod xfs
		cryptomount -u $CRYPT_UUID
		set root='cryptouuid/$CRYPT_UUID'
		if [ x\$feature_platform_search_hint = xy ]; then
			search --no-floppy --fs-uuid --set=root --hint='cryptouuid/$CRYPT_UUID'  $ROOTFS_UUID
		else
			search --no-floppy --fs-uuid --set=root $ROOTFS_UUID
		fi
		echo    'Loading Linux 4.19.0-8-amd64 ...'
		linux   /vmlinuz root=UUID=$ROOTFS_UUID ro
		echo    'Loading initial ramdisk ...'
		initrd  /initrd.img
	}
	EOF

Dodatkowo należy utworzyć plik `/etc/grub.d/13_linux_secure.conf` przy pomocy poleceń:

	echo CRYPT_UUID=$CRYPT_UUID > /etc/grub.d/13_linux_secure.conf
	echo ROOTFS_UUID=$ROOTFS_UUID >> /etc/grub.d/13_linux_secure.conf


### Zobacz także

* [Własny Debian LiveUSB](http://www.opcode.eu.org/LiveUSB.xhtml)
* [Bootowanie systemu](http://www.opcode.eu.org/SystemBoot.xhtml)
