---
layout: post
title: bwrap wewnątrz chroot, czyli Steam w chroot
author: Robert Paciorek
tags:
- debian
---

Jądro nie zezwala na tworzenie przestrzeni użytkownika (używanej m.in. przez polecenia `bwrap`, czy `unshare` z opcjami takimi jak `-r`, `-c`, `-U`) wewnątrz chroot'ów (zobacz [źródła jądra](https://github.com/torvalds/linux/blob/c3137514f1f13532bec4083832e7b95b90b73abc/kernel/user_namespace.c#L99) i `man 2 unshare`). Próba urcomienia tych poleceń wewnątrz standardowego chroot'a kończy dię komunikatami typu: "bwrap: No permissions to create new namespace" i "unshare failed: Operation not permitted". Stanowi to problem m.in. przy próbie instalacji Steam'a wewnątrz chroot'a, gdyż wykorzystuje on wewnętrznie `bwrap`.

Rozwiązanie może być użycie `bwrap` zamiast chroot'a / schroot'a:

	bwrap \
		--bind /opt/games / \
		--dev /dev \
		--proc /proc \
		--bind /sys /sys \
		--bind /run /run \
		--bind /tmp /tmp \
		--ro-bind /etc/passwd /etc/passwd \
		--ro-bind /etc/group /etc/group \
		"$@"

Zaletą jest brak konieczności posiadania uprawnień root'a do uruchomienia takiego chroot'a oraz możliwość zagnieżdzania takich wywołań. Wadą jest natomiast utrata dodatkowych grup (określających uprawnienia użytkownika) wewnątrz tak utworzonego "chroota". Fakt że właśnie z takimi grupami wiąże się prawo do korzystania z akceleracji 3D na GPU czyni to rozwiązanie bezużytecznym w przypadku Steam'a.

Możliwe jest jednak skonstruowanie środowiska typu "chroota", które będzie pozwalało na tworzenie wewnątrz niego. Wymaga to utworzenia namespace typu mount w którym zostanie ustawiony ten sam katalog na root tego namespace i filesystemu. Może to być zrealizowane skryptem:

	CHROOT_DIR="/opt/games"
	USER="rrp"
	
	CMD=$1; shift; ARGS="$@"
	USERID=$(id -u $USER)
	
	exec sudo /usr/bin/unshare -m /bin/sh -c "
		mount --bind   $CHROOT_DIR        $CHROOT_DIR
		
		mount -t proc  proc               $CHROOT_DIR/proc
		mount -t sysfs sysfs              $CHROOT_DIR/sys
		mount -o rbind /dev               $CHROOT_DIR/dev
		mount -o rbind /dev/pts           $CHROOT_DIR/dev/pts
		mount -o rbind /dev/shm           $CHROOT_DIR/dev/shm
		mount -o rbind /run               $CHROOT_DIR/run
		mount -o rbind /run/dbus          $CHROOT_DIR/run/dbus
		mount -o rbind /run/lock          $CHROOT_DIR/run/lock
		mount -o rbind /run/shm           $CHROOT_DIR/run/shm
		mkdir -p $CHROOT_DIR/run/user/$USERID
		mount -o rbind /run/user/$USERID  $CHROOT_DIR/run/user/$USERID
		mount -o rbind /tmp               $CHROOT_DIR/tmp
		
		cd $CHROOT_DIR
		pivot_root . root
		cd /
		umount -l root
		
		[ \"$ARGS\" != \"\" ] && exec su -s /bin/sh -c 'exec \"$CMD\" \"$ARGS\"' $USER
		[ \"$CMD\" != \"\" ] && exec su -s /bin/sh -c 'exec \"$CMD\"' $USER
		exec su -s /bin/bash $USER
	"
