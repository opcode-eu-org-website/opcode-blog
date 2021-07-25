---
layout: post
title: Sekwencje sterujące terminala, czyli kolorowanie i nie tylko
author: Robert Paciorek
tags:
- debian
---

Sekwencje sterujące terminala są to specjalne ciągi znaków, które wysyłane do terminala
(z punktu widzenia programisty po prostu wypisane na terminal z użyciem `echo`, `print`, `printf`, `std::cout`, itd)
powodują zmianę jego zachowania, taką jak na przykład:

* zmianę koloru lub dekoracji wypisywanego (po tej sekwencji) tekstu
* pokazanie / ukrycie lub przesunięcie kursora

Sekwencje te ustandaryzowane są pod postacią [ANSI X3.64](https://en.wikipedia.org/wiki/ANSI_escape_code) (ISO 6429), które popularność zyskało wraz z terminalem VT100, stąd często określenie są jako ANSI/VT100.
Wszystkie te sekwencje sterujące rozpoczynają się od znaku ESC (który posiada kod ASCII 0x1B = 27 = 0o33).
Po tym znaku występuje kod sterujący C1 i dla potrzeb kolorowania i formatowania tekstu oraz określania jego pozycji najistotniejszy jest *Control Sequence Introducer* zapisywany za pomocą znaku `[`.
Po nim podawane są rozdzielane przy pomocy średnika argumenty (np. określające formatowanie tekstu) a sekwencję kończy kod określający polecenie do wykonania z użyciem tych argumentów (np. `m` - formatowanie tekstu, `H` - ustawienie pozycji kursora, czyli miejsca wpisywania tekstu, itd).

Przykłady (bash):

	echo -e '\033[31mCZERWONY\033[0m'
	echo -e '\033[34mGRANATOWY\033[0m'
	echo -e '\033[36mJASNO NIEBIESKI\033[0m'
	
	echo -e '\033[1mPOGRUBIENIE\033[0m'
	echo -e '\033[1;31mJASNO CZERWONY / CZERWONY POGRUBIONY\033[0m'
	
	echo -e '\033[33;40mŻÓŁTY NA CZARNYM TLE\033[0m'
	echo -e '\033[30;43mCZARNY NA ŻÓŁTYM TLE\033[0m'
	
	echo -e '\033[11;22Hnapis do wypisania od 22 znaku w 11 linii'

## podstawowe formatowanie

Podstawowe (3 bitowe) sekwencje kolorujące obsługują 8 kolorów (wartości od 0 – czarny do 7 – biały).
Można niezależnie ustawiać kolor napisu (30 + numer koloru) i tła (40 + numer koloru) oraz dodatkowe opcje formatowania (podkreślenie, miganie, pogrubienie, etc).
`\033[0m` (lub krócej `\033[m`) resetuje całość formatowania do ustawień domyślnych terminala.

Nie wszystkie sekwencje są wspierane przez wszystkie terminale.
Poszczególne kolory mogą też różnić się odcieniem zależnie od używanego terminala.

## więcej kolorów

Sekwencje 4 bitowe rozszerzają zbiór kolorów o ich jaśniejsze warianty (kod koloru zwiększony o 60). Przykład:

	echo -e '\033[36mZWYKLY\033[96mJASNY\033[0m'

Jeżeli nasz terminal obsługuje 256 kolorów (np. xterm) to możemy cieszyć się większą paletą barw. Przykłady:

	for i in `seq 0 255`; do echo -en "\033[38;5;${i}m"; printf " %02x " $i; done; echo -e '\033[0m'
	for i in `seq 0 255`; do echo -en "\033[48;5;${i}m"; printf " %02x " $i; done; echo -e '\033[0m'

Możliwe jest też użycie palety barw RGB przy pomocy sekwencji postaci: `\033[38;2;${r};${g};${b}m` (dla koloru fontu) lub `\033[48;2;${r};${g};${b}m` dla koloru tła, na przykład:

	for r in `seq 0 15 255`; do
		for g in `seq 0 15 255`; do
			for b in `seq 0 15 255`; do
				echo -en "\033[48;2;${r};${g};${b}m ";
			done;
		done;
	done;
	echo -e '\033[0m'

Zaletą zapisu RGB jest to że (przynajmniej w teorii) powinien dawać taki sam kolor dla wszystkich wspierających go terminali,
	natomiast wadą jest to że część terminali nie wspiera tej funkcjonalności.

Jeżeli korzystamy z multipleksera terminala typu tmux, to aby obsługiwał 256 kolorów, nie wystarczy że będzie on działać pod kontrolą xterm.
Wymagane jest też poinformowanie go zmienną środowiskową `TERM` (przed jego uruchomieniem) że działa na takim terminalu, np. poprzez: `TERM=xterm-256color tmux`.

## TERM, ncurces i termcap / terminfo

Jak wcześniej wspomnieliśmy nie wszystkie sekwencje są wspierane przez każdy terminal.
W związku z tym biblioteki (takie jak np. [ncurces](https://pl.wikipedia.org/wiki/Ncurses)) wykorzystujące muszą znać możliwości danego terminala.
Do ich identyfikacji wykorzystywana jest zmienna środowiskowa `TERM` oraz bazy danych typu termcap i terminfo.

## więcej informacji i przykładów

* [Kolorowe Powłoki](http://www.linuxfocus.org/Polish/May2004/article335.shtml)
* [Bash tips: Colors and formatting](https://misc.flogisoft.com/bash/tip_colors_and_formatting)
