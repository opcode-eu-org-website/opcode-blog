---
layout: post
title: Budowa systemu monitoringu infrastruktury obiektów data center
author: Robert Paciorek
tags:
- konferencje
- bms
---

Wystąpienie na konferencji "Data Center Trends" (Warszawa 2020-02-27).

Monitoring parametrów pracy obiektów data center, w szczególności systemów zasilania, chłodzenia i bezpieczeństwa jest bardzo istotny.
Często w tym celu stosowany jest któryś z wielu dostępnych na rynku systemów typu BMS.
Niestety rozwiązania takie mają liczne ograniczenia a ich w drożenie w nie całkiem typowym dla nich zastosowaniu niemal czystego monitoringu (bez funkcji sterowania) potrafi być kłopotliwe.
Jako że głównymi użytkownikami data center jest branża IT, można pokusić się o zastosowanie do monitoringu DC znanych rozwiązań monitoringu infrastruktury IT (takich jak nagios, zabbix, itp) wraz z siecią monitorującą opartą o TCP/IP i standardowe, otwarte protokoły.

[Prezentacja](/files/monitoring_obiektow_data_center-prezentacja.pdf)

## Materiały dodatkowe

### Prometheus, Grafana i Thanos

Powyższa prezentacja pokazuje rozwiązanie oparte na zabbixie i bezpośrednim dostępie do jego bazy SQL (dla celów zewnętrznej wizualizacji). W miejsce zabbixa może zostać użyte innego podobne oprogramowanie np. Prometheus wspomagany Grafaną i Thanosem. Takie podejście powinno ułatwić archiwizację starszych danych (Thanos), a także pozwala na lepsze oddzielenie konfigu od danych (konfiguracja zbierania danych przez Prometheusa w plikach yaml).

### Modbus i BACnet

W pokazywanym w prezentacji rozwiązaniu odczyt wartości z urządzeń Modbus i BACnet realizowany był z użyciem [libmodbus](https://libmodbus.org/) i [BACnet Stack](http://bacnet.sourceforge.net/) oraz własnych programów, skryptów. Przykładowy kod służący odczytowi Modbus: [modbus-ion7650.c](/files/modbus-ion7650.c) oraz BACnet: [bacnetRead.sh](/files/bacnetRead.sh)

### integracja CCTV IP

Z takim otwartym systemem monitoringu parametrów zintegrowany może być także system telewizji dozorowej opartej o technologię IP. Poniżej przedstawiony jest przykładowy schemat takiego rozwiązania. Zakłada on użycie kamer IP z detekcją ruchu / obiektów / alarmów realizowaną w kamerze oraz z możliwością zapisu strumienia wideo bezpośrednio przez kamerę na zewnętrzną macierz.

<p style="text-align: center;"><img style="width:95%;" alt="" src="/files/cctv.svg" /></p>

### protokoły, standardy, hardware, ...

Projektując system monitoringu należy szczególną uwagę zwrócić na otwartość i powszechną dostępność dokumentacji stosowanych protokołów oraz pełną dokumentację dla monitorowanych urządzeń (aby wiedzieć jakie znaczenie ma czytana wartość - jak ją interpretować). Warto zadbać aby nie stosować zbyt wielu protokołów, ale nie jest to ostry wymóg - system z kilkoma otwartymi protokołami (np. Modbus, BACnet + SNMP) jest w pełni do opanowania.

Warto mieć także na uwadze że często zamiast sterownika PLC wystarczy nam moduł I/O z komunikacją Modbus TCP. Przydatne też są komputerki jednopłytkowe typu Raspberry / Banana / Orange Pi, mogące pełnić zasadniczo dowolne funkcje (ew. po doposażeniu w odpowiednie shieldy z wejściami/wyjściami).
