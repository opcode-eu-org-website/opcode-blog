---
layout: post
title: bwrap wewnątrz chroot, czyli Steam w chroot
author: Robert Paciorek
tags:
- debian
---

Jądro nie zezwala na tworzenie przestrzeni użytkownika (używanej m.in. przez polecenia `bwrap`, czy `unshare` z opcjami takimi jak `-r`, `-c`, `-U`) wewnątrz chroot'ów (zobacz [źródła jądra](https://github.com/torvalds/linux/blob/c3137514f1f13532bec4083832e7b95b90b73abc/kernel/user_namespace.c#L99) i `man 2 unshare`). Próba uruchomienia tych poleceń wewnątrz standardowego chroot'a kończy dię komunikatami typu: "bwrap: No permissions to create new namespace" i "unshare failed: Operation not permitted". Stanowi to problem m.in. przy próbie instalacji Steam'a wewnątrz chroot'a, gdyż wykorzystuje on wewnętrznie `bwrap`.

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

Zaletą jest brak konieczności posiadania uprawnień root'a do uruchomienia takiego chroot'a oraz możliwość zagnieżdżania takich wywołań. Wadą jest natomiast utrata dodatkowych grup (określających uprawnienia użytkownika) wewnątrz tak utworzonego "chroota". Fakt że właśnie z takimi grupami wiąże się prawo do korzystania z akceleracji 3D na GPU czyni to rozwiązanie bezużytecznym w przypadku Steam'a.

Możliwe jest jednak skonstruowanie środowiska typu "chroota", które będzie pozwalało na tworzenie wewnątrz niego przestrzeni użytkownika. Wymaga to utworzenia namespace typu mount w którym zostanie ustawiony ten sam katalog na root tego namespace i filesystemu. Może to być zrealizowane odpowiednim skryptem korzystającym z `unshare`.

[Zaktualizowana (sierpień 2026) wersja skryptu](/files/wine/games_chroot.sh) z poprawionym przekazywaniem argumentów, zachowaniem bieżącego katalogu i ustawianiem zmiennych środowiskowych.
