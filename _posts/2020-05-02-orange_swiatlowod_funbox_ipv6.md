---
layout: post
title: Orange Światłowód, FunBox 3.0 i IPv6
author: Robert Paciorek
tags:
- ipv6
- network
---

Orange zapewnia natywny dostęp IPv6 jeżeli w ramach loginu PPPoE `...@neostrada.pl` użyjemy sufiksu `/ipv6` czyli `...@neostrada.pl/ipv6`.
W umowie wskazany jest właśnie login z tym sufiksem, wydaje się że tak jest w większości umów.
Pomimo tego modem „FunBox 3.0” regularnie usuwa ten surfix z używanego loginu tym samym wyłączając IPv6.

Rozwiązaniem problemu może być użycie cron'a do sprawdzania dostępności IPv6 i jej przywracania z użyciem poniższego skryptu ([check_ipv6.sh](/files/check_ipv6.sh)):

<pre>{{ site.includeRaw(site.source + "/files/check_ipv6.sh") }}</pre>

Skrypt wymaga `python3` i `curl`.
Konieczne jest ustawienie w skrypcie lub pliku konfiguracyjnym (`/etc/network/check_ipv6.cfg`) adresu IPv4 swojego routera (zmienna `ROUTER`), hasła do routera (zmienna `PASSWORD`) oraz loginu neostrady bez sufiksu (zmienna `LOGIN`).
Domyślnie skrypt do sprawdzania dostępności IPv6 używa serwerów DNS od Google i OpenDNS adresy te można zmienić poprzez odpowiednie zmienne.

Całość procedury przywrócenia IPv6 zajmuje około minuty, co przy uruchamianiu skryptu przez `crond` co 1 minutę daje niedostępność IPv6 przez niecałe 2 minuty.
