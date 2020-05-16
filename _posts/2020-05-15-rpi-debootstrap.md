---
layout: post
title: Tworzenie obrazu karty SD dla Raspberry Pi z użyciem debootstrap
author: Robert Paciorek
tags:
- debian
- pi
---

Dedykowaną dystrybucją Linuxa dla komputerków jedno płytkowych Raspberry Pi jest Raspbian (będący jedną z odmian Debiana).
Dostarczany on jest typowo w postaci gotowych obrazów kart SD.
Niestety nawet minimalistyczne obrazy Raspbiana zawierają często wiele zbędnych pakietów.
Możliwe jest jednak łatwe przygotowanie własnego dedykowanego obrazu korzystając z instalacji w oparciu o debootstrap (dokładniej qemu-debootstrap).

Poniższy skrypt ([build-rpi-image.sh](/files/build-rpi-image.sh)) służy do automatycznego tworzenia takich obrazów.
Jedyną czynnością wymaganą do utworzenia obrazu (oprócz uruchomienia skryptu) jest wpisanie odpowiednich kluczy SSH do pliku `authorized_keys` w utworzonym obrazie i/lub ustawienie hasła użytkownika.
Po nagraniu na kartę SD i zabootowaniu system będzie dostępny poprzez ssh z użyciem adresu IPv6 link-local (ustalanego jednoznacznie w oparciu o mac adres używanej płytki) i ustawianego klucza ssh.

Skrypt ten można potraktować też jako instruktarz tworzenia takich obrazów, należy zwrócić uwagę na:

* przygotowanie odpowiedniego układu partycji w obrazie (po wcześniejszym przygotowaniu pliku obrazu i jego zamapowaniu jako urządzenia `loop`)
* instalacja odpowiedniego jądra i bootloadera (`raspberrypi-kernel` i `raspberrypi-bootloader`)
* utworzenie plików `cmdline.txt` i `config.txt` na rozruchowej partycji vfat `/boot`

Więcej informacji o tworzeniu bootowalnych obrazów można znaleźć w artykule [Własny Debian LiveUSB](http://www.opcode.eu.org/LiveUSB.xhtml).

Tworzony obraz dedykowany jest dla Raspberry Pi w pierwszej wersji (dla innych odmian konieczne może być doinstalowanie dodatkowych pakietów z firmware) dostępnego jedynie poprzez SSH (dlatego zamiast ustawiania hasła skrypt przypomina o dodaniu kluczy SSH) i testowany był na „Raspberry Pi Model B rev. 2”.

Do automatycznej personalizacji tworzonego obrazu (np. ustawiania kluczy SSH, konfiguracji IP, etc) może posłużyć plik `build-rpi-image.conf` i redefiniowana w nim funkcja `configureLOCAL`. W pliku tym można tez zmienić wartości zmiennych konfiguracyjnych takich jak np. `piuser` (określającej nazwę usera z sudo) `hostname` (określającej nazwę hosta).

Skrypt wymaga zainstalowania pakietów: `parted` `qemu-user-static` `binfmt-support` `debootstrap`.

<pre>{{ site.includeRaw(site.source + "/files/build-rpi-image.sh") }}</pre>
