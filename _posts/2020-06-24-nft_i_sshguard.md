---
layout: post
title: sshguard i nftables
author: Robert Paciorek
tags:
- debian
- network
---

*sshguard* służy blokowaniu ataków siłowych na ssh i inne usługi.
Jego działanie polega na bieżącej analizie logów systemowych w poszukiwaniu (zbyt częstych) prób nieautoryzowanego dostępu i generowaniu reguł firewalla blokujących adresy IP z których pochodzi atak.

W przypadku wersji &lt; 2.0 i używania go wraz z *iptables* możliwe było konfigurowanie na poziomie samego firewalla dla jakich połączeń chcemy stosować wygenerowane poprzez ustawienie `ENABLE_FIREWALL=0` w `/etc/default/sshguard` i samodzielne kierowanie ruchu, który chcemy filtrować do  łańcucha `sshguard`.

Wersja 2.3 dostarczanej wraz z Debian Buster domyślnie wykorzystuje *nftables* tworząc łańcuchy z priorytetem -10 na których odbywa się blokowanie całego ruchu pochodzącego z atakujących adresów.
Rozwiązanie takie umożliwia łatwe i pewne uruchomienie usługi *sshguard* bez ingerencji w (standardowe) konfiguracje firewalla, jednak utrudnia bardziej zaawansowane ustawienia (np. ograniczenie działania blokad *sshguard* tylko do nowych połączeń ssh).
Wymaga też restartowania *sshguard* po przeładowaniu reguł firewalla (jeżeli użyto czyszczenia wszystkich poprzez `nft flush ruleset`) lub dopisania szkieletu reguł wymaganego przez *sshguard* do firewalla.

*sshguard* pozwala jednak na definiowanie własnych skryptów służących obsłudze firewalla, dzięki czemu możemy jego działanie ograniczyć do dodawania i usuwania adresów IP z odpowiednich list.
W tym celu w pliku `/etc/sshguard/sshguard.conf` należy ustawić zmienną `BACKEND` na ścieżkę do wykonywalnego pliku o następującej treści:

	#!/bin/bash
	
	flush() {
		nft flush set inet filter sshguard_blocked_ipv4
		nft flush set inet filter sshguard_blocked_ipv6
	}
	
	trap flush EXIT
	
	while read cmd address addrtype cidr; do
		case $cmd in
			block)
				nft add    element inet filter sshguard_blocked_ipv$addrtype "{ $address/$cidr }";;
			release)
				nft delete element inet filter sshguard_blocked_ipv$addrtype "{ $address/$cidr }";;
			flush)
				flush;;
			flushonexit)
				;;
			*)
				echo "Invalid command" >&2; exit;;
		esac
	done

Taka konfiguracja dla *sshguard* zakłada że w firewallu opartym na *nftables* w tablicy *filter* typu *inet* istnieją dwa nazwane zbiory adresów *sshguard_blocked_ipv6* i *sshguard_blocked_ipv4* używane odpowiednio do blokowania ataków pochodzących z adresów IPv6 i IPv4.
Skrypt konfiguracyjny *nftables* tworzący takie set'y oraz używający ich do filtrowania jedynie połączeń ssh może wyglądać następująco:

	#!/usr/sbin/nft -f
	flush ruleset
	
	table inet filter {
		chain INPUT {
			type filter hook input priority 0; policy drop;
			
			# lo and established / invalid connections
			iifname "lo" accept
			ct state {established, related} accept
			ct state invalid reject
			
			# icmp, igmp
			meta l4proto icmp icmp type timestamp-request reject
			meta l4proto {icmp, ipv6-icmp, igmp} accept
			
			# ssh
			tcp dport ssh jump sshguard
			
			# reject all other packets with ICMP error
			reject
		}
		
		chain sshguard {
			# adresy wyłącznoe z sprawdzania przez sshguard
			ip  saddr 10.40.0.0 accept
			ip6 saddr { 2001:db8:0:a17::123, 2001:db8:0:1313::/64 } accept
			# blokowanie dodanych do odpowiednich set'ów przez sshguard
			ip  saddr @sshguard_blocked_ipv4 drop
			ip6 saddr @sshguard_blocked_ipv6 drop
			# akceptacja niezablokowanych przez sshguard
			accept
		}
		
		set sshguard_blocked_ipv6 {
			type ipv6_addr; flags interval
		}
		
		set sshguard_blocked_ipv4 {
			type ipv4_addr; flags interval
		}
	}

Więcej o *nftables* w [TCP/IP &amp; Ethernet](http://www.opcode.eu.org/Sieci.pdf).
