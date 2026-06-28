---
layout: post
title: Format czasu w Dolphin i nie tylko
author: Robert Paciorek
tags:
- debian
- dolpin
- kde
---

Aplikacje kde nie pozwalają na swobodną konfigurację formatu daty i czasu, często też ignorując ustawienia systemowe w tym zakresie.
Wynika to z korzystania z biblioteki icu do obsługi locales przez qt (ten sam problem występował przy [sortowaniu](/2025/09/16/sortowanie.html)), dodatkowo w wielu miejscach zahardkodowane jest używanie relatywnego formatu czasu ("Właśnie teraz", "Wczoraj o 12:13") bądź formatu długiego (który np. przy localach icu `en_SE`, będących w KDE najbliższym odpowiednikiem systemowego `ed_DK`, powoduje wypisywanie nazwy strefy czasowej pełnymi słowami).

Poniżej zamieszczam patche wymuszające stosowanie formatu daty i czasu zgodnego z [RFC 3339](https://www.rfc-editor.org/info/rfc3339/) (czyli [ISO 8601](https://en.wikipedia.org/wiki/ISO_8601) z dopuszczeniem użycia spacji zamiast `T` do rozdzielania daty od czasu) w postaci `yyyy-MM-dd HH:mm:ss t` (w notacji [icu](https://unicode-org.github.io/icu/userguide/format_parse/datetime/#date-field-symbol-table)) / `%Y-%m-%d %H:%M:%S %Z` (w notacji [date](https://man7.org/linux/man-pages/man1/date.1p.html) / [strftime](https://en.cppreference.com/c/chrono/strftime)):

* [patch](/files/time_format-kio-fileproperties.patch) dla [libkf6kiowidgets6](https://packages.debian.org/trixie/libkf6kiowidgets6)
	* format daty i czasu oknie właściwości pliku
* [patch](/files/time_format-baloo-widgets.patch) dla [libkf6baloowidgets6](https://packages.debian.org/trixie/libkf6baloowidgets6)
	* format daty i czasu w tooltip (oraz panel "info") w Dolphin
* [patch](/files/time_format-dolpin.patch) dla [dolphin](https://packages.debian.org/trixie/dolphin)
	* format daty i czasu w widoku szczegółowej listy plików w Dolphin
	* minimalna szerokość widgetu w tooltip (oraz panel "info") w Dolphin - tak aby data mieściła się w jednej linii
