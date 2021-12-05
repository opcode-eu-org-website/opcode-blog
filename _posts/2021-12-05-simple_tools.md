---
layout: post
title: Proste przydatne narzędzia i kawałki kodu
author: Robert Paciorek
tags:
- shell
- python
- network
---

Wpis zbiera proste narzędzia, które mogą okazać się przydatne w różnych zastosowaniach.

## Serwer SMTP w busybox (netcat, sh, awk)

Jest to bardzo prosty serwer SMTP (wykorzystujący do nasłuchu netcat'a).
Umożliwia on sterowanie (wykonywanie zdalnych poleceń przy pomocy odpowiednio spreparowanych maili)

Pozwala na odbieranie poczty i wykorzystywanie jej do sterowania systemem na którym nie mamy serwera pocztowego, a dysponujemy jedynie podstawowymi narzędziami - w teorii powinien wystarczyć busybox.

Uruchomienie: `while true; do netcat -l -p 25 -e smtp.sh; done`.
Wymaga *busybox* z netcatem potrafiącym odpalić skrypt w `-e` lub innego netcata mającego taką funkcjonalność..

Kod źródłowy ([do pobrania](/files/simple_tools/smtp_server.sh)):

<pre>{{ site.includeRaw(site.source + "/files/simple_tools/smtp_server.sh") }}</pre>


## Serwer HTTP w pythonie

Jest to prosty serwer HTTP z użyciem Pythona i jego standardowego modułu *http.server*. Serwer ten (w odróżnieniu od wywołania typu `python3 -m http.server` pozwalającego serwować zawartość katalogów) pozwala na wykonanie dowolnej akcji w odpowiedzi na żądanie HTTP i przesłanie dowolnej odpowiedzi do klienta. Może być użyty np. do zdalnego sterowania poprzez HTTP.

Kod źródłowy ([do pobrania](/files/simple_tools/http_server.py)):

<pre>{{ site.includeRaw(site.source + "/files/simple_tools/http_server.py") }}</pre>
