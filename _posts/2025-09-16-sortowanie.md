---
layout: post
title: Sortowanie w stylu C z poprawną kolejnością polskich znaków
author: Robert Paciorek
tags:
- debian
- kde
---

Sortowanie w stylu *C* (`LANG=C.UTF-8`) nie umieszcza liter z akcentami w pobliżu ich podstawowych wersji (np. ł zaraz po l), zamiast tego umieszcza wszystkie znaki z poza ASCI po znakach z tego zakresu.
Sortowanie unicodowe jest niezgodne z sortowaniem *C* pod względem braku uprzywilejowania wielkich liter (w sortowaniu *C* wszystkie wielkie litery są przed dowolną małą litera) oraz ignorowaniem w sortowaniu wielu znaków specjalnych (np. kropki).

Niestety nie istnieje gotowe ustawienie sortowania które zapewniałoby umieszczanie znaków z polskimi ogonkami bezpośrednio po ich wersjach podstawowych, a jednocześnie nie wprowadzało innych zmian związanych z sortowaniem unicodowym (jak ignorowanie znaków specjalnych). Rozwiązaniem może być odpowiednia modyfikacja pliku definiującego locale - dla polskich locali `/usr/share/i18n/locales/pl_PL` ([łatka](/files/sortowanie-locales-pl_PL.diff)) lub utworzenie zupełnie nowych locali z takimi zmianami.

Niestety Dolphin (gdy qt jest zbudowane z włączoną obsługą biblioteki icu) ignoruje sortowanie definiowane przez locale (używając sortowania dostarczonego przez icu lub gdy nie jest dostępne wracając do sortowania *C*). Można temu zaradzić modyfikując odpowiednio smego Dolphin, aby sortował zgodnie z posix'owymi locale - [łatka](/files/sortowanie-dolphin.diff).
