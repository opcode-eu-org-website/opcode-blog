---
layout: post
title: SSH jako VPN
author: Robert Paciorek
tags:
- debian
- network
---

VPN czyli *wirtualna sieć prywatna* pozwala udawać że maszyna korzystająca z tej technologii podłączona jest bezpośrednio do jakiejś sieci wewnętrznej (lokalnej) bez względu na to gdzie faktycznie się ona znajduje.
Opiera się to na tunelowaniu ruchu IP lub L2 (tej wirtualnej sieci) w przesyłanych (poprzez inną, zazwyczaj publiczną sieć) pakietach IP z użyciem wirtualnych interfejsów sieciowych powiązanych z drugą stroną takiego tunelu.

Często w tym celu wykorzystywany jest OpenVPN, będący dedykowanym oprogramowaniem do takich zastosowań. Bardzo wiele funkcjonalności VPN możemy jednak uzyskać korzystając zamiast niego z odpowiednich opcji ssh.

## proste tunele SSH

Funkcjonalność zbliżoną do VPN (jednak nim nie będącą) można uzyskać dzięki opcjom tunelom ssh tworzonym z użyciem opcji `-L`, `-R` i `-D`.

Opcja `-L portLokalny:hostZdalny:portZdalny` pozwala dociągnąć do klienta ssh wskazany port wskazanej maszyny dostępnej z serwera ssh. Odbywa się to poprzez
utworzenie tunelu przekierowującego dane kierowane na `portLokalny` komputera na którym działa klient ssh do portu `portZdalny` na serwerze `hostZdalny` poprzez serwer ssh
(i przesyłającego odpowiedzi odebrane przez serwer ssh do klienta). Z punktu widzenia `hostZdalny` połączenie z nim nawiązauje serwer ssh,
jest to przydatne gdy `hostZdalny` jest osiągalny z serwera ssh, ale nie z komputera lokalnego.

Opcja `-R portZdalny:hostLokalny:portLokalny` działa analogicznie tyle że w drugą stronę – pozwala dociągnąć do serwera ssh wskazany port wskazanej maszyny dostępnej z klienta ssh.
Odbywa się to poprzez utworzenie tunelu przekierowującego dane kierowane na `portZdalny` komputera na którym działa serwer ssh do portu `portLokalny` na serwerze `hostLokalny` poprzez klienta ssh.
Typowo serwer ssh na porcie `portZdalny` słucha jedynie na localhost, czyli port ten jest dostępny dla procesów działających na serwerze ssh, ale nie jest dostępny dla innych maszyn w sieciach do których dostęp ma serer ssh.

Opcja `-D port` tworzy tunel dynamiczny typu SOCKS4 / SOCKS5 na wskazanym porcie. Może on być użyty jako proxy typu SOCKS np. w Firefoxie w celu zapewnienia dostępu do zasobów WWW dostępnych z serwera SSH a niedostępny z komputera lokalnego.

Opcje te pozwalają także na przekazywanie ruchu do/z gniazd typu UNIX oraz określanie adresu na którym będzie nasłuchiwanie – szczegóły można sprawdzić w `man ssh`.
Można też wspomnieć o opcji `-W host:port`, która działa jak `ssh 'nc host port'`, czyli przekierowuje standardowe wejście / wyjście jako połączenie TCP do wskazanego portu na wskaznym hoście.

Metody te pomimo, iż są często stosowane i bardzo użyteczne, mają także ograniczenia – pozwalają jedynie na przekierowywanie pojedynczych portów TCP oraz wymagają zmiany adresu i numeru portu z którym łączy się klient (opcje `-L` i `-R`), bądź wymagają odpowiedniego wsparcia w kliencie (opcje `-D`).


## wirtualne urządzenie sieciowe

Na pełne przekazywanie ruchu pomiędzy wirtualnymi kartami sieciowymi typu `tun` lub `tap` (czyli utworzenie wirtualnej sieci prywatnej) pozwala opcja `-w`.

Aby było możliwe wykorzystanie tej opcji serwer ssh musi mieć włączoną zgode na tworzenie tuneli w swojej konfiguracji (`/etc/ssh/sshd_config`) poprzez ustawienie `PermitTunnel` na `yes`.
Natomiast aby korzystanie z tej opcji nie wymagało bezpośredniego logowania na root'a urządzenie tunelowe po stronie serwera powinno być wcześniej utworzone i przypisane odpowiedniemu użytkownikowi lub grupie, np. za pomocą:

	ip tuntap add tun1 mode tun user NAZWA_UZYTKOWNIKA

Wykonanie analogicznej operacji po stronie klienta ssh pozwoli na uruchamianie go z prawami zwykłego użytkowania.

Przypisanie urządzenia tunelowego użytkownikowi (lub grupie) nie oznacza nadania mu praw konfiguracji tego urządzenia (np. ustawienia adresu ip) a jedynie prawo dla procesów tego użytkownika otrzymywania pakietów trafiających do tego urządzenia i generowania pakietów wychodzących tym urządzeniem. Konfiguracja urządzenia nadal wymaga praw roota, może ona jednak zostać wykonana od razu przy tworzeniu tego urządzenia (odpowiednią komendą lub wpisem konfiguracyjnym). Na przykład następujący wpis w `/etc/network/interfaces` na systemach debiano-pochodnych automatycznie utworzy i skonfiguruje urządzenie tunelowe `tun1`:

	auto tun1
	iface tun1 inet static
		address 172.16.18.1                                          # ip tej strony tunelu
		netmask 255.255.255.252
		pre-up  ip tuntap add tun1 mode tun user NAZWA_UZYTKOWNIKA   # użytkownik uprawniony do używania tunelu (wywołujący ssh / logowany poprzez ssh)
		up      ip r a 172.16.16.0/27 via 172.16.18.2                # routing sieci które chcemy przekazywać tunelem

### numer urządzenia tunelowego

Opcja `-w` pozwala określić numery urządzeń tunelowych, które mają zostać użyte do utworzenia połączenia. `ssh -w X:Y serwerSSH` oznacza iż po stronie klienta zostanie użyte urządzenie o numerze X (czyli `tunX`) a po stronie serwera ssh `tunY`.

### tun vs tap

SSH domyślnie tworzy urządzenia tunelowe typu `tun`, czyli operującymi w warstwie sieciowej – przekazujące pakiety IP.
Możliwe jest korzystanie także z urządzeń typu `tap`, czyli operujących w warstwie L2 – przesyłających ramki ethernetowe.
W tym celu należy przed opcją `-w` podać opcję `-o Tunnel=ethernet` (wtedy numery podawane w opcji `-w` odnoszą się do urządzeń o nazwach `tap`).
W takim wypadku tworzone wcześniej urządzenia tunelowe także muszą być typu `tap` i posiadać nazwy wg schematu `tapX`, gdzie `X` jest wartością numeryczną.
Do ich tworzenia można skorzystać z polecenia:

	ip tuntap add tap1 mode tap user NAZWA_UZYTKOWNIKA

Zastosowanie urządzeń typu `tap` pozwala na bridgowanie takich urządzeń z innymi urządzeniami sieciowymi oraz przekazywanie przez nie pakietów warstw niższych niż IP (np. pakietów ARP).
Pozwala to również na działanie programów / usług korzystających z L2 a nie z IP.
