---
layout: post
title: Sposób na brakujące ikony zakładek w Firefox
author: Robert Paciorek
tags:
- x11
- firefox
---

Przy dodawaniu zakładek do niektórych stron Firefox nie jest w stanie wyświetlić odpowiedniej ikony dla zakładki.
Dla przykładu - zakładka do `https://moj.gov.pl/nforms/signer/upload?xFormsAppName=SIGNER` nie posiada ikony, ale do `https://www.gov.pl/web/gov/podpisz-dokument-elektronicznie-wykorzystaj-podpis-zaufany` już tak.

Brakujące zakładki moża naprawić ręcznie. W tym celu przy wyłączonym Firefoxie należy uruchomić `sqlite3 favicons.sqlite` w katalogu z profilem na którym występuje problem i wydać stosowne polecenia SQL - np.:

	INSERT INTO moz_pages_w_icons VALUES(13, "https://moj.gov.pl/nforms/signer/upload?xFormsAppName=SIGNER", 47358960197262);
	INSERT INTO moz_icons_to_pages VALUES(13, 20, 2082927202);
	INSERT INTO moz_icons_to_pages VALUES(13, 21, 2082927202);

Należy mieć na uwadze że w powyższym przykładzie:

* `13` to id w tabeli `moz_pages_w_icons` i należy je ustawić na maksymalne plus jeden
* `20` i `21` to id w tabeli `moz_icons` wcześniej dodanych do favicons.sqlite ikon, można je odczytać z mapowań w `moz_icons_to_pages` (w tym przykładzie były to ikony przypisane do `https://www.gov.pl/...`)
